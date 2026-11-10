<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_assignment_submissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained('mentoring_assignments')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->text('submission_notes')->nullable();
            $table->string('deliverable_url', 2048)->nullable();
            $table->unsignedTinyInteger('score')->nullable();
            $table->text('feedback')->nullable();
            $table->string('status', 30)->default('submitted');
            $table->timestamps();
            $table->unique(['assignment_id', 'student_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_assignment_submissions');
    }
};
