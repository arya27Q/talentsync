<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('wallet_top_ups', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('amount_tc');
            $table->unsignedBigInteger('amount_idr');
            $table->string('payment_channel', 60)->default('qris_sandbox');
            $table->string('payment_reference', 80)->unique();
            $table->string('status', 30)->default('completed')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('wallet_top_ups');
    }
};

