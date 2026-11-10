<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('mentoring_classes')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('paid_tc');
            $table->string('status', 30)->default('pending')->index();
            $table->boolean('has_endorsement')->default(false);
            $table->text('endorsement_notes')->nullable();
            $table->unsignedTinyInteger('assessment_score')->nullable();
            $table->text('mentor_feedback')->nullable();
            $table->timestamp('student_confirmed_at')->nullable();
            $table->timestamps();
            $table->unique(['class_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_enrollments');
    }
};
