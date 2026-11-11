<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Wallet\TopUpWalletRequest;
use App\Http\Requests\Wallet\TransferTimeCoinRequest;
use App\Http\Resources\WalletPresenter;
use App\Models\BankAccount;
use App\Models\CashOutRequest;
use App\Models\Reward;
use App\Models\RewardRedemption;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\User;
use App\Services\WalletService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function __construct(private readonly WalletService $walletService)
    {
    }

    public function summary(Request $request): JsonResponse
    {
        $user = $request->user()->load('studentProfile');
        $wallet = TimeCoinWallet::where('user_id', $user->id)->first();

        $transactions = $wallet
            ? TimeCoinTransaction::where('wallet_id', $wallet->id)
                ->where('ledger_account', 'balance')
                ->latest('created_at')
                ->limit(20)
                ->get()
            : collect();

        $totalIncome = $wallet
            ? (int) TimeCoinTransaction::where('wallet_id', $wallet->id)
                ->where('ledger_account', 'balance')
                ->where('direction', 'credit')
                ->sum('amount')
            : 0;

        $totalExpense = $wallet
            ? (int) TimeCoinTransaction::where('wallet_id', $wallet->id)
                ->where('ledger_account', 'balance')
                ->where('direction', 'debit')
                ->sum('amount')
            : 0;

        $bankAccounts = BankAccount::where('user_id', $user->id)
            ->orderByDesc('is_primary')
            ->latest()
            ->get()
            ->map(fn (BankAccount $b) => WalletPresenter::bankAccount($b));

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => $wallet?->balance ?? 0,
                'locked_balance_tc' => $wallet?->locked_balance ?? 0,
                'estimated_idr' => ($wallet?->balance ?? 0) * 1000,
                'total_income_tc' => $totalIncome,
                'total_expense_tc' => $totalExpense,
                'cashout_fee_percent' => $user->hasRole('mentor') && ! $this->isPremium($request) ? 10 : 0,
                'has_pin' => ! empty($user->studentProfile?->transaction_pin_hash),
                'bank_accounts' => $bankAccounts,
                'recent_transactions' => $transactions->map(fn (TimeCoinTransaction $t) => WalletPresenter::transaction($t)),
            ],
        ]);
    }

    public function transactions(Request $request): JsonResponse
    {
        $wallet = TimeCoinWallet::where('user_id', $request->user()->id)->first();
        if (! $wallet) {
            return response()->json([
                'status' => 'success',
                'data' => [],
                'meta' => ['current_page' => 1, 'last_page' => 1],
            ]);
        }

        $query = TimeCoinTransaction::query()
            ->where('wallet_id', $wallet->id)
            ->where('ledger_account', 'balance')
            ->when($request->filled('type'), fn ($q) => $q->where('transaction_type', $request->string('type')->toString()))
            ->when($request->filled('direction'), fn ($q) => $q->where('direction', $request->string('direction')->toString()))
            ->latest('created_at')
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 20), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (TimeCoinTransaction $t) => WalletPresenter::transaction($t))->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function topUp(TopUpWalletRequest $request): JsonResponse
    {
        $data = $request->validated();
        $topUp = $this->walletService->topUp(
            $request->user(),
            (int) $data['amount_tc'],
            $data['payment_channel'] ?? 'qris_sandbox',
        );
        $wallet = TimeCoinWallet::where('user_id', $request->user()->id)->first();

        return response()->json([
            'status' => 'success',
            'message' => "Top-Up {$topUp->amount_tc} TC berhasil diproses.",
            'data' => [
                'id' => $topUp->id,
                'amount_tc' => $topUp->amount_tc,
                'amount_idr' => $topUp->amount_idr,
                'payment_reference' => $topUp->payment_reference,
                'balance_tc' => $wallet?->balance ?? 0,
            ],
        ], 201);
    }

    public function recipients(Request $request): JsonResponse
    {
        $q = mb_strtolower(trim((string) $request->query('q', '')));
        $users = User::query()
            ->where('id', '!=', $request->user()->id)
            ->with('studentProfile')
            ->when($q !== '', function ($query) use ($q) {
                $like = '%'.$q.'%';
                $query->where(function ($inner) use ($like) {
                    $inner->whereRaw('LOWER(name) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(email) LIKE ?', [$like])
                        ->orWhereHas('studentProfile', fn ($sp) => $sp->whereRaw('LOWER(student_id_number) LIKE ?', [$like]));
                });
            })
            ->limit(15)
            ->get()
            ->map(fn (User $u) => [
                'id' => $u->id,
                'name' => $u->name,
                'email' => $u->email,
                'student_id_number' => $u->studentProfile?->student_id_number,
                'role' => $u->roleRecord?->name,
            ]);

        return response()->json(['status' => 'success', 'data' => $users]);
    }

    public function transfer(TransferTimeCoinRequest $request): JsonResponse
    {
        $identifier = ltrim(trim($request->input('recipient_identifier')), '@');
        $recipient = User::query()
            ->where('email', $identifier)
            ->orWhereHas('studentProfile', fn ($q) => $q->where('student_id_number', $identifier))
            ->orWhere('name', $identifier)
            ->first();
        abort_if(! $recipient, 404, 'Akun penerima tidak ditemukan. Gunakan email atau NIM yang valid.');

        $result = $this->walletService->transfer(
            $request->user(),
            $recipient,
            (int) $request->input('amount_tc'),
        );

        return response()->json([
            'status' => 'success',
            'message' => "{$result['amount_tc']} TC berhasil dikirim ke {$result['recipient_name']}.",
            'data' => $result,
        ], 201);
    }

    public function bankAccounts(Request $request): JsonResponse
    {
        $accounts = BankAccount::where('user_id', $request->user()->id)
            ->orderByDesc('is_primary')
            ->latest()
            ->get()
            ->map(fn (BankAccount $b) => WalletPresenter::bankAccount($b));

        return response()->json(['status' => 'success', 'data' => $accounts]);
    }

    public function storeBankAccount(Request $request): JsonResponse
    {
        $data = $request->validate([
            'bank_name' => ['required', 'string', 'max:100'],
            'account_number' => ['required', 'string', 'max:60'],
            'account_holder_name' => ['required', 'string', 'max:150'],
            'is_primary' => ['sometimes', 'boolean'],
        ]);

        $account = DB::transaction(function () use ($request, $data) {
            if (! empty($data['is_primary'])) {
                BankAccount::where('user_id', $request->user()->id)->update(['is_primary' => false]);
            }
            $hasAny = BankAccount::where('user_id', $request->user()->id)->exists();

            return BankAccount::create([
                'user_id' => $request->user()->id,
                'bank_name' => $data['bank_name'],
                'account_number' => $data['account_number'],
                'account_holder_name' => $data['account_holder_name'],
                'is_primary' => $data['is_primary'] ?? ! $hasAny,
            ]);
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Rekening tujuan pencairan berhasil disimpan.',
            'data' => WalletPresenter::bankAccount($account),
        ], 201);
    }

    public function rewards(Request $request): JsonResponse
    {
        $balance = TimeCoinWallet::where('user_id', $request->user()->id)->value('balance') ?? 0;
        $rewards = Reward::where('is_active', true)->orderBy('tc_price')->get();
        $vouchers = RewardRedemption::where('student_id', $request->user()->id)
            ->with('reward')
            ->latest()
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => $balance,
                'rewards' => $rewards->map(fn (Reward $r) => WalletPresenter::reward($r))->values(),
                'vouchers' => $vouchers->map(fn (RewardRedemption $v) => WalletPresenter::redemption($v))->values(),
            ],
        ]);
    }

    public function redeemReward(Request $request, Reward $reward): JsonResponse
    {
        $redemption = $this->walletService->redeemReward($request->user(), $reward);
        $balance = TimeCoinWallet::where('user_id', $request->user()->id)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'message' => "Reward {$redemption->reward->title} berhasil ditukar!",
            'data' => [
                'balance_tc' => $balance,
                'voucher' => WalletPresenter::redemption($redemption),
            ],
        ], 201);
    }

    public function requestCashOut(Request $request): JsonResponse
    {
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

            if (! BankAccount::where('user_id', $request->user()->id)->where('account_number', $data['account_number'])->exists()) {
                BankAccount::create([
                    'user_id' => $request->user()->id,
                    'bank_name' => $data['bank_name'],
                    'account_number' => $data['account_number'],
                    'account_holder_name' => $data['account_holder_name'],
                    'is_primary' => ! BankAccount::where('user_id', $request->user()->id)->exists(),
                ]);
            }

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
