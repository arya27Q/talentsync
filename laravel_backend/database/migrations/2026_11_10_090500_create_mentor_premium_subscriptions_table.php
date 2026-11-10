<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentor_premium_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('amount_idr')->default(50000);
            $table->string('payment_status', 20)->default('pending')->index();
            $table->string('payment_reference')->unique();
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->foreignId('processed_by')->nullable()->constrained('users')->restrictOnDelete();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentor_premium_subscriptions');
    }
};
