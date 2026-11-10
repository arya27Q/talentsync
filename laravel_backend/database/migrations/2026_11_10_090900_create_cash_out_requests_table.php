<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('cash_out_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->restrictOnDelete();
            $table->unsignedInteger('amount_tc');
            $table->unsignedInteger('admin_fee_idr');
            $table->unsignedBigInteger('disbursed_amount_idr');
            $table->string('bank_name', 100);
            $table->text('account_number');
            $table->text('account_holder_name');
            $table->string('status', 30)->default('pending_transfer')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cash_out_requests');
    }
};
