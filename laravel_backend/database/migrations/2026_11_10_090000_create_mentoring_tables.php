<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

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
        DB::table('roles')->insert(collect([
            ['student', 'Mahasiswa'],
            ['msme', 'Mitra UMKM'],
            ['mentor', 'Mentor'],
            ['admin', 'Administrator'],
        ])->map(fn (array $role) => [
            'name' => $role[0],
            'description' => $role[1],
            'created_at' => now(),
            'updated_at' => now(),
        ])->all());
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('role_id')->nullable()->constrained('roles')->restrictOnDelete();
        });
        $studentRoleId = DB::table('roles')->where('name', 'student')->value('id');
        DB::table('users')->whereNull('role_id')->update(['role_id' => $studentRoleId]);
        Schema::table('users', function (Blueprint $table) {
            $table->foreignId('role_id')->nullable(false)->change();
        });

        Schema::create('mentor_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->string('title_headline', 150)->nullable();
            $table->text('bio')->nullable();
            $table->unsignedInteger('hourly_rate_tc')->default(3);
            $table->boolean('is_premium')->default(false);
            $table->string('verification_status', 20)->default('pending')->index();
            $table->string('verification_document_url', 2048)->nullable();
            $table->string('portfolio_url', 2048)->nullable();
            $table->text('verification_rejection_reason')->nullable();
            $table->foreignId('verification_reviewed_by')->nullable()->constrained('users')->restrictOnDelete();
            $table->timestamp('verification_reviewed_at')->nullable();
            $table->timestamp('premium_expires_at')->nullable();
            $table->decimal('rating_average', 3, 2)->default(0);
            $table->timestamps();
        });

        Schema::create('mentor_premium_subscriptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('amount_idr')->default(50000);
            $table->string('payment_status', 20)->default('pending')->index();
            $table->string('payment_reference')->unique();
            $table->timestamp('starts_at')->nullable();
            $table->timestamp('expires_at')->nullable();
            $table->foreignId('processed_by')->nullable()->constrained('users')->restrictOnDelete();
            $table->timestamps();
        });

        Schema::create('time_coin_wallets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->restrictOnDelete();
            $table->unsignedInteger('balance')->default(0);
            $table->unsignedInteger('locked_balance')->default(0);
            $table->timestamps();
        });

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

        Schema::create('mentoring_enrollments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('mentoring_classes')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('paid_tc');
            $table->string('status', 30)->default('pending')->index();
            $table->boolean('has_endorsement')->default(false);
            $table->text('endorsement_notes')->nullable();
            $table->unsignedTinyInteger('assessment_score')->nullable();
            $table->text('mentor_feedback')->nullable();
            $table->timestamp('student_confirmed_at')->nullable();
            $table->timestamps();
            $table->unique(['class_id', 'student_id']);
        });

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

        Schema::create('cash_out_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->restrictOnDelete();
            $table->unsignedInteger('amount_tc');
            $table->unsignedInteger('admin_fee_idr');
            $table->unsignedBigInteger('disbursed_amount_idr');
            $table->string('bank_name', 100);
            $table->text('account_number');
            $table->text('account_holder_name');
            $table->string('status', 30)->default('pending_transfer')->index();
            $table->timestamps();
        });

        Schema::create('mentoring_messages', function (Blueprint $table) {
            $table->id();
            $table->foreignId('enrollment_id')->constrained('mentoring_enrollments')->restrictOnDelete();
            $table->foreignId('sender_id')->constrained('users')->restrictOnDelete();
            $table->text('message')->nullable();
            $table->string('attachment_url', 2048)->nullable();
            $table->timestamps();
            $table->index(['enrollment_id', 'created_at']);
        });

        Schema::create('mentoring_assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('class_id')->constrained('mentoring_classes')->restrictOnDelete();
            $table->foreignId('mentor_id')->constrained('users')->restrictOnDelete();
            $table->string('title', 200);
            $table->text('description')->nullable();
            $table->dateTime('due_at')->nullable();
            $table->timestamps();
        });

        Schema::create('mentoring_assignment_submissions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('assignment_id')->constrained('mentoring_assignments')->restrictOnDelete();
            $table->foreignId('student_id')->constrained('users')->restrictOnDelete();
            $table->text('submission_notes')->nullable();
            $table->string('deliverable_url', 2048)->nullable();
            $table->unsignedTinyInteger('score')->nullable();
            $table->text('feedback')->nullable();
            $table->string('status', 30)->default('submitted');
            $table->timestamps();
            $table->unique(['assignment_id', 'student_id']);
        });

        Schema::create('time_coin_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('wallet_id')->constrained('time_coin_wallets')->restrictOnDelete();
            $table->foreignId('sender_id')->nullable()->constrained('users')->restrictOnDelete();
            $table->foreignId('recipient_id')->constrained('users')->restrictOnDelete();
            $table->string('transaction_type', 50);
            $table->string('direction', 10);
            $table->string('ledger_account', 20);
            $table->unsignedInteger('amount');
            $table->string('reference_type', 100);
            $table->unsignedBigInteger('reference_id');
            $table->string('status', 20)->default('completed');
            $table->timestamp('created_at')->useCurrent();
            $table->index(['reference_type', 'reference_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('time_coin_transactions');
        Schema::dropIfExists('mentoring_assignment_submissions');
        Schema::dropIfExists('mentoring_assignments');
        Schema::dropIfExists('mentoring_messages');
        Schema::dropIfExists('cash_out_requests');
        Schema::dropIfExists('mentor_premium_subscriptions');
        Schema::dropIfExists('reviews');
        Schema::dropIfExists('mentoring_enrollments');
        Schema::dropIfExists('mentoring_classes');
        Schema::dropIfExists('time_coin_wallets');
        Schema::dropIfExists('mentor_profiles');
        Schema::table('users', function (Blueprint $table) {
            $table->dropConstrainedForeignId('role_id');
        });
        Schema::dropIfExists('roles');
    }
};
