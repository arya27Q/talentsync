<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rewards', function (Blueprint $table) {
            $table->id();
            $table->string('title', 150);
            $table->string('provider', 120);
            $table->text('description')->nullable();
            $table->unsignedInteger('tc_price');
            $table->string('icon_key', 60)->default('card_giftcard');
            $table->unsignedInteger('stock')->default(100);
            $table->boolean('is_active')->default(true)->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rewards');
    }
};

