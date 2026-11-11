<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('umkm_profiles', function (Blueprint $table) {
            $table->string('logo_url', 2048)->nullable()->after('business_sector');
            $table->string('district', 100)->nullable()->after('address');
            $table->string('city', 100)->default('Surabaya')->after('district');
            $table->boolean('is_verified')->default(true)->after('is_premium');
        });
    }

    public function down(): void
    {
        Schema::table('umkm_profiles', function (Blueprint $table) {
            $table->dropColumn(['logo_url', 'district', 'city', 'is_verified']);
        });
    }
};

