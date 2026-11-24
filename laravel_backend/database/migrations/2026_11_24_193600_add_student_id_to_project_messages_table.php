<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('project_messages', function (Blueprint $table) {
            $table->foreignId('student_id')
                ->nullable()
                ->after('project_id')
                ->constrained('users')
                ->nullOnDelete();
            $table->index(['project_id', 'student_id', 'created_at'], 'project_messages_thread_idx');
        });

        // Backfill student_id for existing project_messages rows
        $projects = DB::table('projects')->select('id', 'msme_id')->get()->keyBy('id');
        $messages = DB::table('project_messages')->select('id', 'project_id', 'sender_id')->get();
        foreach ($messages as $msg) {
            $project = $projects->get($msg->project_id);
            if (! $project) {
                continue;
            }
            if ((int) $msg->sender_id !== (int) $project->msme_id) {
                DB::table('project_messages')
                    ->where('id', $msg->id)
                    ->update(['student_id' => $msg->sender_id]);
            } else {
                $acceptedStudentId = DB::table('project_applications')
                    ->where('project_id', $msg->project_id)
                    ->where('status', 'accepted')
                    ->value('student_id');
                $fallbackStudentId = $acceptedStudentId ?? DB::table('project_messages')
                    ->where('project_id', $msg->project_id)
                    ->where('sender_id', '!=', $project->msme_id)
                    ->orderBy('id')
                    ->value('sender_id');
                if ($fallbackStudentId) {
                    DB::table('project_messages')
                        ->where('id', $msg->id)
                        ->update(['student_id' => $fallbackStudentId]);
                }
            }
        }
    }

    public function down(): void
    {
        Schema::table('project_messages', function (Blueprint $table) {
            $table->dropIndex('project_messages_thread_idx');
            $table->dropConstrainedForeignId('student_id');
        });
    }
};
