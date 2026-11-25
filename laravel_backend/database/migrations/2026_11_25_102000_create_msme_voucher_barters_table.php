<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('msme_voucher_barters', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('reward_id')->nullable()->constrained('rewards')->nullOnDelete();
            $table->string('voucher_type', 40)->default('free_product');
            $table->string('title', 150);
            $table->unsignedInteger('quantity');
            $table->unsignedInteger('value_idr');
            $table->unsignedInteger('tc_per_voucher');
            $table->unsignedInteger('total_tc');
            $table->unsignedSmallInteger('validity_days')->default(60);
            $table->timestamp('expires_at')->nullable();
            $table->string('design_image_url', 2048)->nullable();
            $table->boolean('is_guaranteed')->default(true);
            $table->string('status', 30)->default('active')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('msme_voucher_barters');
    }
};
