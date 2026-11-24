<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Models\BankAccount;
use App\Models\EscrowDispute;
use App\Models\Project;
use App\Models\ProjectApplication;
use App\Models\Review;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\File;

class MsmeProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user()->load(['roleRecord', 'roles', 'umkmProfile']);
        $profile = $user->umkmProfile;

        if (! $profile) {
            $profile = UmkmProfile::create([
                'user_id' => $user->id,
                'business_name' => $user->name,
                'business_sector' => 'F&B',
                'address' => 'Surabaya, Jawa Timur',
                'city' => 'Surabaya',
                'is_verified' => true,
                'is_premium' => false,
                'monthly_quota_tc' => 20,
            ]);
        }

        $balance = (int) (TimeCoinWallet::where('user_id', $user->id)->value('balance') ?? 0);
        $completedProjectsCount = Project::where('msme_id', $user->id)->where('status', 'completed')->count();
        $userProjectIds = Project::where('msme_id', $user->id)->pluck('id');
        $mentoredStudentsCount = ProjectApplication::whereIn('project_id', $userProjectIds)->where('status', 'accepted')->distinct('student_id')->count('student_id');
        $avgRating = Review::where('reviewee_id', $user->id)->avg('rating');
        $rating = $avgRating !== null ? round((float) $avgRating, 1) : 0;

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'business_name' => $profile->business_name,
                'business_sector' => $profile->business_sector,
                'logo_url' => $profile->logo_url,
                'avatar_url' => $profile->logo_url,
                'address' => $profile->address,
                'district' => $profile->district,
                'city' => $profile->city ?? 'Surabaya',
                'description' => $profile->description,
                'nib' => $profile->nib,
                'business_document_url' => $profile->business_document_url,
                'is_verified' => (bool) $profile->is_verified,
                'is_premium' => (bool) $profile->is_premium,
                'monthly_quota_tc' => (int) ($profile->monthly_quota_tc ?? 20),
                'balance_tc' => $balance,
                'completed_projects_count' => $completedProjectsCount,
                'rating' => $rating,
                'mentored_students_count' => $mentoredStudentsCount,
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:150'],
            'business_name' => ['sometimes', 'string', 'max:150'],
            'business_sector' => ['sometimes', 'string', 'max:100'],
            'address' => ['sometimes', 'string', 'max:5000'],
            'district' => ['nullable', 'string', 'max:100'],
            'city' => ['sometimes', 'string', 'max:100'],
            'description' => ['nullable', 'string', 'max:5000'],
            'nib' => ['nullable', 'string', 'max:50'],
            'logo_url' => ['nullable', 'string', 'max:2048'],
            'logo_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png'])->max(3 * 1024)],
        ], [
            'logo_file.mimes' => 'Format logo usaha hanya mendukung PNG atau JPG/JPEG.',
            'logo_file.max' => 'Ukuran logo usaha maksimal 3 MB.',
        ]);

        if (isset($data['name']) && $data['name'] !== $user->name) {
            $user->update(['name' => $data['name']]);
        }

        $profile = $user->umkmProfile ?: new UmkmProfile(['user_id' => $user->id]);

        if ($request->hasFile('logo_file')) {
            $storedPath = $request->file('logo_file')->store('umkm-logos', 'public');
            /** @var \Illuminate\Filesystem\FilesystemAdapter $publicDisk */
            $publicDisk = Storage::disk('public');
            $data['logo_url'] = $publicDisk->url($storedPath);
        }

        $profile->fill([
            'business_name' => $data['business_name'] ?? $profile->business_name ?? $user->name,
            'business_sector' => $data['business_sector'] ?? $profile->business_sector ?? 'Umum',
            'address' => $data['address'] ?? $profile->address ?? 'Surabaya',
            'district' => $data['district'] ?? $profile->district,
            'city' => $data['city'] ?? $profile->city ?? 'Surabaya',
            'description' => array_key_exists('description', $data) ? $data['description'] : $profile->description,
            'nib' => array_key_exists('nib', $data) ? $data['nib'] : $profile->nib,
            'logo_url' => $data['logo_url'] ?? $profile->logo_url,
        ]);
        $profile->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profil usaha berhasil diperbarui.',
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'business_name' => $profile->business_name,
                'business_sector' => $profile->business_sector,
                'logo_url' => $profile->logo_url,
                'avatar_url' => $profile->logo_url,
                'address' => $profile->address,
                'district' => $profile->district,
                'city' => $profile->city,
                'description' => $profile->description,
                'nib' => $profile->nib,
                'is_verified' => (bool) $profile->is_verified,
            ],
        ]);
    }

    public function destroyAccount(Request $request): JsonResponse
    {
        $user = $request->user();

        $hasActiveProjects = Project::where('msme_id', $user->id)
            ->whereIn('status', ['in_progress', 'review'])
            ->exists();
        abort_if($hasActiveProjects, 409, 'Selesaikan proyek yang sedang berjalan atau menunggu peninjauan sebelum menghapus akun.');

        $wallet = TimeCoinWallet::where('user_id', $user->id)->first();
        abort_if(($wallet?->locked_balance ?? 0) > 0, 409, 'Masih terdapat saldo TimeCoin yang tertahan di escrow.');

        $hasOpenDisputes = EscrowDispute::where('reporter_id', $user->id)
            ->where('status', '!=', 'resolved')
            ->exists();
        abort_if($hasOpenDisputes, 409, 'Selesaikan laporan sengketa escrow terlebih dahulu sebelum menghapus akun.');

        $profile = UmkmProfile::where('user_id', $user->id)->first();
        $filesToDelete = array_values(array_filter([
            $this->publicDiskPath($profile?->logo_url),
            $this->publicDiskPath($profile?->business_document_url),
        ]));

        DB::transaction(function () use ($user, $profile) {
            $user->tokens()->delete();
            BankAccount::where('user_id', $user->id)->delete();

            // Close any remaining open postings so students cannot apply to a deleted MSME
            Project::where('msme_id', $user->id)
                ->where('status', 'open')
                ->update(['status' => 'cancelled']);

            if ($profile) {
                $profile->update([
                    'business_name' => 'Akun Mitra Terhapus',
                    'logo_url' => null,
                    'business_document_url' => null,
                    'description' => null,
                    'nib' => null,
                    'is_verified' => false,
                ]);
            }

            $user->update([
                'name' => 'Akun Mitra Terhapus',
                'email' => "deleted-msme-{$user->id}-".Str::lower(Str::random(6)).'@deleted.talentsync.local',
                'password' => Str::random(40),
            ]);
        }, 3);

        foreach ($filesToDelete as $path) {
            Storage::disk('public')->delete($path);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Akun Mitra UMKM berhasil dihapus secara permanen.',
        ]);
    }

    private function publicDiskPath(?string $url): ?string
    {
        if (! $url) {
            return null;
        }
        $path = parse_url($url, PHP_URL_PATH);
        if (! is_string($path) || ! str_starts_with($path, '/storage/')) {
            return null;
        }

        return substr($path, strlen('/storage/'));
    }
}
