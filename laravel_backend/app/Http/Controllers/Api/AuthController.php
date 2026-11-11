<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Http\Resources\StudentPresenter;
use App\Models\MentorProfile;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use App\Services\StudentAccountService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\File;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function __construct(private readonly StudentAccountService $studentAccountService)
    {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $data = $request->validated();
        $ktmPath = null;
        $avatarPath = null;

        if ($request->hasFile('ktm_file')) {
            $ktmPath = $request->file('ktm_file')->store('student-ktms', 'public');
            $data['ktm_document_url'] = Storage::disk('public')->url($ktmPath);
        }
        if ($request->hasFile('avatar_file')) {
            $avatarPath = $request->file('avatar_file')->store('student-avatars', 'public');
            $data['avatar_url'] = Storage::disk('public')->url($avatarPath);
        }

        try {
            [$user, $wallet] = DB::transaction(function () use ($data) {
                $role = Role::where('name', $data['role'])->firstOrFail();
                $user = User::create([
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'password' => $data['password'],
                    'role_id' => $role->id,
                ]);
                $user->roles()->syncWithoutDetaching([$role->id]);

                if ($data['role'] === 'student') {
                    StudentProfile::create([
                        'user_id' => $user->id,
                        'university' => $data['university'],
                        'major' => $data['major'],
                        'student_id_number' => $data['student_id_number'],
                        'ktm_document_url' => $data['ktm_document_url'] ?? null,
                        'ktm_verification_status' => 'approved',
                        'avatar_url' => $data['avatar_url'] ?? null,
                        'cohort_year' => $data['cohort_year'] ?? null,
                        'bio' => $data['bio'] ?? null,
                    ]);
                    if (! empty($data['skills'])) {
                        $this->studentAccountService->syncSkills($user, $data['skills']);
                    }
                } else {
                    UmkmProfile::create([
                        'user_id' => $user->id,
                        'business_name' => $data['business_name'],
                        'business_sector' => $data['business_sector'],
                        'address' => $data['address'],
                        'business_document_url' => $data['business_document_url'] ?? null,
                    ]);
                }

                return [$user, TimeCoinWallet::create([
                    'user_id' => $user->id,
                    'balance' => 0,
                    'locked_balance' => 0,
                ])];
            });
        } catch (\Throwable $exception) {
            if ($ktmPath !== null) {
                Storage::disk('public')->delete($ktmPath);
            }
            if ($avatarPath !== null) {
                Storage::disk('public')->delete($avatarPath);
            }
            throw $exception;
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil.',
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => $this->formatSessionUser(
                    $user->fresh(['roleRecord', 'studentProfile', 'mentorProfile', 'roles']),
                    (int) ($wallet->balance ?? 0),
                ),
            ],
        ], 201);
    }

    public function registerMentor(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:150', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'title_headline' => ['required', 'string', 'max:150'],
            'bio' => ['required', 'string', 'max:5000'],
            'hourly_rate_tc' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'cv_file' => ['required', File::types(['pdf'])->max(5 * 1024)],
            'portfolio_url' => ['required', 'url', 'max:2048'],
        ], [
            'cv_file.required' => 'CV dalam format PDF wajib diunggah.',
            'cv_file.mimes' => 'Format CV harus berupa berkas PDF.',
            'cv_file.max' => 'Ukuran berkas CV maksimal 5 MB.',
        ]);

        $cvPath = $request->file('cv_file')->store('mentor-cvs', 'public');
        $cvUrl = Storage::disk('public')->url($cvPath);

        try {
            $result = DB::transaction(function () use ($data, $cvUrl) {
                $mentorRole = Role::where('name', 'mentor')->firstOrFail();
                $user = User::create([
                    'name' => $data['name'],
                    'email' => $data['email'],
                    'password' => $data['password'],
                    'role_id' => $mentorRole->id,
                ]);
                $user->roles()->syncWithoutDetaching([$mentorRole->id]);
                $profile = MentorProfile::create([
                    'user_id' => $user->id,
                    'title_headline' => $data['title_headline'],
                    'bio' => $data['bio'],
                    'hourly_rate_tc' => $data['hourly_rate_tc'] ?? 3,
                    'verification_document_url' => $cvUrl,
                    'portfolio_url' => $data['portfolio_url'],
                    'verification_status' => 'approved',
                    'verification_reviewed_at' => now(),
                ]);
                $wallet = TimeCoinWallet::create([
                    'user_id' => $user->id,
                    'balance' => 0,
                    'locked_balance' => 0,
                ]);

                return [$user, $profile, $wallet];
            });
        } catch (\Throwable $exception) {
            Storage::disk('public')->delete($cvPath);
            throw $exception;
        }
        [$user, $profile, $wallet] = $result;

        return response()->json([
            'status' => 'success',
            'message' => 'Pendaftaran mentor berhasil dan akun sudah terverifikasi.',
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => 'mentor',
                    'roles' => ['mentor'],
                    'balance_tc' => (int) ($wallet->balance ?? 0),
                ],
                'verification_status' => $profile->verification_status,
                'cv_url' => $profile->verification_document_url,
            ],
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $identifier = $request->identifierValue();
        $password = $request->input('password');

        $user = User::query()
            ->where('email', $identifier)
            ->orWhereHas('studentProfile', fn ($q) => $q->where('student_id_number', $identifier))
            ->first();

        if (! $user || ! Hash::check($password, $user->password)) {
            throw ValidationException::withMessages(['email' => ['Email/NIM atau kata sandi tidak valid.']]);
        }

        $wallet = TimeCoinWallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'locked_balance' => 0],
        );
        $token = $user->createToken('flutter')->plainTextToken;
        $user->load(['roleRecord', 'roles', 'studentProfile', 'mentorProfile']);

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil.',
            'data' => [
                'token' => $token,
                'user' => $this->formatSessionUser($user, (int) ($wallet->balance ?? 0)),
            ],
        ]);
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['roleRecord', 'roles', 'studentProfile', 'studentSkills', 'mentorProfile']);
        $balance = TimeCoinWallet::where('user_id', $user->id)->value('balance') ?? 0;

        if ($user->hasRole('student')) {
            return response()->json([
                'status' => 'success',
                'data' => StudentPresenter::profile($user, $balance),
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data' => $this->formatSessionUser($user, $balance),
        ]);
    }

    public function switchRole(Request $request): JsonResponse
    {
        $data = $request->validate([
            'role' => ['required', Rule::in(['student', 'mentor'])],
        ]);
        $user = $request->user();
        abort_unless(
            $user->hasAssignedRole($data['role']),
            403,
            'Akun Anda belum memiliki akses untuk peran tersebut.',
        );

        $role = Role::where('name', $data['role'])->firstOrFail();
        $user->update(['role_id' => $role->id]);
        $user = $user->fresh(['roleRecord', 'roles', 'studentProfile', 'mentorProfile']);
        $balance = TimeCoinWallet::where('user_id', $user->id)->value('balance') ?? 0;

        return response()->json([
            'status' => 'success',
            'message' => 'Peran aktif berhasil dialihkan ke '.($data['role'] === 'mentor' ? 'Peer Mentor' : 'Mahasiswa').'.',
            'data' => [
                'user' => $this->formatSessionUser($user, $balance),
            ],
        ]);
    }

    public function sessions(Request $request): JsonResponse
    {
        $currentId = $request->user()->currentAccessToken()?->id;
        $tokens = $request->user()->tokens()->latest()->get()->map(fn ($token) => [
            'id' => $token->id,
            'device_name' => $token->name ?: 'Perangkat Android',
            'is_current' => $token->id === $currentId,
            'last_used_at' => $token->last_used_at?->toIso8601String(),
            'created_at' => $token->created_at?->toIso8601String(),
        ]);

        return response()->json(['status' => 'success', 'data' => $tokens]);
    }

    public function revokeOtherSessions(Request $request): JsonResponse
    {
        $currentId = $request->user()->currentAccessToken()?->id;
        $deleted = $request->user()->tokens()->when($currentId, fn ($q) => $q->where('id', '!=', $currentId))->delete();

        return response()->json([
            'status' => 'success',
            'message' => $deleted > 0
                ? "{$deleted} sesi perangkat lain berhasil dikeluarkan."
                : 'Tidak ada sesi perangkat lain yang aktif.',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['status' => 'success', 'message' => 'Logout berhasil.']);
    }

    private function formatSessionUser(User $user, int $balance): array
    {
        $roleName = $user->roleRecord?->name;
        $roles = $user->roles->pluck('name')->values()->all();
        if ($roleName && ! in_array($roleName, $roles, true)) {
            $roles[] = $roleName;
        }

        $avatarUrl = match ($roleName) {
            'mentor' => $user->mentorProfile?->avatar_url ?? $user->studentProfile?->avatar_url,
            'student' => $user->studentProfile?->avatar_url,
            default => null,
        };

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $roleName,
            'roles' => $roles,
            'balance_tc' => $balance,
            'verification_status' => $user->hasRole('mentor') ? $user->mentorProfile?->verification_status : null,
            'avatar_url' => $avatarUrl,
            'university' => $user->studentProfile?->university,
            'major' => $user->studentProfile?->major,
            'student_id_number' => $user->studentProfile?->student_id_number,
            'completed_projects_count' => $user->studentProfile?->completed_projects_count ?? 0,
            'is_mentor_eligible' => (bool) ($user->studentProfile?->is_mentor_eligible ?? false),
        ];
    }
}
