<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('escrow_disputes', function (Blueprint $table) {
            $table->text('resolution_notes')->nullable()->after('status');
            $table->foreignId('resolved_by')->nullable()->after('resolution_notes')->constrained('users')->nullOnDelete();
            $table->timestamp('resolved_at')->nullable()->after('resolved_by');
        });
    }

    public function down(): void
    {
        Schema::table('escrow_disputes', function (Blueprint $table) {
            $table->dropConstrainedForeignId('resolved_by');
            $table->dropColumn(['resolution_notes', 'resolved_at']);
        });
    }
};
