<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('projects', function (Blueprint $table) {
            $table->id();
            $table->foreignId('msme_id')->constrained('users')->restrictOnDelete();
            $table->string('code', 30)->unique();
            $table->string('title', 200);
            $table->string('division', 120)->nullable();
            $table->string('category', 100)->index();
            $table->text('description');
            $table->json('deliverables_checklist')->nullable();
            $table->unsignedInteger('reward_tc');
            $table->date('deadline')->index();
            $table->string('duration_label', 60)->default('2 Minggu');
            $table->string('work_mode', 30)->default('Hybrid');
            $table->string('location_label', 120)->nullable();
            $table->json('skills')->nullable();
            $table->string('benefit_badge', 120)->default('Sertifikat & Portofolio');
            $table->boolean('requires_endorsement')->default(false)->index();
            $table->string('atmosphere_photo_url', 2048)->nullable();
            $table->string('atmosphere_caption', 200)->nullable();
            $table->string('status', 30)->default('open')->index();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('projects');
    }
};

