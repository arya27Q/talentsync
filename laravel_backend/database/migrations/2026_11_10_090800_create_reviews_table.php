<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('reviews', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reviewer_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('reviewee_id')->constrained('users')->restrictOnDelete();
            $table->foreignId('mentoring_class_id')->constrained('mentoring_classes')->restrictOnDelete();
            $table->unsignedTinyInteger('rating');
            $table->text('review_text')->nullable();
            $table->timestamps();
            $table->unique(['reviewer_id', 'reviewee_id', 'mentoring_class_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
