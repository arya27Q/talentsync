<?php

namespace App\Services;

use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use Illuminate\Database\Eloquent\Model;

class TimeCoinLedgerService
{
    public function holdForMentoring(TimeCoinWallet $wallet, int $studentId, int $mentorId, int $amount, Model $reference): void
    {
        $wallet->decrement('balance', $amount);
        $wallet->increment('locked_balance', $amount);
        $this->record($wallet, $studentId, $mentorId, 'mentoring_payment', 'debit', 'balance', $amount, $reference);
        $this->record($wallet, $studentId, $mentorId, 'mentoring_payment', 'escrow_credit', 'locked_balance', $amount, $reference);
    }

    public function refundMentoringEscrow(TimeCoinWallet $wallet, int $mentorId, int $studentId, int $amount, Model $reference): void
    {
        $this->assertEscrowBalance($wallet, $amount);
        $wallet->decrement('locked_balance', $amount);
        $wallet->increment('balance', $amount);
        $this->record($wallet, $mentorId, $studentId, 'mentoring_refund', 'escrow_debit', 'locked_balance', $amount, $reference);
        $this->record($wallet, $mentorId, $studentId, 'mentoring_refund', 'credit', 'balance', $amount, $reference);
    }

    public function releaseMentoringEscrow(
        TimeCoinWallet $studentWallet,
        TimeCoinWallet $mentorWallet,
        int $studentId,
        int $mentorId,
        int $amount,
        Model $reference,
    ): void {
        $this->assertEscrowBalance($studentWallet, $amount);
        $studentWallet->decrement('locked_balance', $amount);
        $mentorWallet->increment('balance', $amount);
        $this->record($studentWallet, $studentId, $mentorId, 'mentoring_payment', 'escrow_debit', 'locked_balance', $amount, $reference);
        $this->record($mentorWallet, $studentId, $mentorId, 'mentoring_payment', 'credit', 'balance', $amount, $reference);
    }

    public function recordTopUp(TimeCoinWallet $wallet, int $userId, int $amount, Model $reference): void
    {
        $wallet->increment('balance', $amount);
        $this->record($wallet, null, $userId, 'top_up', 'credit', 'balance', $amount, $reference);
    }

    public function transferBetweenUsers(
        TimeCoinWallet $senderWallet,
        TimeCoinWallet $recipientWallet,
        int $senderId,
        int $recipientId,
        int $amount,
        Model $reference,
    ): void {
        abort_if($senderWallet->balance < $amount, 422, 'Saldo TimeCoin tidak mencukupi untuk transfer.');
        $senderWallet->decrement('balance', $amount);
        $recipientWallet->increment('balance', $amount);
        $this->record($senderWallet, $senderId, $recipientId, 'p2p_transfer', 'debit', 'balance', $amount, $reference);
        $this->record($recipientWallet, $senderId, $recipientId, 'p2p_transfer', 'credit', 'balance', $amount, $reference);
    }

    public function redeemReward(TimeCoinWallet $wallet, int $studentId, int $amount, Model $reference): void
    {
        abort_if($wallet->balance < $amount, 422, 'Saldo TimeCoin tidak mencukupi untuk menukar reward.');
        $wallet->decrement('balance', $amount);
        $this->record($wallet, $studentId, $studentId, 'voucher_redeem', 'debit', 'balance', $amount, $reference);
    }

    private function assertEscrowBalance(TimeCoinWallet $wallet, int $amount): void
    {
        abort_if($wallet->locked_balance < $amount, 409, 'Saldo escrow tidak sesuai dengan booking.');
    }

    private function record(
        TimeCoinWallet $wallet,
        ?int $senderId,
        int $recipientId,
        string $type,
        string $direction,
        string $account,
        int $amount,
        Model $reference,
    ): void {
        TimeCoinTransaction::create([
            'wallet_id' => $wallet->id,
            'sender_id' => $senderId,
            'recipient_id' => $recipientId,
            'transaction_type' => $type,
            'direction' => $direction,
            'ledger_account' => $account,
            'amount' => $amount,
            'reference_type' => $reference::class,
            'reference_id' => $reference->getKey(),
            'status' => 'completed',
        ]);
    }
}
