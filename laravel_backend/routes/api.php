<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\MentoringController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\WalletController;

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:5,1');
    Route::post('/register-mentor', [AuthController::class, 'registerMentor'])->middleware('throttle:5,1');
    Route::post('/logout', [AuthController::class, 'logout'])->middleware('auth:sanctum');
});

Route::middleware('auth:sanctum')->prefix('mentoring')->group(function () {
    Route::get('/mentors', [MentoringController::class, 'mentors']);
    Route::get('/classes', [MentoringController::class, 'classes']);
    Route::get('/classes/{mentoringClass}', [MentoringController::class, 'showClass']);
    Route::post('/classes/{mentoringClass}/book', [MentoringController::class, 'book'])
        ->middleware('role:student');
    Route::get('/enrollments/mine', [MentoringController::class, 'myEnrollments'])
        ->middleware('role:student');
    Route::patch('/enrollments/{enrollment}/attendance', [MentoringController::class, 'updateAttendance'])
        ->middleware(['role:mentor', 'mentor.verified']);
    Route::patch('/enrollments/{enrollment}/decision', [MentoringController::class, 'decideBooking'])
        ->middleware(['role:mentor', 'mentor.verified']);
    Route::post('/enrollments/{enrollment}/assessment', [MentoringController::class, 'submitAssessment'])
        ->middleware(['role:mentor', 'mentor.verified']);
    Route::post('/enrollments/{enrollment}/endorse', [MentoringController::class, 'endorse'])
        ->middleware(['role:mentor', 'mentor.verified']);
    Route::post('/enrollments/{enrollment}/confirm-completion', [MentoringController::class, 'confirmCompletion'])
        ->middleware('role:student');
    Route::get('/enrollments/{enrollment}/messages', [MentoringController::class, 'messages']);
    Route::post('/enrollments/{enrollment}/messages', [MentoringController::class, 'sendMessage']);
    Route::get('/enrollments/{enrollment}/assignments', [MentoringController::class, 'enrollmentAssignments']);
    Route::post('/assignments/{assignment}/submissions', [MentoringController::class, 'submitAssignment'])
        ->middleware('role:student');
    Route::patch('/submissions/{submission}/review', [MentoringController::class, 'reviewAssignment'])
        ->middleware(['role:mentor', 'mentor.verified']);

    Route::middleware('role:mentor')->prefix('mentor')->group(function () {
        Route::get('/profile', [MentoringController::class, 'mentorProfile']);
        Route::put('/profile', [MentoringController::class, 'updateMentorProfile']);
        Route::get('/verification', [MentoringController::class, 'verificationStatus']);
        Route::middleware('mentor.verified')->group(function () {
            Route::get('/dashboard', [MentoringController::class, 'mentorDashboard']);
            Route::get('/classes', [MentoringController::class, 'mentorClasses']);
            Route::post('/classes', [MentoringController::class, 'storeClass']);
            Route::post('/classes/{mentoringClass}/assignments', [MentoringController::class, 'createAssignment']);
            Route::put('/classes/{mentoringClass}', [MentoringController::class, 'updateClass']);
            Route::delete('/classes/{mentoringClass}', [MentoringController::class, 'deleteClass']);
            Route::get('/enrollments', [MentoringController::class, 'mentorEnrollments']);
            Route::post('/premium-subscriptions', [MentoringController::class, 'subscribePremium']);
            Route::get('/premium-subscriptions', [MentoringController::class, 'premiumSubscriptions']);
        });
    });
});

Route::middleware(['auth:sanctum', 'role:admin'])->prefix('admin')->group(function () {
    Route::get('/mentors/pending-verification', [MentoringController::class, 'pendingMentorVerifications']);
    Route::patch('/mentors/{mentor}/verification', [MentoringController::class, 'reviewMentorVerification']);
    Route::get('/mentor-premium-subscriptions/pending', [MentoringController::class, 'pendingPremiumSubscriptions']);
    Route::patch('/mentor-premium-subscriptions/{subscription}', [MentoringController::class, 'resolvePremiumSubscription']);
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
