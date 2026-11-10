<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CashOutRequest;
use App\Models\TimeCoinWallet;
use App\Models\TimeCoinTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function summary(Request $request): JsonResponse
    {
        $wallet = TimeCoinWallet::where('user_id', $request->user()->id)->first();
        $transactions = $wallet
            ? TimeCoinTransaction::where('wallet_id', $wallet->id)->latest('created_at')->limit(20)->get()
            : collect();

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => $wallet?->balance ?? 0,
                'locked_balance_tc' => $wallet?->locked_balance ?? 0,
                'estimated_idr' => ($wallet?->balance ?? 0) * 1000,
                'cashout_fee_percent' => $request->user()->hasRole('mentor') && ! $this->isPremium($request) ? 10 : 0,
                'recent_transactions' => $transactions->map(fn (TimeCoinTransaction $transaction) => [
                    'id' => $transaction->id,
                    'type' => $transaction->transaction_type,
                    'direction' => $transaction->direction,
                    'ledger_account' => $transaction->ledger_account,
                    'amount' => $transaction->amount,
                    'status' => $transaction->status,
                    'created_at' => $transaction->created_at,
                ]),
            ],
        ]);
    }

    public function requestCashOut(Request $request): JsonResponse
    {
        if ($request->user()->hasRole('mentor')) {
            abort_unless($request->user()->mentorProfile?->verification_status === 'approved', 403, 'Akun mentor belum terverifikasi.');
        }

        $data = $request->validate([
            'amount_tc' => ['required', 'integer', 'min:1', 'max:10000000'],
            'bank_name' => ['required', 'string', 'max:100'],
            'account_number' => ['required', 'string', 'max:100'],
            'account_holder_name' => ['required', 'string', 'max:150'],
        ]);
        $result = DB::transaction(function () use ($request, $data) {
            $wallet = TimeCoinWallet::where('user_id', $request->user()->id)->lockForUpdate()->firstOrFail();
            abort_if($wallet->balance < $data['amount_tc'], 422, 'Saldo TimeCoin tidak mencukupi.');
            $grossIdr = $data['amount_tc'] * 1000;
            $feeRate = $request->user()->hasRole('mentor') && ! $this->isPremium($request) ? 0.10 : 0;
            $feeIdr = (int) round($grossIdr * $feeRate);
            $cashOut = CashOutRequest::create([
                'user_id' => $request->user()->id,
                'amount_tc' => $data['amount_tc'],
                'admin_fee_idr' => $feeIdr,
                'disbursed_amount_idr' => $grossIdr - $feeIdr,
                'bank_name' => $data['bank_name'],
                'account_number' => $data['account_number'],
                'account_holder_name' => $data['account_holder_name'],
                'status' => 'pending_transfer',
            ]);
            $wallet->decrement('balance', $data['amount_tc']);
            TimeCoinTransaction::create([
                'wallet_id' => $wallet->id,
                'sender_id' => $request->user()->id,
                'recipient_id' => $request->user()->id,
                'transaction_type' => 'cash_out',
                'direction' => 'debit',
                'ledger_account' => 'balance',
                'amount' => $data['amount_tc'],
                'reference_type' => CashOutRequest::class,
                'reference_id' => $cashOut->id,
                'status' => 'pending',
            ]);

            return $cashOut;
        }, 3);

        return response()->json([
            'status' => 'success',
            'message' => 'Pengajuan pencairan berhasil dibuat.',
            'data' => [
                'id' => $result->id,
                'amount_tc' => $result->amount_tc,
                'disbursed_amount_idr' => $result->disbursed_amount_idr,
                'admin_fee_idr' => $result->admin_fee_idr,
                'admin_fee_percent' => $request->user()->hasRole('mentor') && ! $this->isPremium($request) ? 10 : 0,
                'status' => $result->status,
            ],
        ], 201);
    }

    public function cashOutHistory(Request $request): JsonResponse
    {
        $history = CashOutRequest::where('user_id', $request->user()->id)->latest()->paginate(20);

        return response()->json(['status' => 'success', 'data' => $history]);
    }

    public function resolveCashOut(Request $request, CashOutRequest $cashOutRequest): JsonResponse
    {
        $data = $request->validate(['status' => ['required', 'in:completed,failed']]);
        $result = DB::transaction(function () use ($request, $cashOutRequest, $data) {
            $cashOut = CashOutRequest::query()->lockForUpdate()->findOrFail($cashOutRequest->id);
            abort_unless($cashOut->status === 'pending_transfer', 409, 'Pengajuan ini sudah diproses.');
            $wallet = TimeCoinWallet::where('user_id', $cashOut->user_id)->lockForUpdate()->firstOrFail();
            $ledger = TimeCoinTransaction::where('reference_type', CashOutRequest::class)
                ->where('reference_id', $cashOut->id)
                ->lockForUpdate()
                ->firstOrFail();

            if ($data['status'] === 'failed') {
                $wallet->increment('balance', $cashOut->amount_tc);
                TimeCoinTransaction::create([
                    'wallet_id' => $wallet->id,
                    'sender_id' => $request->user()->id,
                    'recipient_id' => $cashOut->user_id,
                    'transaction_type' => 'cash_out_refund',
                    'direction' => 'credit',
                    'ledger_account' => 'balance',
                    'amount' => $cashOut->amount_tc,
                    'reference_type' => CashOutRequest::class,
                    'reference_id' => $cashOut->id,
                    'status' => 'completed',
                ]);
            }

            $cashOut->update(['status' => $data['status']]);
            $ledger->update(['status' => $data['status']]);

            return $cashOut->fresh();
        }, 3);

        return response()->json(['status' => 'success', 'message' => 'Status cash-out diperbarui.', 'data' => [
            'id' => $result->id,
            'status' => $result->status,
            'amount_tc' => $result->amount_tc,
        ]]);
    }

    public function pendingCashOuts(): JsonResponse
    {
        $cashOuts = CashOutRequest::with('user:id,name,email')
            ->where('status', 'pending_transfer')
            ->oldest()
            ->paginate(20);

        return response()->json(['status' => 'success', 'data' => $cashOuts]);
    }

    private function isPremium(Request $request): bool
    {
        $profile = $request->user()->mentorProfile;

        return (bool) $profile?->is_premium
            && (! $profile->premium_expires_at || $profile->premium_expires_at->isFuture());
    }
}
