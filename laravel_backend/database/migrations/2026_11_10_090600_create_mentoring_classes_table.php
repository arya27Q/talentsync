<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_classes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->string('topic', 200);
            $table->text('description')->nullable();
            $table->dateTime('scheduled_time')->index();
            $table->unsignedSmallInteger('duration_minutes')->default(60);
            $table->unsignedInteger('price_tc');
            $table->string('meeting_link')->nullable();
            $table->unsignedSmallInteger('capacity')->default(1);
            $table->string('status', 20)->default('open')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_classes');
    }
};
