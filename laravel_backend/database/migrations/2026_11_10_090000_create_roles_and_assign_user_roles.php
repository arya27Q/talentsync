<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name', 50)->unique();
            $table->string('description')->nullable();
            $table->timestamps();
        });

        $now = now();
        DB::table('roles')->insert([
            ['name' => 'student', 'description' => 'Mahasiswa', 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'msme', 'description' => 'Mitra UMKM', 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'mentor', 'description' => 'Mentor', 'created_at' => $now, 'updated_at' => $now],
            ['name' => 'admin', 'description' => 'Administrator', 'created_at' => $now, 'updated_at' => $now],
        ]);

        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('role_id')->nullable()->constrained('roles')->restrictOnDelete();
        });

        $studentRoleId = DB::table('roles')->where('name', 'student')->value('id');
        DB::table('users')->whereNull('role_id')->update(['role_id' => $studentRoleId]);

        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('role_id')->nullable(false)->change();
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('role_id');
        });
        Schema::dropIfExists('roles');
    }
};
