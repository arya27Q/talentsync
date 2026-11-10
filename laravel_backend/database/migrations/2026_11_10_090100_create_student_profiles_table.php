<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('student_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->string('university', 150);
            $table->string('major', 100);
            $table->string('student_id_number', 50)->unique();
            $table->string('ktm_document_url', 2048)->nullable();
            $table->boolean('is_mentor_eligible')->default(false);
            $table->unsignedInteger('completed_projects_count')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_profiles');
    }
};
