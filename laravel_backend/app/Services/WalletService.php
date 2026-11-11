<?php

namespace App\Services;

use App\Models\Reward;
use App\Models\RewardRedemption;
use App\Models\TimeCoinWallet;
use App\Models\User;
use App\Models\WalletTopUp;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class WalletService
{
    public function __construct(
        private readonly TimeCoinLedgerService $ledger,
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    public function topUp(User $user, int $amountTc, string $channel): WalletTopUp
    {
        $topUp = DB::transaction(function () use ($user, $amountTc, $channel) {
            $wallet = TimeCoinWallet::firstOrCreate(['user_id' => $user->id]);
            $lockedWallet = TimeCoinWallet::whereKey($wallet->id)->lockForUpdate()->firstOrFail();

            $record = WalletTopUp::create([
                'user_id' => $user->id,
                'amount_tc' => $amountTc,
                'amount_idr' => $amountTc * 1000,
                'payment_channel' => $channel,
                'payment_reference' => 'TOP-'.strtoupper(Str::random(10)),
                'status' => 'completed',
            ]);

            $this->ledger->recordTopUp($lockedWallet, $user->id, $amountTc, $record);

            return $record;
        }, 3);

        $this->notifications->send(
            $user,
            'wallet_top_up',
            "+{$amountTc} TC Berhasil Ditambahkan",
            "Top-up sebesar {$amountTc} TC via {$channel} telah masuk ke dompet Anda.",
            '/wallet',
        );

        return $topUp;
    }

    public function transfer(User $sender, User $recipient, int $amountTc): array
    {
        abort_if($sender->id === $recipient->id, 422, 'Tidak dapat mengirim TimeCoin ke akun sendiri.');

        $wallets = DB::transaction(function () use ($sender, $recipient, $amountTc) {
            $senderWallet = TimeCoinWallet::firstOrCreate(['user_id' => $sender->id]);
            $recipientWallet = TimeCoinWallet::firstOrCreate(['user_id' => $recipient->id]);

            // Consistent lock ordering by wallet ID prevents InnoDB deadlocks under concurrency.
            $ids = [$senderWallet->id, $recipientWallet->id];
            sort($ids);
            $locked = TimeCoinWallet::whereIn('id', $ids)->orderBy('id')->lockForUpdate()->get()->keyBy('id');

            $lockedSender = $locked->get($senderWallet->id);
            $lockedRecipient = $locked->get($recipientWallet->id);
            abort_if(! $lockedSender || ! $lockedRecipient, 500, 'Dompet pengguna tidak ditemukan.');

            $this->ledger->transferBetweenUsers(
                $lockedSender,
                $lockedRecipient,
                $sender->id,
                $recipient->id,
                $amountTc,
                $sender,
            );

            return [
                'sender_balance_tc' => $lockedSender->fresh()->balance,
                'recipient_name' => $recipient->name,
                'amount_tc' => $amountTc,
            ];
        }, 3);

        $this->notifications->send(
            $recipient,
            'wallet_transfer_received',
            "+{$amountTc} TC Diterima",
            "{$sender->name} mengirimkan {$amountTc} TC ke dompet Anda.",
            '/wallet',
        );

        return $wallets;
    }

    public function redeemReward(User $student, Reward $reward): RewardRedemption
    {
        $redemption = DB::transaction(function () use ($student, $reward) {
            $lockedReward = Reward::query()->lockForUpdate()->findOrFail($reward->id);
            abort_unless($lockedReward->is_active, 409, 'Reward ini sudah tidak tersedia.');
            abort_if($lockedReward->stock < 1, 409, 'Stok reward sudah habis.');

            $wallet = TimeCoinWallet::firstOrCreate(['user_id' => $student->id]);
            $lockedWallet = TimeCoinWallet::whereKey($wallet->id)->lockForUpdate()->firstOrFail();
            abort_if($lockedWallet->balance < $lockedReward->tc_price, 422, 'Saldo TimeCoin tidak mencukupi.');

            $voucherCode = 'TS-RWD-'.strtoupper(Str::random(8));
            $redemption = RewardRedemption::create([
                'reward_id' => $lockedReward->id,
                'student_id' => $student->id,
                'paid_tc' => $lockedReward->tc_price,
                'voucher_code' => $voucherCode,
                'qr_payload' => "talentsync://voucher/{$voucherCode}?reward={$lockedReward->id}&student={$student->id}",
                'status' => 'active',
                'expires_at' => now()->addDays(30),
            ]);

            $lockedReward->decrement('stock');
            $this->ledger->redeemReward($lockedWallet, $student->id, $lockedReward->tc_price, $redemption);

            return $redemption->load('reward');
        }, 3);

        $this->notifications->send(
            $student,
            'reward_redeemed',
            'Voucher Reward Siap Digunakan',
            "Penukaran {$redemption->reward->title} berhasil. Kode voucher: {$redemption->voucher_code}",
            '/wallet/rewards',
        );

        return $redemption;
    }
}

