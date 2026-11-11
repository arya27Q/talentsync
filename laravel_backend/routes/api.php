<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\AdminMentorPremiumController;
use App\Http\Controllers\Api\MentorCatalogController;
use App\Http\Controllers\Api\MentorProfileController;
use App\Http\Controllers\Api\MentorDashboardController;
use App\Http\Controllers\Api\MentorPremiumSubscriptionController;
use App\Http\Controllers\Api\MentoringAssignmentController;
use App\Http\Controllers\Api\MentoringClassController;
use App\Http\Controllers\Api\MentoringEnrollmentController;
use App\Http\Controllers\Api\MentoringMessageController;
use App\Http\Controllers\Api\WalletController;

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
    Route::post('/register', [AuthController::class, 'register'])->middleware('throttle:5,1');
    Route::post('/register-mentor', [AuthController::class, 'registerMentor'])->middleware('throttle:5,1');
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
});

Route::middleware('auth:sanctum')->prefix('mentoring')->group(function () {
    Route::get('/mentors', [MentorCatalogController::class, 'mentors']);
    Route::get('/classes', [MentorCatalogController::class, 'classes']);
    Route::get('/classes/{mentoringClass}', [MentorCatalogController::class, 'showClass']);
    Route::post('/classes/{mentoringClass}/book', [MentoringEnrollmentController::class, 'book'])
        ->middleware('role:student');
    Route::get('/enrollments/mine', [MentoringEnrollmentController::class, 'studentIndex'])
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
    Route::post('/cash-out', [WalletController::class, 'requestCashOut'])
        ->middleware('role:student|mentor');
    Route::get('/cash-outs', [WalletController::class, 'cashOutHistory'])
        ->middleware('role:student|mentor');
    Route::patch('/cash-outs/{cashOutRequest}', [WalletController::class, 'resolveCashOut'])
        ->middleware('role:admin');
});
