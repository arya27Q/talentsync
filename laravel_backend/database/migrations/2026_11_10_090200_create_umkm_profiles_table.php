<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('umkm_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->string('business_name', 150);
            $table->string('business_sector', 100);
            $table->text('address');
            $table->string('business_document_url', 2048)->nullable();
            $table->boolean('is_premium')->default(false);
            $table->unsignedInteger('monthly_quota_tc')->default(20);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('umkm_profiles');
    }
};
