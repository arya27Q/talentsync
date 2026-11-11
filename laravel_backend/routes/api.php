<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AdminMentorPremiumController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DisputeController;
use App\Http\Controllers\Api\InboxController;
use App\Http\Controllers\Api\MentorCatalogController;
use App\Http\Controllers\Api\MentorDashboardController;
use App\Http\Controllers\Api\MentoringAssignmentController;
use App\Http\Controllers\Api\MentoringClassController;
use App\Http\Controllers\Api\MentoringEnrollmentController;
use App\Http\Controllers\Api\MentoringMessageController;
use App\Http\Controllers\Api\MentorPremiumSubscriptionController;
use App\Http\Controllers\Api\MentorProfileController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\Student\PortfolioController;
use App\Http\Controllers\Api\Student\ProjectController;
use App\Http\Controllers\Api\Student\StudentDashboardController;
use App\Http\Controllers\Api\Student\StudentProfileController;
use App\Http\Controllers\Api\Student\StudentProjectController;
use App\Http\Controllers\Api\Student\WorkspaceMessageController;
use App\Http\Controllers\Api\Student\WorkspaceTaskController;
use App\Http\Controllers\Api\WalletController;

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
    Route::post('/register-mentor', [AuthController::class, 'registerMentor'])->middleware('throttle:5,1');

    Route::middleware('auth:sanctum')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
        Route::post('/switch-role', [AuthController::class, 'switchRole']);
        Route::get('/sessions', [AuthController::class, 'sessions']);
        Route::delete('/sessions/others', [AuthController::class, 'revokeOtherSessions']);
    });
});

