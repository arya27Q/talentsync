<?php

namespace App\Http\Resources;

use App\Models\BankAccount;
use App\Models\Reward;
use App\Models\RewardRedemption;
use App\Models\TimeCoinTransaction;

final class WalletPresenter
{
    public static function transaction(TimeCoinTransaction $transaction): array
    {
        $title = match ($transaction->transaction_type) {
            'project_reward' => 'Imbalan Proyek UMKM',
            'mentoring_payment' => $transaction->direction === 'debit' || $transaction->direction === 'escrow_credit'
                ? 'Booking Sesi Mentoring'
                : 'Pembayaran Sesi Mentoring',
            'mentoring_refund' => 'Pengembalian Escrow Mentoring',
            'top_up' => 'Top-Up TimeCoin',
            'p2p_transfer' => $transaction->direction === 'debit'
                ? 'Kirim TimeCoin ke Rekan'
                : 'Terima TimeCoin dari Rekan',
            'voucher_redeem' => 'Penukaran Reward Hub',
            'cash_out' => 'Penarikan Dana (Cash-Out)',
            'cash_out_refund' => 'Pengembalian Cash-Out Gagal',
            default => ucfirst(str_replace('_', ' ', $transaction->transaction_type)),
        };

        return [
            'id' => $transaction->id,
            'title' => $title,
            'type' => $transaction->transaction_type,
            'direction' => $transaction->direction,
            'ledger_account' => $transaction->ledger_account,
            'amount' => $transaction->amount,
            'status' => $transaction->status,
            'created_at' => $transaction->created_at?->toIso8601String(),
        ];
    }

    public static function bankAccount(BankAccount $account): array
    {
        return [
            'id' => $account->id,
            'bank_name' => $account->bank_name,
            'account_number' => $account->account_number,
            'account_holder_name' => $account->account_holder_name,
            'is_primary' => (bool) $account->is_primary,
        ];
    }

    public static function reward(Reward $reward): array
    {
        return [
            'id' => $reward->id,
            'title' => $reward->title,
            'provider' => $reward->provider,
            'description' => $reward->description,
            'tc_price' => $reward->tc_price,
            'icon_key' => $reward->icon_key,
            'stock' => $reward->stock,
            'is_available' => (bool) $reward->is_active && $reward->stock > 0,
        ];
    }

    public static function redemption(RewardRedemption $redemption): array
    {
        return [
            'id' => $redemption->id,
            'reward_id' => $redemption->reward_id,
            'reward_title' => $redemption->relationLoaded('reward') ? $redemption->reward?->title : null,
            'provider' => $redemption->relationLoaded('reward') ? $redemption->reward?->provider : null,
            'paid_tc' => $redemption->paid_tc,
            'voucher_code' => $redemption->voucher_code,
            'qr_payload' => $redemption->qr_payload,
            'status' => $redemption->status,
            'expires_at' => $redemption->expires_at?->toIso8601String(),
            'created_at' => $redemption->created_at?->toIso8601String(),
        ];
    }
}

