<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('project_applications', function (Blueprint $table) {
            $table->string('linkedin_url', 2048)->nullable()->after('portfolio_link');
            $table->string('cv_url', 2048)->nullable()->after('linkedin_url');
            $table->string('cv_file_name', 255)->nullable()->after('cv_url');
            $table->string('github_url', 2048)->nullable()->after('cv_file_name');
            $table->foreignId('recommended_mentor_id')
                ->nullable()
                ->after('rejection_feedback')
                ->constrained('users')
                ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('project_applications', function (Blueprint $table) {
            $table->dropConstrainedForeignId('recommended_mentor_id');
            $table->dropColumn(['linkedin_url', 'cv_url', 'cv_file_name', 'github_url']);
        });
    }
};
