<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_materials', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('mentoring_classes')->cascadeOnDelete();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->string('kind', 30)->default('pdf');
            $table->string('meta_label', 80)->nullable();
            $table->string('resource_url', 2048);
            $table->boolean('is_new')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_materials');
    }
};

