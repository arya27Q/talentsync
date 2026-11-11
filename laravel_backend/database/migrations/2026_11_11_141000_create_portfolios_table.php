<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('portfolios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('project_id')->nullable()->constrained('projects')->nullOnDelete();
            $table->string('title', 200);
            $table->string('category', 100);
            $table->string('client_name', 150)->nullable();
            $table->string('role_title', 150)->nullable();
            $table->string('duration_label', 60)->nullable();
            $table->unsignedInteger('reward_tc')->default(0);
            $table->decimal('rating', 3, 2)->default(5.00);
            $table->json('tags')->nullable();
            $table->text('problem_summary')->nullable();
            $table->text('solution_summary')->nullable();
            $table->text('result_summary')->nullable();
            $table->json('deliverable_highlights')->nullable();
            $table->text('testimonial_quote')->nullable();
            $table->string('testimonial_author', 150)->nullable();
            $table->string('preview_image_url', 2048)->nullable();
            $table->string('case_study_url', 2048)->nullable();
            $table->boolean('is_verified')->default(true)->index();
            $table->boolean('is_featured')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('portfolios');
    }
};

