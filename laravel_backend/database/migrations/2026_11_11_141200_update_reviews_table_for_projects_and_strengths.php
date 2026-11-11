<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->index('reviewer_id', 'reviews_reviewer_id_idx');
            $table->dropForeign(['mentoring_class_id']);
            $table->dropUnique(['reviewer_id', 'reviewee_id', 'mentoring_class_id']);
        });

        Schema::table('reviews', function (Blueprint $table) {
            $table->unsignedBigInteger('mentoring_class_id')->nullable()->change();
            $table->foreign('mentoring_class_id')
                ->references('id')
                ->on('mentoring_classes')
                ->restrictOnDelete();
            $table->foreignId('project_id')
                ->nullable()
                ->after('mentoring_class_id')
                ->constrained('projects')
                ->restrictOnDelete();
            $table->json('strength_tags')->nullable()->after('review_text');
            $table->unique(['reviewer_id', 'reviewee_id', 'mentoring_class_id'], 'reviews_mentoring_unique');
            $table->unique(['reviewer_id', 'reviewee_id', 'project_id'], 'reviews_project_unique');
        });
    }

    public function down(): void
    {
        Schema::table('reviews', function (Blueprint $table) {
            $table->dropUnique('reviews_mentoring_unique');
            $table->dropUnique('reviews_project_unique');
            $table->dropConstrainedForeignId('project_id');
            $table->dropColumn('strength_tags');
            $table->dropForeign(['mentoring_class_id']);
        });

        Schema::table('reviews', function (Blueprint $table) {
            $table->unsignedBigInteger('mentoring_class_id')->nullable(false)->change();
            $table->foreign('mentoring_class_id')
                ->references('id')
                ->on('mentoring_classes')
                ->restrictOnDelete();
            $table->unique(['reviewer_id', 'reviewee_id', 'mentoring_class_id']);
            $table->dropIndex('reviews_reviewer_id_idx');
        });
    }
};

