<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mentoring_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained('mentoring_enrollments')->restrictOnDelete();
            $table->foreignId('sender_id')->constrained('users')->restrictOnDelete();
            $table->text('message')->nullable();
            $table->string('attachment_url', 2048)->nullable();
            $table->timestamps();
            $table->index(['enrollment_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mentoring_messages');
    }
};
