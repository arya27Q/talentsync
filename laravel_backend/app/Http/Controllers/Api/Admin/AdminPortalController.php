<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\WalletPresenter;
use App\Models\AdminAuditLog;
use App\Models\CashOutRequest;
use App\Models\EscrowDispute;
use App\Models\MentoringClass;
use App\Models\MentorPremiumSubscription;
use App\Models\MentorProfile;
use App\Models\Project;
use App\Models\Reward;
use App\Models\StudentProfile;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\User;
use App\Services\NotificationDispatcher;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class AdminPortalController extends Controller
{
    public function __construct(private readonly NotificationDispatcher $notifications)
    {
    }

    public function dashboard(): JsonResponse
    {
        $studentsCount = User::query()
            ->where(fn ($q) => $q->whereHas('roleRecord', fn ($r) => $r->where('name', 'student'))
                ->orWhereHas('roles', fn ($r) => $r->where('name', 'student')))
            ->count();

        $msmesCount = User::query()
            ->where(fn ($q) => $q->whereHas('roleRecord', fn ($r) => $r->where('name', 'msme'))
                ->orWhereHas('roles', fn ($r) => $r->where('name', 'msme')))
            ->count();

        $mentorsCount = User::query()
            ->where(fn ($q) => $q->whereHas('roleRecord', fn ($r) => $r->where('name', 'mentor'))
                ->orWhereHas('roles', fn ($r) => $r->where('name', 'mentor')))
            ->count();

        $recentTransactions = TimeCoinTransaction::query()
            ->with(['wallet.user:id,name,email'])
            ->latest('created_at')
            ->latest('id')
            ->limit(8)
            ->get()
            ->map(fn (TimeCoinTransaction $tx) => [
                ...WalletPresenter::transaction($tx),
                'owner_name' => $tx->wallet?->user?->name ?? 'Pengguna',
                'owner_email' => $tx->wallet?->user?->email ?? '',
            ])
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'users' => [
                    'total' => User::count(),
                    'students' => $studentsCount,
                    'msmes' => $msmesCount,
                    'mentors' => $mentorsCount,
                ],
                'projects' => [
                    'total' => Project::count(),
                    'open' => Project::where('status', 'open')->count(),
                    'in_progress' => Project::where('status', 'in_progress')->count(),
                    'completed' => Project::where('status', 'completed')->count(),
                ],
                'mentoring' => [
                    'open_classes' => MentoringClass::where('status', 'open')->count(),
                    'total_classes' => MentoringClass::count(),
                ],
                'economy' => [
                    'total_circulating_tc' => (int) TimeCoinWallet::sum('balance'),
                    'total_locked_escrow_tc' => (int) TimeCoinWallet::sum('locked_balance'),
                ],
                'queues' => [
                    'pending_cash_outs' => CashOutRequest::where('status', 'pending_transfer')->count(),
                    'pending_mentor_premium' => MentorPremiumSubscription::where('payment_status', 'pending')->count(),
                    'open_disputes' => EscrowDispute::where('status', 'open')->count(),
                    'suspended_users' => User::whereNotNull('suspended_at')->count(),
                ],
                'recent_transactions' => $recentTransactions,
            ],
        ]);
    }

    public function users(Request $request): JsonResponse
    {
        $role = trim((string) $request->query('role', 'all'));
        $search = mb_strtolower(trim((string) $request->query('search', '')));

        $query = User::query()
            ->with(['roleRecord:id,name', 'roles:id,name', 'studentProfile', 'umkmProfile', 'mentorProfile', 'timeCoinWallet'])
            ->withCount('tokens')
            ->where(function ($q) {
                $q->whereDoesntHave('roleRecord', fn ($r) => $r->where('name', 'admin'));
            })
            ->when($role !== '' && $role !== 'all', function ($q) use ($role) {
                $q->where(function ($inner) use ($role) {
                    $inner->whereHas('roleRecord', fn ($r) => $r->where('name', $role))
                        ->orWhereHas('roles', fn ($r) => $r->where('name', $role));
                });
            })
            ->when($search !== '', function ($q) use ($search) {
                $like = '%'.$search.'%';
                $q->where(function ($inner) use ($like) {
                    $inner->whereRaw('LOWER(name) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(email) LIKE ?', [$like]);
                });
            })
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 20), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (User $u) => $this->presentUser($u))->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function updateUserVerification(Request $request, User $user): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['approved', 'pending', 'rejected'])],
            'target_role' => ['sometimes', Rule::in(['student', 'msme', 'mentor'])],
        ]);

        $targetRole = $data['target_role'] ?? $user->roleRecord?->name ?? 'student';
        $status = $data['status'];

        if ($targetRole === 'student') {
            $profile = StudentProfile::firstOrCreate(
                ['user_id' => $user->id],
                ['university' => 'Belum diisi', 'major' => 'Belum diisi']
            );
            $profile->update(['ktm_verification_status' => $status]);
        } elseif ($targetRole === 'msme') {
            $profile = UmkmProfile::firstOrCreate(
                ['user_id' => $user->id],
                ['business_name' => $user->name, 'business_sector' => 'Umum', 'address' => 'Belum diisi']
            );
            $profile->update(['is_verified' => $status === 'approved']);
        } elseif ($targetRole === 'mentor') {
            $profile = MentorProfile::firstOrCreate(['user_id' => $user->id]);
            $profile->update(['verification_status' => $status]);
        }

        $statusLabel = match ($status) {
            'approved' => 'disetujui',
            'rejected' => 'ditolak',
            default => 'dikembalikan ke menunggu verifikasi',
        };
        $this->notifications->send(
            $user,
            'admin_verification_updated',
            'Status Verifikasi Akun Diperbarui',
            "Status verifikasi akun {$targetRole} Anda telah {$statusLabel} oleh Admin TalentSync.",
            '/notifications',
        );

        AdminAuditLog::record(
            $request,
            'user_verification_updated',
            'user',
            $user->id,
            "{$user->name} ({$targetRole})",
            "Status verifikasi diubah menjadi {$status}.",
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Status verifikasi pengguna berhasil diperbarui.',
            'data' => $this->presentUser($user->fresh(['roleRecord:id,name', 'roles:id,name', 'studentProfile', 'umkmProfile', 'mentorProfile', 'timeCoinWallet'])->loadCount('tokens')),
        ]);
    }

    public function updateUserSuspension(Request $request, User $user): JsonResponse
    {
        abort_if($user->hasRole('admin'), 403, 'Akun administrator tidak dapat dibekukan.');

        $data = $request->validate([
            'is_suspended' => ['required', 'boolean'],
            'reason' => ['nullable', 'string', 'max:500'],
            'admin_password' => ['nullable', 'string'],
        ]);

        if (! empty($data['admin_password']) && ! Hash::check($data['admin_password'], $request->user()->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kata sandi konfirmasi admin tidak sesuai.',
            ], 422);
        }

        $isSuspended = (bool) $data['is_suspended'];
        $reason = trim((string) ($data['reason'] ?? ''));

        if ($isSuspended) {
            if (mb_strlen($reason) < 5) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Alasan pembekuan akun minimal 5 karakter.',
                ], 422);
            }

            $user->update([
                'suspended_at' => now(),
                'suspended_reason' => $reason,
                'suspended_by' => $request->user()->id,
            ]);
            $revokedCount = $user->tokens()->delete();

            $this->notifications->send(
                $user,
                'account_suspended',
                'Akun Dibekukan Sementara',
                "Akun Anda dibekukan oleh Admin TalentSync. Alasan: {$reason}",
                '/settings/help-support',
            );

            AdminAuditLog::record(
                $request,
                'user_suspended',
                'user',
                $user->id,
                "{$user->name} ({$user->email})",
                "Akun dibekukan. Alasan: {$reason}. {$revokedCount} sesi aktif dicabut.",
            );
        } else {
            $user->update([
                'suspended_at' => null,
                'suspended_reason' => null,
                'suspended_by' => null,
            ]);

            $this->notifications->send(
                $user,
                'account_unsuspended',
                'Pembekuan Akun Dibuka',
                'Akun Anda telah diaktifkan kembali oleh Admin TalentSync. Anda dapat masuk seperti biasa.',
                '/notifications',
            );

            AdminAuditLog::record(
                $request,
                'user_unsuspended',
                'user',
                $user->id,
                "{$user->name} ({$user->email})",
                'Pembekuan akun dibuka kembali oleh admin.',
            );
        }

        return response()->json([
            'status' => 'success',
            'message' => $isSuspended
                ? 'Akun pengguna berhasil dibekukan dan seluruh sesinya telah dicabut.'
                : 'Pembekuan akun berhasil dibuka kembali.',
            'data' => $this->presentUser($user->fresh(['roleRecord:id,name', 'roles:id,name', 'studentProfile', 'umkmProfile', 'mentorProfile', 'timeCoinWallet'])->loadCount('tokens')),
        ]);
    }

    public function forceLogoutUser(Request $request, User $user): JsonResponse
    {
        abort_if($user->hasRole('admin'), 403, 'Gunakan menu Sesi Perangkat untuk mengelola sesi admin.');

        $revokedCount = $user->tokens()->delete();

        AdminAuditLog::record(
            $request,
            'user_force_logout',
            'user',
            $user->id,
            "{$user->name} ({$user->email})",
            "Admin mencabut paksa {$revokedCount} token sesi aktif.",
        );

        return response()->json([
            'status' => 'success',
            'message' => $revokedCount > 0
                ? "{$revokedCount} sesi aktif milik {$user->name} berhasil dicabut paksa."
                : "{$user->name} saat ini tidak memiliki sesi login aktif.",
            'data' => ['revoked_tokens' => $revokedCount],
        ]);
    }

    public function disputes(Request $request): JsonResponse
    {
        $status = trim((string) $request->query('status', 'all'));

        $query = EscrowDispute::query()
            ->with(['reporter:id,name,email', 'resolver:id,name'])
            ->when($status !== '' && $status !== 'all', fn ($q) => $q->where('status', $status))
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 20), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (EscrowDispute $d) => $this->presentDispute($d))->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function resolveDispute(Request $request, EscrowDispute $dispute): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['resolved', 'rejected'])],
            'resolution_notes' => ['required', 'string', 'min:10', 'max:2000'],
        ], [
            'resolution_notes.required' => 'Catatan keputusan resolusi wajib diisi.',
            'resolution_notes.min' => 'Catatan keputusan minimal 10 karakter.',
        ]);

        abort_unless($dispute->status === 'open', 409, 'Laporan sengketa ini sudah diproses sebelumnya.');

        $dispute->update([
            'status' => $data['status'],
            'resolution_notes' => trim($data['resolution_notes']),
            'resolved_by' => $request->user()->id,
            'resolved_at' => now(),
        ]);

        $this->notifications->send(
            $dispute->reporter_id,
            'dispute_resolved',
            $data['status'] === 'resolved' ? 'Laporan Sengketa Diselesaikan' : 'Laporan Sengketa Ditutup',
            'Keputusan Admin: '.trim($data['resolution_notes']),
            '/settings/help-support',
        );

        AdminAuditLog::record(
            $request,
            $data['status'] === 'resolved' ? 'dispute_resolved' : 'dispute_rejected',
            'escrow_dispute',
            $dispute->id,
            "Sengketa #{$dispute->id} ({$dispute->category})",
            trim($data['resolution_notes']),
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Keputusan sengketa berhasil disimpan.',
            'data' => $this->presentDispute($dispute->fresh(['reporter:id,name,email', 'resolver:id,name'])),
        ]);
    }

    public function projects(Request $request): JsonResponse
    {
        $status = trim((string) $request->query('status', 'all'));
        $search = mb_strtolower(trim((string) $request->query('search', '')));

        $query = Project::query()
            ->with(['msme:id,name', 'msme.umkmProfile:id,user_id,business_name'])
            ->withCount('applications')
            ->when($status !== '' && $status !== 'all', fn ($q) => $q->where('status', $status))
            ->when($search !== '', function ($q) use ($search) {
                $like = '%'.$search.'%';
                $q->where(function ($inner) use ($like) {
                    $inner->whereRaw('LOWER(title) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(category) LIKE ?', [$like]);
                });
            })
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 20), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (Project $p) => [
                'id' => $p->id,
                'title' => $p->title,
                'category' => $p->category,
                'msme_name' => $p->msme?->umkmProfile?->business_name ?? $p->msme?->name ?? 'Mitra UMKM',
                'reward_tc' => (int) $p->reward_tc,
                'duration_label' => $p->duration_label,
                'status' => $p->status,
                'applications_count' => (int) ($p->applications_count ?? 0),
                'created_at' => $p->created_at?->toIso8601String(),
            ])->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function updateProjectStatus(Request $request, Project $project): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['open', 'cancelled'])],
            'reason' => ['nullable', 'string', 'max:500'],
        ]);

        abort_if(
            in_array($project->status, ['completed'], true),
            409,
            'Proyek yang sudah selesai tidak dapat diubah statusnya.'
        );

        $project->update(['status' => $data['status']]);

        $reason = trim((string) ($data['reason'] ?? ''));
        $this->notifications->send(
            $project->msme_id,
            'admin_project_moderation',
            $data['status'] === 'cancelled' ? 'Proyek Dinonaktifkan Admin' : 'Proyek Diaktifkan Kembali',
            $reason !== ''
                ? "Proyek \"{$project->title}\" diperbarui oleh Admin. Catatan: {$reason}"
                : "Status proyek \"{$project->title}\" telah diperbarui menjadi {$data['status']} oleh Admin.",
            '/msme/dashboard',
        );

        AdminAuditLog::record(
            $request,
            $data['status'] === 'cancelled' ? 'project_cancelled' : 'project_reopened',
            'project',
            $project->id,
            $project->title,
            $reason !== '' ? "Status: {$data['status']}. Alasan: {$reason}" : "Status diubah menjadi {$data['status']}.",
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Status proyek berhasil diperbarui.',
            'data' => [
                'id' => $project->id,
                'status' => $project->status,
            ],
        ]);
    }

    public function transactions(Request $request): JsonResponse
    {
        $type = trim((string) $request->query('type', 'all'));

        $query = TimeCoinTransaction::query()
            ->with(['wallet.user:id,name,email'])
            ->when($type !== '' && $type !== 'all', fn ($q) => $q->where('transaction_type', $type))
            ->latest('created_at')
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 25), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (TimeCoinTransaction $tx) => [
                ...WalletPresenter::transaction($tx),
                'owner_name' => $tx->wallet?->user?->name ?? 'Pengguna',
                'owner_email' => $tx->wallet?->user?->email ?? '',
            ])->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function auditLogs(Request $request): JsonResponse
    {
        $action = trim((string) $request->query('action', 'all'));

        $query = AdminAuditLog::query()
            ->with('admin:id,name,email')
            ->when($action !== '' && $action !== 'all', fn ($q) => $q->where('action', $action))
            ->latest('created_at')
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 30), 100));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (AdminAuditLog $log) => [
                'id' => $log->id,
                'admin_name' => $log->admin?->name ?? 'Admin',
                'admin_email' => $log->admin?->email ?? '',
                'action' => $log->action,
                'target_type' => $log->target_type,
                'target_id' => $log->target_id,
                'target_label' => $log->target_label,
                'details' => $log->details,
                'ip_address' => $log->ip_address,
                'created_at' => $log->created_at?->toIso8601String(),
            ])->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function securityAnomalies(): JsonResponse
    {
        $highValueCashOuts = CashOutRequest::query()
            ->with('user:id,name,email')
            ->where('status', 'pending_transfer')
            ->where('amount_tc', '>=', 300)
            ->latest('created_at')
            ->limit(15)
            ->get()
            ->map(fn (CashOutRequest $c) => [
                'severity' => 'high',
                'code' => 'high_value_cash_out',
                'title' => "Pencairan Nominal Tinggi ({$c->amount_tc} TC)",
                'description' => ($c->user?->name ?? 'Pengguna')." mengajukan pencairan ke {$c->bank_name} ({$c->account_number}) senilai {$c->amount_tc} TC.",
                'reference_id' => $c->id,
                'created_at' => $c->created_at?->toIso8601String(),
            ]);

        $frequentCashOutUserIds = CashOutRequest::query()
            ->where('created_at', '>=', now()->subDay())
            ->selectRaw('user_id, COUNT(*) as req_count, SUM(amount_tc) as total_tc')
            ->groupBy('user_id')
            ->havingRaw('COUNT(*) >= 2')
            ->get();

        $frequentUsers = User::query()
            ->whereIn('id', $frequentCashOutUserIds->pluck('user_id'))
            ->get()
            ->keyBy('id');

        $frequentAlerts = $frequentCashOutUserIds->map(function ($row) use ($frequentUsers) {
            $u = $frequentUsers->get($row->user_id);

            return [
                'severity' => 'medium',
                'code' => 'frequent_cash_out',
                'title' => "Frekuensi Cash-Out Tinggi ({$row->req_count}x / 24 jam)",
                'description' => ($u?->name ?? "User #{$row->user_id}")." mengajukan {$row->req_count} kali pencairan dalam 24 jam terakhir (total {$row->total_tc} TC).",
                'reference_id' => (int) $row->user_id,
                'created_at' => now()->toIso8601String(),
            ];
        });

        $largeTransfers = TimeCoinTransaction::query()
            ->with(['wallet.user:id,name,email'])
            ->where('transaction_type', 'transfer_out')
            ->where('amount', '>=', 500)
            ->where('created_at', '>=', now()->subDays(7))
            ->latest('created_at')
            ->limit(15)
            ->get()
            ->map(fn (TimeCoinTransaction $tx) => [
                'severity' => 'medium',
                'code' => 'large_transfer',
                'title' => "Transfer Besar ({$tx->amount} TC)",
                'description' => ($tx->wallet?->user?->name ?? 'Pengguna')." melakukan transfer keluar sebesar {$tx->amount} TC dalam 7 hari terakhir.",
                'reference_id' => $tx->id,
                'created_at' => $tx->created_at?->toIso8601String(),
            ]);

        $alerts = $highValueCashOuts->concat($frequentAlerts)->concat($largeTransfers)->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'summary' => [
                    'total_alerts' => $alerts->count(),
                    'high_severity_count' => $alerts->where('severity', 'high')->count(),
                    'suspended_users_count' => User::whereNotNull('suspended_at')->count(),
                    'open_disputes_count' => EscrowDispute::where('status', 'open')->count(),
                ],
                'alerts' => $alerts,
            ],
        ]);
    }

    public function confirmPassword(Request $request): JsonResponse
    {
        $data = $request->validate([
            'password' => ['required', 'string'],
        ]);

        if (! Hash::check($data['password'], $request->user()->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kata sandi administrator tidak sesuai.',
            ], 422);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Identitas administrator terverifikasi.',
        ]);
    }

    public function broadcastAnnouncement(Request $request): JsonResponse
    {
        $data = $request->validate([
            'target_role' => ['required', Rule::in(['all', 'student', 'msme', 'mentor'])],
            'title' => ['required', 'string', 'min:5', 'max:120'],
            'body' => ['required', 'string', 'min:10', 'max:1000'],
        ], [
            'title.min' => 'Judul pengumuman minimal 5 karakter.',
            'body.min' => 'Isi pengumuman minimal 10 karakter.',
        ]);

        $targetRole = $data['target_role'];
        $title = trim($data['title']);
        $body = trim($data['body']);

        $recipients = User::query()
            ->whereNull('suspended_at')
            ->whereDoesntHave('roleRecord', fn ($r) => $r->where('name', 'admin'))
            ->when($targetRole !== 'all', function ($q) use ($targetRole) {
                $q->where(function ($inner) use ($targetRole) {
                    $inner->whereHas('roleRecord', fn ($r) => $r->where('name', $targetRole))
                        ->orWhereHas('roles', fn ($r) => $r->where('name', $targetRole));
                });
            })
            ->get();

        foreach ($recipients as $recipient) {
            $this->notifications->send(
                $recipient,
                'system_announcement',
                $title,
                $body,
                '/notifications',
            );
        }

        AdminAuditLog::record(
            $request,
            'announcement_broadcast',
            'announcement',
            null,
            "{$title} (target: {$targetRole})",
            "Dikirim ke {$recipients->count()} pengguna aktif.",
        );

        return response()->json([
            'status' => 'success',
            'message' => "Pengumuman berhasil dikirim ke {$recipients->count()} pengguna.",
            'data' => [
                'recipients_count' => $recipients->count(),
                'target_role' => $targetRole,
            ],
        ]);
    }

    public function adjustUserWallet(Request $request, User $user): JsonResponse
    {
        abort_if($user->hasRole('admin'), 403, 'Saldo akun administrator tidak dapat disesuaikan.');

        $data = $request->validate([
            'direction' => ['required', Rule::in(['credit', 'debit'])],
            'amount_tc' => ['required', 'integer', 'min:1', 'max:100000'],
            'reason' => ['required', 'string', 'min:5', 'max:500'],
            'admin_password' => ['required', 'string'],
        ], [
            'reason.min' => 'Alasan penyesuaian saldo minimal 5 karakter.',
            'admin_password.required' => 'Kata sandi admin wajib diisi untuk penyesuaian saldo.',
        ]);

        if (! Hash::check($data['admin_password'], $request->user()->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kata sandi administrator tidak sesuai.',
            ], 422);
        }

        $direction = $data['direction'];
        $amount = (int) $data['amount_tc'];
        $reason = trim($data['reason']);

        $wallet = DB::transaction(function () use ($request, $user, $direction, $amount) {
            $wallet = TimeCoinWallet::query()->where('user_id', $user->id)->lockForUpdate()->first();
            if (! $wallet) {
                $wallet = TimeCoinWallet::create([
                    'user_id' => $user->id,
                    'balance' => 0,
                    'locked_balance' => 0,
                ]);
            }

            if ($direction === 'debit') {
                abort_if(
                    $wallet->balance < $amount,
                    409,
                    "Saldo bebas pengguna ({$wallet->balance} TC) tidak mencukupi untuk pemotongan {$amount} TC."
                );
                $wallet->decrement('balance', $amount);
            } else {
                $wallet->increment('balance', $amount);
            }

            TimeCoinTransaction::create([
                'wallet_id' => $wallet->id,
                'sender_id' => $direction === 'credit' ? $request->user()->id : $user->id,
                'recipient_id' => $direction === 'credit' ? $user->id : $request->user()->id,
                'transaction_type' => 'admin_adjustment',
                'direction' => $direction,
                'ledger_account' => 'balance',
                'amount' => $amount,
                'reference_type' => User::class,
                'reference_id' => $user->id,
                'status' => 'completed',
            ]);

            return $wallet->fresh();
        }, 3);

        $verb = $direction === 'credit' ? "ditambahkan +{$amount} TC" : "dipotong -{$amount} TC";
        $this->notifications->send(
            $user,
            'admin_wallet_adjustment',
            'Penyesuaian Saldo TimeCoin oleh Admin',
            "Saldo dompet Anda telah {$verb}. Catatan Admin: {$reason}",
            '/wallet',
        );

        AdminAuditLog::record(
            $request,
            'wallet_adjustment',
            'user',
            $user->id,
            "{$user->name} ({$direction} {$amount} TC)",
            "Saldo baru: {$wallet->balance} TC. Alasan: {$reason}",
        );

        return response()->json([
            'status' => 'success',
            'message' => "Saldo {$user->name} berhasil {$verb}.",
            'data' => [
                'user_id' => $user->id,
                'balance_tc' => (int) $wallet->balance,
                'locked_balance_tc' => (int) $wallet->locked_balance,
            ],
        ]);
    }

    public function mentoringClasses(Request $request): JsonResponse
    {
        $status = trim((string) $request->query('status', 'all'));
        $search = mb_strtolower(trim((string) $request->query('search', '')));

        $query = MentoringClass::query()
            ->with(['mentor:id,name,email'])
            ->withCount('enrollments')
            ->when($status !== '' && $status !== 'all', fn ($q) => $q->where('status', $status))
            ->when($search !== '', function ($q) use ($search) {
                $like = '%'.$search.'%';
                $q->where(function ($inner) use ($like) {
                    $inner->whereRaw('LOWER(topic) LIKE ?', [$like])
                        ->orWhereRaw('LOWER(description) LIKE ?', [$like]);
                });
            })
            ->latest('id');

        $paginated = $query->paginate(min((int) $request->integer('per_page', 15), 50));

        return response()->json([
            'status' => 'success',
            'data' => $paginated->getCollection()->map(fn (MentoringClass $c) => [
                'id' => $c->id,
                'topic' => $c->topic,
                'mentor_name' => $c->mentor?->name ?? 'Peer Mentor',
                'mentor_email' => $c->mentor?->email ?? '',
                'price_tc' => (int) $c->price_tc,
                'duration_label' => $c->effectiveDurationLabel(),
                'capacity' => (int) ($c->capacity ?? 0),
                'enrollments_count' => (int) ($c->enrollments_count ?? 0),
                'status' => $c->status,
                'created_at' => $c->created_at?->toIso8601String(),
            ])->values(),
            'meta' => [
                'current_page' => $paginated->currentPage(),
                'last_page' => $paginated->lastPage(),
                'total' => $paginated->total(),
            ],
        ]);
    }

    public function updateMentoringClassStatus(Request $request, MentoringClass $mentoringClass): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['open', 'cancelled'])],
            'reason' => ['nullable', 'string', 'max:500'],
        ]);

        $mentoringClass->update(['status' => $data['status']]);
        $reason = trim((string) ($data['reason'] ?? ''));

        $this->notifications->send(
            $mentoringClass->mentor_id,
            'admin_mentoring_moderation',
            $data['status'] === 'cancelled' ? 'Kelas Mentoring Dinonaktifkan Admin' : 'Kelas Mentoring Diaktifkan Kembali',
            $reason !== ''
                ? "Kelas \"{$mentoringClass->topic}\" diperbarui oleh Admin. Catatan: {$reason}"
                : "Status kelas \"{$mentoringClass->topic}\" diubah menjadi {$data['status']} oleh Admin.",
            '/mentor/dashboard',
        );

        AdminAuditLog::record(
            $request,
            $data['status'] === 'cancelled' ? 'mentoring_class_cancelled' : 'mentoring_class_reopened',
            'mentoring_class',
            $mentoringClass->id,
            $mentoringClass->topic,
            $reason !== '' ? "Status: {$data['status']}. Alasan: {$reason}" : "Status diubah menjadi {$data['status']}.",
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Status kelas mentoring berhasil diperbarui.',
            'data' => [
                'id' => $mentoringClass->id,
                'status' => $mentoringClass->status,
            ],
        ]);
    }

    public function rewards(): JsonResponse
    {
        $items = Reward::query()
            ->withCount('redemptions')
            ->latest('id')
            ->get()
            ->map(fn (Reward $r) => [
                'id' => $r->id,
                'title' => $r->title,
                'provider' => $r->provider,
                'description' => $r->description,
                'tc_price' => (int) $r->tc_price,
                'icon_key' => $r->icon_key,
                'stock' => (int) $r->stock,
                'is_active' => (bool) $r->is_active,
                'redemptions_count' => (int) ($r->redemptions_count ?? 0),
            ])
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => $items,
        ]);
    }

    public function storeReward(Request $request): JsonResponse
    {
        $data = $request->validate([
            'title' => ['required', 'string', 'min:3', 'max:150'],
            'provider' => ['required', 'string', 'min:2', 'max:120'],
            'description' => ['required', 'string', 'min:5', 'max:1000'],
            'tc_price' => ['required', 'integer', 'min:1', 'max:100000'],
            'stock' => ['required', 'integer', 'min:0', 'max:100000'],
            'icon_key' => ['nullable', 'string', 'max:50'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $reward = Reward::create([
            'title' => trim($data['title']),
            'provider' => trim($data['provider']),
            'description' => trim($data['description']),
            'tc_price' => (int) $data['tc_price'],
            'stock' => (int) $data['stock'],
            'icon_key' => $data['icon_key'] ?? 'card_giftcard',
            'is_active' => (bool) ($data['is_active'] ?? true),
        ]);

        AdminAuditLog::record(
            $request,
            'reward_created',
            'reward',
            $reward->id,
            $reward->title,
            "Provider: {$reward->provider}, Harga: {$reward->tc_price} TC, Stok: {$reward->stock}.",
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Item reward berhasil ditambahkan ke katalog.',
            'data' => [
                'id' => $reward->id,
                'title' => $reward->title,
                'provider' => $reward->provider,
                'description' => $reward->description,
                'tc_price' => (int) $reward->tc_price,
                'stock' => (int) $reward->stock,
                'is_active' => (bool) $reward->is_active,
            ],
        ], 201);
    }

    public function updateReward(Request $request, Reward $reward): JsonResponse
    {
        $data = $request->validate([
            'title' => ['sometimes', 'string', 'min:3', 'max:150'],
            'provider' => ['sometimes', 'string', 'min:2', 'max:120'],
            'description' => ['sometimes', 'string', 'min:5', 'max:1000'],
            'tc_price' => ['sometimes', 'integer', 'min:1', 'max:100000'],
            'stock' => ['sometimes', 'integer', 'min:0', 'max:100000'],
            'is_active' => ['sometimes', 'boolean'],
        ]);

        $reward->update($data);

        AdminAuditLog::record(
            $request,
            'reward_updated',
            'reward',
            $reward->id,
            $reward->title,
            "Harga: {$reward->tc_price} TC, Stok: {$reward->stock}, Aktif: ".($reward->is_active ? 'Ya' : 'Tidak').'.',
        );

        return response()->json([
            'status' => 'success',
            'message' => 'Item reward berhasil diperbarui.',
            'data' => [
                'id' => $reward->id,
                'title' => $reward->title,
                'provider' => $reward->provider,
                'description' => $reward->description,
                'tc_price' => (int) $reward->tc_price,
                'stock' => (int) $reward->stock,
                'is_active' => (bool) $reward->is_active,
            ],
        ]);
    }

    public function exportCsv(Request $request, string $resource): JsonResponse
    {
        $allowed = ['users', 'transactions', 'audit-logs'];
        abort_unless(in_array($resource, $allowed, true), 404, 'Jenis laporan CSV tidak ditemukan.');

        $rows = [];
        if ($resource === 'users') {
            $rows[] = ['ID', 'Nama', 'Email', 'Peran', 'Verifikasi', 'Dibekukan', 'Saldo TC', 'Escrow TC', 'Terdaftar'];
            $users = User::query()
                ->with(['roleRecord:id,name', 'roles:id,name', 'studentProfile', 'umkmProfile', 'mentorProfile', 'timeCoinWallet'])
                ->whereDoesntHave('roleRecord', fn ($r) => $r->where('name', 'admin'))
                ->latest('id')
                ->limit(1000)
                ->get();
            foreach ($users as $u) {
                $p = $this->presentUser($u);
                $rows[] = [
                    $p['id'],
                    $p['name'],
                    $p['email'],
                    $p['role'],
                    $p['verification_status'],
                    $p['is_suspended'] ? 'Ya' : 'Tidak',
                    $p['balance_tc'],
                    $p['locked_balance_tc'],
                    $p['created_at'] ?? '',
                ];
            }
        } elseif ($resource === 'transactions') {
            $rows[] = ['ID', 'Judul', 'Tipe', 'Arah', 'Nominal TC', 'Status', 'Pemilik', 'Email', 'Waktu'];
            $txs = TimeCoinTransaction::query()
                ->with(['wallet.user:id,name,email'])
                ->latest('created_at')
                ->latest('id')
                ->limit(1000)
                ->get();
            foreach ($txs as $tx) {
                $p = WalletPresenter::transaction($tx);
                $rows[] = [
                    $p['id'],
                    $p['title'],
                    $p['type'],
                    $p['direction'],
                    $p['amount'],
                    $p['status'],
                    $tx->wallet?->user?->name ?? 'Pengguna',
                    $tx->wallet?->user?->email ?? '',
                    $p['created_at'] ?? '',
                ];
            }
        } else {
            $rows[] = ['ID', 'Admin', 'Aksi', 'Target', 'Detail', 'IP Address', 'Waktu'];
            $logs = AdminAuditLog::query()
                ->with('admin:id,name,email')
                ->latest('created_at')
                ->latest('id')
                ->limit(1000)
                ->get();
            foreach ($logs as $log) {
                $rows[] = [
                    $log->id,
                    $log->admin?->name ?? 'Admin',
                    $log->action,
                    $log->target_label ?? '',
                    $log->details ?? '',
                    $log->ip_address ?? '',
                    $log->created_at?->toIso8601String() ?? '',
                ];
            }
        }

        $stream = fopen('php://temp', 'r+');
        foreach ($rows as $row) {
            fputcsv($stream, $row);
        }
        rewind($stream);
        $csv = stream_get_contents($stream) ?: '';
        fclose($stream);

        AdminAuditLog::record(
            $request,
            'csv_exported',
            'report',
            null,
            "Export CSV: {$resource}",
            'Total '.max(count($rows) - 1, 0).' baris diekspor.',
        );

        return response()->json([
            'status' => 'success',
            'data' => [
                'filename' => 'talentsync_'.str_replace('-', '_', $resource).'_'.now()->format('Ymd_His').'.csv',
                'rows_count' => max(count($rows) - 1, 0),
                'csv' => $csv,
            ],
        ]);
    }

    private function presentUser(User $u): array
    {
        $primaryRole = $u->roleRecord?->name ?? 'student';
        $allRoles = $u->roles->pluck('name')->prepend($primaryRole)->unique()->values()->all();

        $verificationStatus = match ($primaryRole) {
            'msme' => ($u->umkmProfile?->is_verified ?? false) ? 'approved' : 'pending',
            'mentor' => $u->mentorProfile?->verification_status ?? 'pending',
            default => $u->studentProfile?->ktm_verification_status ?? 'pending',
        };

        $subtitle = match ($primaryRole) {
            'msme' => trim(($u->umkmProfile?->business_name ?? 'UMKM').' · '.($u->umkmProfile?->business_sector ?? 'Usaha')),
            'mentor' => $u->mentorProfile?->title_headline ?? 'Peer Mentor TalentSync',
            default => trim(($u->studentProfile?->university ?? 'Mahasiswa').' · '.($u->studentProfile?->student_id_number ?? '-')),
        };

        $isPremium = match ($primaryRole) {
            'msme' => (bool) ($u->umkmProfile?->is_premium ?? false),
            'mentor' => (bool) ($u->mentorProfile?->is_premium ?? false),
            default => false,
        };

        return [
            'id' => $u->id,
            'name' => $u->name,
            'email' => $u->email,
            'role' => $primaryRole,
            'roles' => $allRoles,
            'subtitle' => $subtitle,
            'verification_status' => $verificationStatus,
            'is_premium' => $isPremium,
            'is_suspended' => $u->isSuspended(),
            'suspended_reason' => $u->suspended_reason,
            'suspended_at' => $u->suspended_at?->toIso8601String(),
            'active_sessions_count' => (int) ($u->tokens_count ?? 0),
            'balance_tc' => (int) ($u->timeCoinWallet?->balance ?? 0),
            'locked_balance_tc' => (int) ($u->timeCoinWallet?->locked_balance ?? 0),
            'created_at' => $u->created_at?->toIso8601String(),
        ];
    }

    private function presentDispute(EscrowDispute $d): array
    {
        $refLabel = match ($d->reference_type) {
            Project::class => 'Proyek UMKM',
            \App\Models\MentoringEnrollment::class => 'Sesi Mentoring',
            default => 'Dompet TimeCoin',
        };

        return [
            'id' => $d->id,
            'reporter_name' => $d->reporter?->name ?? 'Pengguna',
            'reporter_email' => $d->reporter?->email ?? '',
            'reference_type_label' => $refLabel,
            'reference_id' => $d->reference_id,
            'category' => $d->category,
            'description' => $d->description,
            'status' => $d->status,
            'resolution_notes' => $d->resolution_notes,
            'resolved_by_name' => $d->resolver?->name,
            'resolved_at' => $d->resolved_at?->toIso8601String(),
            'created_at' => $d->created_at?->toIso8601String(),
        ];
    }
}
