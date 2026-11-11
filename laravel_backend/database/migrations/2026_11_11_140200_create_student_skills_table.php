<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('student_skills', function (Blueprint $table) {
            $table->id();
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->string('name', 80);
            $table->string('proficiency_level', 30)->default('Menengah');
            $table->unsignedTinyInteger('score')->default(75);
            $table->boolean('is_verified')->default(false);
            $table->string('verified_source', 50)->nullable();
            $table->timestamp('verified_at')->nullable();
            $table->timestamps();
            $table->unique(['student_id', 'name']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('student_skills');
    }
};

