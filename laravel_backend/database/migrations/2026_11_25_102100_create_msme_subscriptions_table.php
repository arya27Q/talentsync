<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('msme_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('plan_type', 30); // monthly, yearly
            $table->unsignedBigInteger('price_idr');
            $table->string('payment_channel', 60)->default('qris_sandbox');
            $table->string('payment_reference', 80)->unique();
            $table->string('status', 30)->default('active')->index();
            $table->timestamp('starts_at');
            $table->timestamp('expires_at');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('msme_subscriptions');
    }
};
