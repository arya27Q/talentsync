<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('project_milestones', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained('projects')->cascadeOnDelete();
            $table->unsignedSmallInteger('step_order');
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->unsignedInteger('reward_tc');
            $table->string('status', 30)->default('locked')->index();
            $table->date('due_date')->nullable();
            $table->timestamps();
            $table->unique(['project_id', 'step_order']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('project_milestones');
    }
};

