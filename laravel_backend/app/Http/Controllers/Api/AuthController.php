<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TimeCoinWallet;
use App\Models\MentorProfile;
use App\Models\Role;
use App\Models\StudentProfile;
use App\Models\UmkmProfile;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\File;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:150', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['required', 'in:student,msme'],
            'university' => ['required_if:role,student', 'nullable', 'string', 'max:150'],
            'major' => ['required_if:role,student', 'nullable', 'string', 'max:100'],
            'student_id_number' => ['required_if:role,student', 'nullable', 'string', 'max:50', 'unique:student_profiles,student_id_number'],
            'ktm_document_url' => ['nullable', 'url', 'max:2048'],
            'business_name' => ['required_if:role,msme', 'nullable', 'string', 'max:150'],
            'business_sector' => ['required_if:role,msme', 'nullable', 'string', 'max:100'],
            'address' => ['required_if:role,msme', 'nullable', 'string', 'max:5000'],
            'business_document_url' => ['nullable', 'url', 'max:2048'],
        ]);
        [$user, $wallet] = DB::transaction(function () use ($data) {
            $role = Role::where('name', $data['role'])->firstOrFail();
            $user = User::create([
                'name' => $data['name'],
                'email' => $data['email'],
                'password' => $data['password'],
                'role_id' => $role->id,
            ]);

            if ($data['role'] === 'student') {
                StudentProfile::create([
                    'user_id' => $user->id,
                    'university' => $data['university'],
                    'major' => $data['major'],
                    'student_id_number' => $data['student_id_number'],
                    'ktm_document_url' => $data['ktm_document_url'] ?? null,
                ]);
            } else {
                UmkmProfile::create([
                    'user_id' => $user->id,
                    'business_name' => $data['business_name'],
                    'business_sector' => $data['business_sector'],
                    'address' => $data['address'],
                    'business_document_url' => $data['business_document_url'] ?? null,
                ]);
            }

            return [$user, TimeCoinWallet::create(['user_id' => $user->id])];
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil.',
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $data['role'],
                    'balance_tc' => $wallet->balance,
                ],
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
                $wallet = TimeCoinWallet::create(['user_id' => $user->id]);

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
                'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'role' => 'mentor', 'balance_tc' => $wallet->balance],
                'verification_status' => $profile->verification_status,
                'cv_url' => $profile->verification_document_url,
            ],
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);
        $user = User::where('email', $data['email'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages(['email' => ['Email atau kata sandi tidak valid.']]);
        }

        $wallet = TimeCoinWallet::firstOrCreate(['user_id' => $user->id]);
        $token = $user->createToken('flutter')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil.',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->roleRecord?->name,
                    'balance_tc' => $wallet->balance,
                    'verification_status' => $user->hasRole('mentor') ? $user->mentorProfile?->verification_status : null,
                ],
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['status' => 'success', 'message' => 'Logout berhasil.']);
    }
}
