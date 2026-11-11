<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('project_applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->text('cover_letter');
            $table->json('portfolio_ids')->nullable();
            $table->string('portfolio_link', 2048)->nullable();
            $table->boolean('has_mentor_endorsement_snapshot')->default(false);
            $table->string('timeline_commitment', 60)->default('2 Minggu');
            $table->string('dedication_hours', 60)->nullable();
            $table->string('status', 40)->default('pending')->index();
            $table->text('rejection_feedback')->nullable();
            $table->timestamp('reviewed_at')->nullable();
            $table->timestamp('applied_at')->useCurrent();
            $table->timestamps();
            $table->unique(['project_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('project_applications');
    }
};

