<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_action_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained('mentoring_enrollments')->cascadeOnDelete();
            $table->string('title', 200);
            $table->string('tag', 60)->default('Wajib');
            $table->text('detail')->nullable();
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_action_items');
    }
};

