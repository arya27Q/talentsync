<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentor_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->string('title_headline', 150)->nullable();
            $table->text('bio')->nullable();
            $table->unsignedInteger('hourly_rate_tc')->default(3);
            $table->boolean('is_premium')->default(false);
            $table->string('verification_status', 20)->default('pending')->index();
            $table->string('verification_document_url', 2048)->nullable();
            $table->string('portfolio_url', 2048)->nullable();
            $table->text('verification_rejection_reason')->nullable();
            $table->foreignId('verification_reviewed_by')->nullable()->constrained('users')->restrictOnDelete();
            $table->timestamp('verification_reviewed_at')->nullable();
            $table->timestamp('premium_expires_at')->nullable();
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentor_profiles');
    }
};
