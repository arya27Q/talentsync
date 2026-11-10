<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('time_coin_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained('time_coin_wallets')->restrictOnDelete();
            $table->foreignId('sender_id')->nullable()->constrained('users')->restrictOnDelete();
            $table->foreignId('recipient_id')->constrained('users')->restrictOnDelete();
            $table->string('transaction_type', 50);
            $table->string('direction', 10);
            $table->string('ledger_account', 20);
            $table->unsignedInteger('amount');
            $table->string('reference_type', 100);
            $table->unsignedBigInteger('reference_id');
            $table->string('status', 20)->default('completed');
            $table->timestamp('created_at')->useCurrent();
            $table->index(['reference_type', 'reference_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('time_coin_transactions');
    }
};