Route::middleware(['auth:sanctum', 'role:student'])->prefix('student')->group(function () {
    Route::get('/dashboard', [StudentDashboardController::class, 'index']);
    Route::get('/profile', [StudentProfileController::class, 'show']);
    Route::match(['put', 'post'], '/profile', [StudentProfileController::class, 'update']);
    Route::get('/settings/privacy', [StudentProfileController::class, 'privacy']);
    Route::patch('/settings/privacy', [StudentProfileController::class, 'updatePrivacy']);
    Route::put('/security/pin', [StudentProfileController::class, 'updatePin']);
    Route::post('/skills/{skill}/verify', [StudentProfileController::class, 'verifySkill']);
    Route::post('/portfolio/github/sync', [StudentProfileController::class, 'githubSync']);
    Route::delete('/portfolio/github', [StudentProfileController::class, 'githubDisconnect']);
    Route::get('/mentor-eligibility', [StudentProfileController::class, 'mentorEligibility']);
    Route::post('/switch-to-mentor', [StudentProfileController::class, 'switchToMentor']);
    Route::delete('/account', [StudentProfileController::class, 'destroyAccount']);
    Route::get('/projects', [StudentProjectController::class, 'index']);
    Route::get('/portfolio', [PortfolioController::class, 'index']);
    Route::get('/certificates', [PortfolioController::class, 'certificates']);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/projects', [ProjectController::class, 'index']);
    Route::get('/projects/{project}', [ProjectController::class, 'show']);
    Route::post('/projects/{project}/bookmark', [ProjectController::class, 'toggleBookmark'])
        ->middleware('role:student');
    Route::get('/projects/{project}/apply-context', [ProjectController::class, 'applyContext'])
        ->middleware('role:student');
    Route::post('/projects/{project}/apply', [ProjectController::class, 'apply'])
        ->middleware('role:student');

    Route::get('/projects/{project}/milestones', [StudentProjectController::class, 'milestones'])
        ->middleware('role:student');
    Route::post('/projects/{project}/milestones', [StudentProjectController::class, 'addMilestone'])
        ->middleware('role:student');
    Route::post('/milestones/{milestone}/submissions', [StudentProjectController::class, 'submitDeliverable'])
        ->middleware('role:student');
    Route::get('/projects/{project}/completion-summary', [StudentProjectController::class, 'completionSummary'])
        ->middleware('role:student');
    Route::post('/projects/{project}/review-client', [StudentProjectController::class, 'reviewClient'])
        ->middleware('role:student');

    Route::get('/projects/{project}/tasks', [WorkspaceTaskController::class, 'index'])
        ->middleware('role:student');
    Route::post('/projects/{project}/tasks', [WorkspaceTaskController::class, 'store'])
        ->middleware('role:student');
    Route::patch('/tasks/{task}', [WorkspaceTaskController::class, 'update'])
        ->middleware('role:student');
    Route::delete('/tasks/{task}', [WorkspaceTaskController::class, 'destroy'])
        ->middleware('role:student');

    Route::get('/projects/{project}/messages', [WorkspaceMessageController::class, 'index'])
        ->middleware('role:student|msme');
    Route::post('/projects/{project}/messages', [WorkspaceMessageController::class, 'store'])
        ->middleware('role:student|msme');

    Route::get('/portfolio/case-studies/{portfolio}', [PortfolioController::class, 'caseStudy']);

    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::patch('/notifications/{id}/read', [NotificationController::class, 'markRead']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllRead']);

    Route::get('/inbox', [InboxController::class, 'index'])->middleware('role:student');
    Route::post('/disputes', [DisputeController::class, 'store']);
});

Route::middleware('auth:sanctum')->prefix('mentoring')->group(function () {
    Route::get('/mentors', [MentorCatalogController::class, 'mentors']);
    Route::get('/mentors/{mentor}', [MentorCatalogController::class, 'showMentor']);
    Route::post('/mentors/{mentor}/bookmark', [MentorCatalogController::class, 'toggleMentorBookmark'])
        ->middleware('role:student');
    Route::get('/classes', [MentorCatalogController::class, 'classes']);
    Route::get('/classes/{mentoringClass}', [MentorCatalogController::class, 'showClass']);
    Route::post('/classes/{mentoringClass}/book', [MentoringEnrollmentController::class, 'book'])
        ->middleware('role:student');

    Route::get('/student/mentors', [MentoringEnrollmentController::class, 'studentMentors'])
        ->middleware('role:student');
    Route::get('/enrollments/mine', [MentoringEnrollmentController::class, 'studentIndex'])
        ->middleware('role:student');
    Route::get('/enrollments/{enrollment}', [MentoringEnrollmentController::class, 'show'])
        ->middleware('role:student|mentor');
    Route::get('/enrollments/{enrollment}/materials', [MentoringEnrollmentController::class, 'materials']);
    Route::patch('/enrollments/{enrollment}/action-items/{item}', [MentoringEnrollmentController::class, 'toggleActionItem'])
        ->middleware('role:student');
    Route::patch('/enrollments/{enrollment}/attendance', [MentoringEnrollmentController::class, 'attendance'])
        ->middleware('role:mentor');
    Route::patch('/enrollments/{enrollment}/decision', [MentoringEnrollmentController::class, 'decide'])
        ->middleware('role:mentor');
    Route::post('/enrollments/{enrollment}/assessment', [MentoringEnrollmentController::class, 'assess'])
        ->middleware('role:mentor');
    Route::post('/enrollments/{enrollment}/endorse', [MentoringEnrollmentController::class, 'endorse'])
        ->middleware('role:mentor');
    Route::post('/enrollments/{enrollment}/confirm-completion', [MentoringEnrollmentController::class, 'confirmCompletion'])
        ->middleware('role:student');
    Route::get('/enrollments/{enrollment}/messages', [MentoringMessageController::class, 'index']);
    Route::post('/enrollments/{enrollment}/messages', [MentoringMessageController::class, 'store']);
    Route::get('/enrollments/{enrollment}/assignments', [MentoringAssignmentController::class, 'index']);
    Route::post('/assignments/{assignment}/submissions', [MentoringAssignmentController::class, 'submit'])
        ->middleware('role:student');
    Route::patch('/submissions/{submission}/review', [MentoringAssignmentController::class, 'review'])
        ->middleware('role:mentor');

    Route::middleware('role:mentor')->prefix('mentor')->group(function () {
        Route::get('/profile', [MentorProfileController::class, 'show']);
        Route::match(['put', 'post'], '/profile', [MentorProfileController::class, 'update']);
        Route::delete('/account', [MentorProfileController::class, 'destroyAccount']);
        Route::get('/dashboard', [MentorDashboardController::class, 'index']);
        Route::get('/classes', [MentoringClassController::class, 'index']);
        Route::post('/classes', [MentoringClassController::class, 'store']);
        Route::post('/classes/{mentoringClass}/assignments', [MentoringAssignmentController::class, 'store']);
        Route::post('/classes/{mentoringClass}/materials', [MentoringEnrollmentController::class, 'storeMaterial']);
        Route::put('/classes/{mentoringClass}', [MentoringClassController::class, 'update']);
        Route::delete('/classes/{mentoringClass}', [MentoringClassController::class, 'destroy']);
        Route::get('/enrollments', [MentoringEnrollmentController::class, 'mentorIndex']);
        Route::post('/premium-subscriptions', [MentorPremiumSubscriptionController::class, 'store']);
        Route::get('/premium-subscriptions', [MentorPremiumSubscriptionController::class, 'index']);
    });
});

Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/mentor-premium-subscriptions/pending', [AdminMentorPremiumController::class, 'pending']);
    Route::patch('/mentor-premium-subscriptions/{subscription}', [AdminMentorPremiumController::class, 'resolve']);
    Route::get('/cash-outs/pending', [WalletController::class, 'pendingCashOuts']);
});

Route::middleware('auth:sanctum')->prefix('wallet')->group(function () {
    Route::get('/summary', [WalletController::class, 'summary']);
    Route::get('/transactions', [WalletController::class, 'transactions']);
    Route::post('/top-up', [WalletController::class, 'topUp']);
    Route::get('/recipients', [WalletController::class, 'recipients']);
    Route::post('/transfer', [WalletController::class, 'transfer']);
    Route::get('/bank-accounts', [WalletController::class, 'bankAccounts']);
    Route::post('/bank-accounts', [WalletController::class, 'storeBankAccount']);
    Route::get('/rewards', [WalletController::class, 'rewards']);
    Route::post('/rewards/{reward}/redeem', [WalletController::class, 'redeemReward']);
    Route::post('/cash-out', [WalletController::class, 'requestCashOut'])
        ->middleware('role:student|mentor');
    Route::get('/cash-outs', [WalletController::class, 'cashOutHistory'])
        ->middleware('role:student|mentor');
    Route::patch('/cash-outs/{cashOutRequest}', [WalletController::class, 'resolveCashOut'])
        ->middleware('role:admin');
});
