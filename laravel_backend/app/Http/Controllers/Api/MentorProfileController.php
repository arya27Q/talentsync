<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MentoringPresenter;
use App\Models\CashOutRequest;
use App\Models\MentorPremiumSubscription;
use App\Models\MentorProfile;
use App\Models\MentoringClass;
use App\Models\MentoringEnrollment;
use App\Models\MentoringMessage;
use App\Models\Review;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\File;

class MentorProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $profile = MentorProfile::firstOrCreate(
            ['user_id' => $request->user()->id],
            ['verification_status' => 'approved'],
        );

        return response()->json([
            'status' => 'success',
            'data' => MentoringPresenter::mentorProfile(
                $profile->loadMissing('user:id,name,email'),
            ),
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'title_headline' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:5000'],
            'hourly_rate_tc' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'avatar_file' => ['sometimes', File::image()->max(2 * 1024)],
            'remove_avatar' => ['sometimes', 'boolean'],
            'cv_file' => ['sometimes', File::types(['pdf'])->max(5 * 1024)],
            'verification_document_url' => ['sometimes', 'url', 'max:2048'],
            'portfolio_url' => ['sometimes', 'url', 'max:2048'],
        ], [
            'name.required' => 'Nama lengkap wajib diisi.',
            'avatar_file.image' => 'Foto profil harus berupa berkas gambar (JPG, PNG, WEBP).',
            'avatar_file.max' => 'Ukuran foto profil maksimal 2 MB.',
            'cv_file.mimes' => 'Format CV harus berupa berkas PDF.',
            'cv_file.max' => 'Ukuran berkas CV maksimal 5 MB.',
        ]);

        $user = $request->user();
        $profile = MentorProfile::firstOrCreate(
            ['user_id' => $user->id],
            ['verification_status' => 'approved'],
        );

        $newAvatarPath = null;
        $newCvPath = null;
        $filesToDeleteAfterSave = [];

        if ($request->hasFile('avatar_file')) {
            $newAvatarPath = $request->file('avatar_file')->store('mentor-avatars', 'public');
            $data['avatar_url'] = Storage::disk('public')->url($newAvatarPath);
            if ($oldAvatar = $this->publicDiskPath($profile->avatar_url)) {
                $filesToDeleteAfterSave[] = $oldAvatar;
            }
        } elseif ($request->boolean('remove_avatar')) {
            $data['avatar_url'] = null;
            if ($oldAvatar = $this->publicDiskPath($profile->avatar_url)) {
                $filesToDeleteAfterSave[] = $oldAvatar;
            }
        }

        if ($request->hasFile('cv_file')) {
            $newCvPath = $request->file('cv_file')->store('mentor-cvs', 'public');
            $data['verification_document_url'] = Storage::disk('public')->url($newCvPath);
            if ($oldCv = $this->publicDiskPath($profile->verification_document_url)) {
                $filesToDeleteAfterSave[] = $oldCv;
            }
        }

        $name = $data['name'] ?? null;
        unset($data['name'], $data['avatar_file'], $data['remove_avatar'], $data['cv_file']);

        if ($profile->verification_status !== 'approved') {
            $data['verification_status'] = 'approved';
            $data['verification_rejection_reason'] = null;
            $data['verification_reviewed_at'] = now();
        }

        try {
            DB::transaction(function () use ($user, $profile, $name, $data) {
                if ($name !== null) {
                    $user->update(['name' => $name]);
                }
                if ($data !== []) {
                    $profile->fill($data)->save();
                }
            });
        } catch (\Throwable $exception) {
            if ($newAvatarPath !== null) {
                Storage::disk('public')->delete($newAvatarPath);
            }
            if ($newCvPath !== null) {
                Storage::disk('public')->delete($newCvPath);
            }
            throw $exception;
        }

        foreach ($filesToDeleteAfterSave as $oldPath) {
            Storage::disk('public')->delete($oldPath);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Profil mentor berhasil diperbarui.',
            'data' => MentoringPresenter::mentorProfile(
                $profile->fresh('user:id,name,email'),
            ),
        ]);
    }

    public function destroyAccount(Request $request): JsonResponse
    {
        $user = $request->user();
        $classIds = MentoringClass::query()->where('mentor_id', $user->id)->pluck('id');

        $hasOngoingEnrollments = $classIds->isNotEmpty() && MentoringEnrollment::query()
            ->whereIn('class_id', $classIds)
            ->whereIn('status', ['pending', 'accepted', 'attended', 'pending_confirmation'])
            ->exists();
        abort_if($hasOngoingEnrollments, 409, 'Selesaikan atau batalkan seluruh sesi mentoring aktif terlebih dahulu sebelum menghapus akun.');

        $hasPendingCashOut = CashOutRequest::query()
            ->where('user_id', $user->id)
            ->where('status', 'pending')
            ->exists();
        abort_if($hasPendingCashOut, 409, 'Tunggu proses penarikan TimeCoin selesai sebelum menghapus akun.');

        $profile = MentorProfile::query()->where('user_id', $user->id)->first();
        $filesToDelete = array_values(array_filter([
            $this->publicDiskPath($profile?->avatar_url),
            $this->publicDiskPath($profile?->verification_document_url),
        ]));

        DB::transaction(function () use ($user, $classIds) {
            $enrollmentIds = $classIds->isEmpty()
                ? collect()
                : MentoringEnrollment::query()->whereIn('class_id', $classIds)->pluck('id');

            $assignmentIds = DB::table('mentoring_assignments')
                ->where('mentor_id', $user->id)
                ->when($classIds->isNotEmpty(), fn ($query) => $query->orWhereIn('class_id', $classIds))
                ->pluck('id');

            if ($assignmentIds->isNotEmpty()) {
                DB::table('mentoring_assignment_submissions')
                    ->whereIn('assignment_id', $assignmentIds)
                    ->delete();
                DB::table('mentoring_assignments')
                    ->whereIn('id', $assignmentIds)
                    ->delete();
            }

            MentoringMessage::query()
                ->where('sender_id', $user->id)
                ->when($enrollmentIds->isNotEmpty(), fn ($query) => $query->orWhereIn('enrollment_id', $enrollmentIds))
                ->delete();

            Review::query()
                ->where('reviewer_id', $user->id)
                ->orWhere('reviewee_id', $user->id)
                ->when($classIds->isNotEmpty(), fn ($query) => $query->orWhereIn('mentoring_class_id', $classIds))
                ->delete();

            if ($enrollmentIds->isNotEmpty()) {
                MentoringEnrollment::query()->whereIn('id', $enrollmentIds)->delete();
            }

            if ($classIds->isNotEmpty()) {
                MentoringClass::query()->whereIn('id', $classIds)->delete();
            }

            MentorPremiumSubscription::query()->where('mentor_id', $user->id)->delete();
            CashOutRequest::query()->where('user_id', $user->id)->delete();

            $walletId = TimeCoinWallet::query()->where('user_id', $user->id)->value('id');
            TimeCoinTransaction::query()
                ->where('sender_id', $user->id)
                ->orWhere('recipient_id', $user->id)
                ->when($walletId !== null, fn ($query) => $query->orWhere('wallet_id', $walletId))
                ->delete();

            if ($walletId !== null) {
                TimeCoinWallet::query()->where('id', $walletId)->delete();
            }

            MentorProfile::query()->where('user_id', $user->id)->delete();
            $user->tokens()->delete();
            $user->delete();
        });

        foreach ($filesToDelete as $path) {
            Storage::disk('public')->delete($path);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Akun mentor berhasil dihapus.',
        ]);
    }

    private function publicDiskPath(?string $url): ?string
    {
        if ($url === null || $url === '') {
            return null;
        }
        $prefix = rtrim(Storage::disk('public')->url(''), '/').'/';
        if (str_starts_with($url, $prefix)) {
            return ltrim(substr($url, strlen($prefix)), '/');
        }
        $parsedPath = parse_url($url, PHP_URL_PATH);
        if (is_string($parsedPath) && str_starts_with($parsedPath, '/storage/')) {
            return ltrim(substr($parsedPath, strlen('/storage/')), '/');
        }

        return null;
    }
}
