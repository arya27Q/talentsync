<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TimeCoinWallet;
use App\Models\MentorProfile;
use App\Models\Role;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Illuminate\Support\Facades\DB;

class AuthController extends Controller
{
    public function registerMentor(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:150', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'title_headline' => ['required', 'string', 'max:150'],
            'bio' => ['required', 'string', 'max:5000'],
            'verification_document_url' => ['required', 'url', 'max:2048'],
            'portfolio_url' => ['required', 'url', 'max:2048'],
        ]);
        $result = DB::transaction(function () use ($data) {
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
                'verification_document_url' => $data['verification_document_url'],
                'portfolio_url' => $data['portfolio_url'],
                'verification_status' => 'pending',
            ]);
            $wallet = TimeCoinWallet::create(['user_id' => $user->id]);

            return [$user, $profile, $wallet];
        });
        [$user, $profile, $wallet] = $result;

        return response()->json([
            'status' => 'success',
            'message' => 'Pendaftaran mentor diterima dan menunggu verifikasi.',
            'data' => [
                'token' => $user->createToken('flutter')->plainTextToken,
                'user' => ['id' => $user->id, 'name' => $user->name, 'email' => $user->email, 'role' => 'mentor', 'balance_tc' => $wallet->balance],
                'verification_status' => $profile->verification_status,
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
