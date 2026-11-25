<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mentoring_classes', function (Blueprint $table) {
            $table->string('duration_label', 80)->nullable()->after('duration_minutes');
            $table->unsignedSmallInteger('duration_days')->nullable()->after('duration_label');
        });

        DB::table('mentoring_classes')
            ->whereNull('duration_label')
            ->update([
                'duration_label' => '7 Hari',
                'duration_days' => 7,
            ]);
    }

    public function down(): void
    {
        Schema::table('mentoring_classes', function (Blueprint $table) {
            $table->dropColumn(['duration_label', 'duration_days']);
        });
    }
};
