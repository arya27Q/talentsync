<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('project_deliverables', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            $table->foreignId('milestone_id')->nullable()->constrained('project_milestones')->nullOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->string('submission_format', 20)->default('link');
            $table->string('deliverable_url', 2048)->nullable();
            $table->string('file_path', 2048)->nullable();
            $table->string('file_name', 255)->nullable();
            $table->string('file_size_label', 40)->nullable();
            $table->text('submission_notes')->nullable();
            $table->json('attachment_links')->nullable();
            $table->unsignedSmallInteger('revision_count')->default(0);
            $table->text('revision_notes')->nullable();
            $table->boolean('recommend_mentor_consultation')->default(false);
            $table->string('status', 30)->default('submitted')->index();
            $table->timestamp('submitted_at')->useCurrent();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('project_deliverables');
    }
};

