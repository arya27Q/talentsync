<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('mentoring_classes')->restrictOnDelete();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->dateTime('due_at')->nullable();
            $table->timestamps();
        });

    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_assignments');
    }
};
