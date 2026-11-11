<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Student\SwitchToMentorRequest;
use App\Http\Requests\Student\UpdateStudentProfileRequest;
use App\Http\Resources\StudentPresenter;
use App\Models\Portfolio;
use App\Models\StudentCertificate;
use App\Models\StudentProfile;
use App\Models\StudentSkill;
use App\Models\TimeCoinWallet;
use App\Services\StudentAccountService;
use App\Services\StudentEligibilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class StudentProfileController extends Controller
{
    public function __construct(
        private readonly StudentAccountService $accountService,
        private readonly StudentEligibilityService $eligibilityService,
    ) {
    }

    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load(['roleRecord', 'roles', 'studentProfile', 'studentSkills']);
        $balance = TimeCoinWallet::where('user_id', $user->id)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'data' => StudentPresenter::profile($user, $balance),
        ]);
    }

    public function update(UpdateStudentProfileRequest $request): JsonResponse
    {
        $this->accountService->updateProfile(
            $request->user(),
            $request->validated(),
            $request->file('avatar_file'),
            $request->file('ktm_file'),
        );

        $user = $request->user()->fresh(['roleRecord', 'roles', 'studentProfile', 'studentSkills']);
        $balance = TimeCoinWallet::where('user_id', $user->id)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'message' => 'Profil mahasiswa berhasil diperbarui.',
            'data' => StudentPresenter::profile($user, $balance),
        ]);
    }

    public function privacy(Request $request): JsonResponse
    {
        $profile = StudentProfile::where('user_id', $request->user()->id)->first();

        return response()->json([
            'status' => 'success',
            'data' => [
                'two_factor_enabled' => (bool) ($profile?->two_factor_enabled ?? false),
                'is_public_profile' => (bool) ($profile?->is_public_profile ?? true),
                'show_online_status' => (bool) ($profile?->show_online_status ?? true),
                'show_endorse_badge' => (bool) ($profile?->show_endorse_badge ?? true),
                'has_transaction_pin' => ! empty($profile?->transaction_pin_hash),
                'pin_updated_at' => $profile?->pin_updated_at?->toIso8601String(),
                'password_updated_at' => $request->user()->updated_at?->toIso8601String(),
            ],
        ]);
    }

    public function updatePrivacy(Request $request): JsonResponse
    {
        $data = $request->validate([
            'two_factor_enabled' => ['sometimes', 'boolean'],
            'is_public_profile' => ['sometimes', 'boolean'],
            'show_online_status' => ['sometimes', 'boolean'],
            'show_endorse_badge' => ['sometimes', 'boolean'],
        ]);

        $profile = StudentProfile::where('user_id', $request->user()->id)->firstOrFail();
        $profile->fill($data)->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Pengaturan privasi dan keamanan diperbarui.',
            'data' => [
                'two_factor_enabled' => (bool) $profile->two_factor_enabled,
                'is_public_profile' => (bool) $profile->is_public_profile,
                'show_online_status' => (bool) $profile->show_online_status,
                'show_endorse_badge' => (bool) $profile->show_endorse_badge,
            ],
        ]);
    }

    public function updatePin(Request $request): JsonResponse
    {
        $data = $request->validate([
            'pin' => ['required', 'digits:6'],
        ], [
            'pin.required' => 'PIN transaksi wajib diisi.',
            'pin.digits' => 'PIN transaksi harus berupa 6 digit angka.',
        ]);

        $profile = StudentProfile::where('user_id', $request->user()->id)->firstOrFail();
        $profile->update([
            'transaction_pin_hash' => Hash::make($data['pin']),
            'pin_updated_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'PIN transaksi TimeCoin berhasil disimpan.',
            'data' => [
                'has_transaction_pin' => true,
                'pin_updated_at' => $profile->pin_updated_at?->toIso8601String(),
            ],
        ]);
    }

    public function verifySkill(Request $request, StudentSkill $skill): JsonResponse
    {
        abort_unless($skill->student_id === $request->user()->id, 403);
        $skill->update([
            'is_verified' => true,
            'verified_source' => 'Portofolio & Evaluasi Mandiri',
            'verified_at' => now(),
        ]);

        return response()->json([
            'status' => 'success',
            'message' => "Keahlian {$skill->name} berhasil diajukan & terverifikasi.",
            'data' => StudentPresenter::skill($skill->fresh()),
        ]);
    }

    public function githubSync(Request $request): JsonResponse
    {
        $data = $request->validate([
            'github_username' => ['sometimes', 'nullable', 'string', 'max:100'],
        ]);

        $profile = StudentProfile::where('user_id', $request->user()->id)->firstOrFail();
        $username = $data['github_username'] ?? $profile->github_username;
        abort_if(empty($username), 422, 'Atur username GitHub terlebih dahulu di Edit Profil.');

        $updated = $this->accountService->syncGithub($request->user(), $username);

        return response()->json([
            'status' => 'success',
            'message' => 'Statistik repositori GitHub berhasil disinkronkan.',
            'data' => [
                'connected' => true,
                'username' => $updated->github_username,
                'repos_count' => $updated->github_repos_count,
                'commits_count' => $updated->github_commits_count,
                'pinned_count' => $updated->github_pinned_count,
                'languages' => $updated->github_languages ?? [],
                'last_synced_at' => $updated->github_last_synced_at?->toIso8601String(),
            ],
        ]);
    }

    public function githubDisconnect(Request $request): JsonResponse
    {
        $this->accountService->disconnectGithub($request->user());

        return response()->json([
            'status' => 'success',
            'message' => 'Koneksi GitHub diputuskan.',
        ]);
    }

    public function mentorEligibility(Request $request): JsonResponse
    {
        $user = $request->user();
        $eligibility = $this->eligibilityService->mentorSwitchEligibility($user);

        $portfolios = Portfolio::where('student_id', $user->id)
            ->where('is_verified', true)
            ->latest()
            ->get()
            ->map(fn (Portfolio $p) => [
                'id' => $p->id,
                'title' => $p->title,
                'subtitle' => ($p->client_name ?? 'UMKM').' · '.$p->category,
                'selected' => true,
            ]);

        $certificates = StudentCertificate::where('student_id', $user->id)
            ->latest()
            ->get()
            ->map(fn (StudentCertificate $c) => StudentPresenter::certificate($c));

        $skills = StudentSkill::where('student_id', $user->id)
            ->pluck('name')
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                ...$eligibility,
                'available_proofs' => $portfolios,
                'certificates' => $certificates,
                'skills' => $skills,
            ],
        ]);
    }

    public function switchToMentor(SwitchToMentorRequest $request): JsonResponse
    {
        $result = $this->accountService->switchToMentor(
            $request->user(),
            $request->validated(),
            $request->file('external_certificate_file'),
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Mode Mentor berhasil diaktifkan! Anda kini dapat membimbing mahasiswa di dasbor mentor.',
            'data' => [
                'active_role' => $result['active_role'],
                'user' => [
                    'id' => $result['user']->id,
                    'name' => $result['user']->name,
                    'email' => $result['user']->email,
                    'role' => 'mentor',
                    'roles' => $result['user']->roles()->pluck('name')->values()->all(),
                    'avatar_url' => $result['user']->mentorProfile?->avatar_url,
                ],
            ],
        ]);
    }

    public function destroyAccount(Request $request): JsonResponse
    {
        $this->accountService->destroyAccount($request->user());

        return response()->json([
            'status' => 'success',
            'message' => 'Akun mahasiswa berhasil dinonaktifkan dan dihapus.',
        ]);
    }
}

