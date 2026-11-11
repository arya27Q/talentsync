<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('student_profiles', function (Blueprint $table) {
            $table->string('avatar_url', 2048)->nullable()->after('ktm_document_url');
            $table->string('headline', 150)->nullable()->after('avatar_url');
            $table->text('bio')->nullable()->after('headline');
            $table->string('cohort_year', 20)->nullable()->after('bio');
            $table->unsignedTinyInteger('semester')->nullable()->after('cohort_year');
            $table->string('ktm_verification_status', 20)->default('approved')->after('ktm_document_url');
            $table->string('linkedin_url', 255)->nullable()->after('semester');
            $table->string('github_username', 100)->nullable()->after('linkedin_url');
            $table->timestamp('github_connected_at')->nullable()->after('github_username');
            $table->unsignedInteger('github_repos_count')->default(0)->after('github_connected_at');
            $table->unsignedInteger('github_commits_count')->default(0)->after('github_repos_count');
            $table->unsignedInteger('github_pinned_count')->default(0)->after('github_commits_count');
            $table->json('github_languages')->nullable()->after('github_pinned_count');
            $table->timestamp('github_last_synced_at')->nullable()->after('github_languages');
            $table->boolean('is_public_profile')->default(true)->after('github_last_synced_at');
            $table->boolean('is_open_for_projects')->default(true)->after('is_public_profile');
            $table->boolean('two_factor_enabled')->default(false)->after('is_open_for_projects');
            $table->boolean('show_online_status')->default(true)->after('two_factor_enabled');
            $table->boolean('show_endorse_badge')->default(true)->after('show_online_status');
            $table->string('transaction_pin_hash')->nullable()->after('show_endorse_badge');
            $table->timestamp('pin_updated_at')->nullable()->after('transaction_pin_hash');
            $table->unsignedInteger('total_contribution_hours')->default(0)->after('completed_projects_count');
            $table->decimal('rating_average', 3, 2)->default(0)->after('total_contribution_hours');
        });
    }

    public function down(): void
    {
        Schema::table('student_profiles', function (Blueprint $table) {
            $table->dropColumn([
                'avatar_url',
                'headline',
                'bio',
                'cohort_year',
                'semester',
                'ktm_verification_status',
                'linkedin_url',
                'github_username',
                'github_connected_at',
                'github_repos_count',
                'github_commits_count',
                'github_pinned_count',
                'github_languages',
                'github_last_synced_at',
                'is_public_profile',
                'is_open_for_projects',
                'two_factor_enabled',
                'show_online_status',
                'show_endorse_badge',
                'transaction_pin_hash',
                'pin_updated_at',
                'total_contribution_hours',
                'rating_average',
            ]);
        });
    }
};

