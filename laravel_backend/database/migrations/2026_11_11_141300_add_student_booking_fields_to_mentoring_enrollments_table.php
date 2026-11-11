<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mentoring_enrollments', function (Blueprint $table) {
            $table->string('topic_focus', 200)->nullable()->after('paid_tc');
            $table->text('student_notes')->nullable()->after('topic_focus');
            $table->string('materials_url', 2048)->nullable()->after('student_notes');
            $table->json('rubric_scores')->nullable()->after('mentor_feedback');
            $table->timestamp('evaluated_at')->nullable()->after('rubric_scores');
        });
    }

    public function down(): void
    {
        Schema::table('mentoring_enrollments', function (Blueprint $table) {
            $table->dropColumn([
                'topic_focus',
                'student_notes',
                'materials_url',
                'rubric_scores',
                'evaluated_at',
            ]);
        });
    }
};

