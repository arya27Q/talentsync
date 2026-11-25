<?php

namespace App\Http\Controllers\Api\Msme;

use App\Http\Controllers\Controller;
use App\Http\Resources\WalletPresenter;
use App\Models\MsmeSubscription;
use App\Models\MsmeVoucherBarter;
use App\Models\Project;
use App\Models\Reward;
use App\Models\TimeCoinTransaction;
use App\Models\TimeCoinWallet;
use App\Models\UmkmProfile;
use App\Models\WalletTopUp;
use App\Services\NotificationDispatcher;
use App\Services\TimeCoinLedgerService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\Rules\File;

class MsmeFinanceController extends Controller
{
    public const PLAN_PRICES_IDR = [
        'monthly' => 49000,
        'yearly' => 490000,
    ];

    public function __construct(
        private readonly TimeCoinLedgerService $ledger,
        private readonly NotificationDispatcher $notifications,
    ) {
    }

    public function barters(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $wallet = TimeCoinWallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'locked_balance' => 0]
        );
        $isPremium = (bool) ($user->umkmProfile?->is_premium ?? false);

        $barters = MsmeVoucherBarter::query()
            ->with(['reward' => fn ($q) => $q->withCount('redemptions')])
            ->where('user_id', $user->id)
            ->latest('id')
            ->get()
            ->map(fn (MsmeVoucherBarter $b) => $this->presentBarter($b))
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => (int) $wallet->balance,
                'locked_balance_tc' => (int) $wallet->locked_balance,
                'is_premium' => $isPremium,
                'admin_fee_percent' => $isPremium ? 0 : 5,
                'barters' => $barters,
            ],
        ]);
    }

    public function storeBarter(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $data = $request->validate([
            'voucher_type' => ['required', 'string', 'in:free_product,discount,bundle'],
            'title' => ['required', 'string', 'min:3', 'max:150'],
            'quantity' => ['required', 'integer', 'min:1', 'max:100'],
            'value_idr' => ['required', 'integer', 'min:5000', 'max:500000'],
            'validity_days' => ['required', 'integer', 'in:30,60,90'],
            'is_guaranteed' => ['accepted'],
            'design_file' => ['sometimes', 'nullable', File::types(['jpg', 'jpeg', 'png'])->max(3 * 1024)],
        ], [
            'title.required' => 'Nama voucher wajib diisi.',
            'title.min' => 'Nama voucher minimal 3 karakter.',
            'quantity.min' => 'Jumlah voucher minimal 1.',
            'quantity.max' => 'Jumlah voucher maksimal 100 per pengajuan.',
            'value_idr.min' => 'Nilai per voucher minimal Rp5.000.',
            'is_guaranteed.accepted' => 'Centang pernyataan jaminan penukaran voucher sebelum melanjutkan.',
            'design_file.mimes' => 'Desain voucher hanya mendukung format PNG atau JPG/JPEG.',
            'design_file.max' => 'Ukuran desain voucher maksimal 3 MB.',
        ]);

        $designImageUrl = null;
        if ($request->hasFile('design_file')) {
            $storedPath = $request->file('design_file')->store('voucher-designs', 'public');
            /** @var \Illuminate\Filesystem\FilesystemAdapter $publicDisk */
            $publicDisk = Storage::disk('public');
            $designImageUrl = $publicDisk->url($storedPath);
        }

        $tcPerVoucher = max(1, (int) round(((int) $data['value_idr']) / 1000));
        $quantity = (int) $data['quantity'];
        $totalTc = $quantity * $tcPerVoucher;
        $validityDays = (int) $data['validity_days'];
        $expiresAt = now()->addDays($validityDays);

        $businessName = $user->umkmProfile?->business_name ?: $user->name;
        $typeLabel = match ($data['voucher_type']) {
            'discount' => 'Voucher Diskon',
            'bundle' => 'Paket Hemat',
            default => 'Gratis Produk',
        };
        $iconKey = match ($data['voucher_type']) {
            'discount' => 'local_offer',
            'bundle' => 'redeem',
            default => 'local_cafe',
        };

        $result = DB::transaction(function () use (
            $user,
            $data,
            $designImageUrl,
            $tcPerVoucher,
            $quantity,
            $totalTc,
            $validityDays,
            $expiresAt,
            $businessName,
            $typeLabel,
            $iconKey,
        ) {
            $reward = Reward::create([
                'title' => trim($data['title']),
                'provider' => $businessName,
                'description' => "{$typeLabel} dari {$businessName} · Berlaku {$validityDays} hari sejak diterbitkan.",
                'tc_price' => $tcPerVoucher,
                'icon_key' => $iconKey,
                'stock' => $quantity,
                'is_active' => true,
            ]);

            $barter = MsmeVoucherBarter::create([
                'user_id' => $user->id,
                'reward_id' => $reward->id,
                'voucher_type' => $data['voucher_type'],
                'title' => trim($data['title']),
                'quantity' => $quantity,
                'value_idr' => (int) $data['value_idr'],
                'tc_per_voucher' => $tcPerVoucher,
                'total_tc' => $totalTc,
                'validity_days' => $validityDays,
                'expires_at' => $expiresAt,
                'design_image_url' => $designImageUrl,
                'is_guaranteed' => true,
                'status' => 'active',
            ]);

            $wallet = TimeCoinWallet::firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 0, 'locked_balance' => 0]
            );
            $lockedWallet = TimeCoinWallet::whereKey($wallet->id)->lockForUpdate()->firstOrFail();
            $this->ledger->recordVoucherBarter($lockedWallet, $user->id, $totalTc, $barter);

            $barter->load(['reward' => fn ($q) => $q->withCount('redemptions')]);

            return [
                'barter' => $barter,
                'balance_tc' => (int) $lockedWallet->fresh()->balance,
            ];
        }, 3);

        $this->notifications->send(
            $user,
            'msme_voucher_barter',
            "+{$totalTc} TC dari Barter Voucher",
            "Voucher \"{$result['barter']->title}\" ({$quantity} pcs) resmi tayang di Katalog Hadiah mahasiswa.",
            '/msme/barter',
        );

        return response()->json([
            'status' => 'success',
            'message' => "Voucher \"{$result['barter']->title}\" berhasil dibarter menjadi +{$totalTc} TimeCoin!",
            'data' => [
                'barter' => $this->presentBarter($result['barter']),
                'balance_tc' => $result['balance_tc'],
            ],
        ], 201);
    }

    public function topUp(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $data = $request->validate([
            'amount_tc' => ['required', 'integer', 'min:10', 'max:100000'],
            'payment_channel' => ['sometimes', 'string', 'in:qris_sandbox,va_bca,va_mandiri,gopay'],
        ], [
            'amount_tc.min' => 'Minimal top-up adalah 10 TC (Rp10.000).',
            'amount_tc.max' => 'Maksimal top-up adalah 100.000 TC per transaksi.',
        ]);

        $amountTc = (int) $data['amount_tc'];
        $channel = $data['payment_channel'] ?? 'qris_sandbox';
        $isPremium = (bool) ($user->umkmProfile?->is_premium ?? false);
        $adminFeePercent = $isPremium ? 0 : 5;
        $baseIdr = $amountTc * 1000;
        $adminFeeIdr = (int) round($baseIdr * $adminFeePercent / 100);
        $totalPayableIdr = $baseIdr + $adminFeeIdr;

        $result = DB::transaction(function () use ($user, $amountTc, $totalPayableIdr, $channel) {
            $wallet = TimeCoinWallet::firstOrCreate(
                ['user_id' => $user->id],
                ['balance' => 0, 'locked_balance' => 0]
            );
            $lockedWallet = TimeCoinWallet::whereKey($wallet->id)->lockForUpdate()->firstOrFail();

            $topUp = WalletTopUp::create([
                'user_id' => $user->id,
                'amount_tc' => $amountTc,
                'amount_idr' => $totalPayableIdr,
                'payment_channel' => $channel,
                'payment_reference' => 'UMKM-TOP-'.strtoupper(Str::random(8)),
                'status' => 'completed',
            ]);

            $this->ledger->recordTopUp($lockedWallet, $user->id, $amountTc, $topUp);

            return [
                'top_up' => $topUp,
                'balance_tc' => (int) $lockedWallet->fresh()->balance,
            ];
        }, 3);

        $this->notifications->send(
            $user,
            'msme_wallet_top_up',
            "+{$amountTc} TC Top-Up Berhasil",
            "Saldo usaha bertambah {$amountTc} TC (Admin {$adminFeePercent}% · Total Rp".number_format($totalPayableIdr, 0, ',', '.').').',
            '/msme/barter',
        );

        return response()->json([
            'status' => 'success',
            'message' => "Top-Up {$amountTc} TC berhasil masuk ke saldo usaha.",
            'data' => [
                'id' => $result['top_up']->id,
                'amount_tc' => $amountTc,
                'base_idr' => $baseIdr,
                'admin_fee_percent' => $adminFeePercent,
                'admin_fee_idr' => $adminFeeIdr,
                'total_payable_idr' => $totalPayableIdr,
                'payment_channel' => $channel,
                'payment_reference' => $result['top_up']->payment_reference,
                'balance_tc' => $result['balance_tc'],
                'is_premium' => $isPremium,
            ],
        ], 201);
    }

    public function transactions(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $wallet = TimeCoinWallet::firstOrCreate(
            ['user_id' => $user->id],
            ['balance' => 0, 'locked_balance' => 0]
        );
        $isPremium = (bool) ($user->umkmProfile?->is_premium ?? false);

        $transactions = TimeCoinTransaction::where('wallet_id', $wallet->id)
            ->where('ledger_account', 'balance')
            ->latest('created_at')
            ->latest('id')
            ->limit(30)
            ->get()
            ->map(fn (TimeCoinTransaction $tx) => WalletPresenter::transaction($tx))
            ->values();

        $totalIncome = (int) TimeCoinTransaction::where('wallet_id', $wallet->id)
            ->where('ledger_account', 'balance')
            ->where('direction', 'credit')
            ->sum('amount');

        $totalExpense = (int) TimeCoinTransaction::where('wallet_id', $wallet->id)
            ->where('ledger_account', 'balance')
            ->where('direction', 'debit')
            ->sum('amount');

        return response()->json([
            'status' => 'success',
            'data' => [
                'balance_tc' => (int) $wallet->balance,
                'locked_balance_tc' => (int) $wallet->locked_balance,
                'estimated_idr' => (int) $wallet->balance * 1000,
                'total_income_tc' => $totalIncome,
                'total_expense_tc' => $totalExpense,
                'is_premium' => $isPremium,
                'admin_fee_percent' => $isPremium ? 0 : 5,
                'monthly_quota_tc' => (int) ($user->umkmProfile?->monthly_quota_tc ?? ($isPremium ? 500 : 20)),
                'transactions' => $transactions,
            ],
        ]);
    }

    public function subscription(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $isPremium = (bool) ($user->umkmProfile?->is_premium ?? false);

        $activeSub = MsmeSubscription::where('user_id', $user->id)
            ->where('status', 'active')
            ->where('expires_at', '>', now())
            ->latest('id')
            ->first();

        $activeProjectsCount = Project::where('msme_id', $user->id)
            ->whereIn('status', ['open', 'in_progress', 'review'])
            ->count();
        $slotsMax = $isPremium ? 10 : 2;

        return response()->json([
            'status' => 'success',
            'data' => [
                'is_premium' => $isPremium,
                'slots_used' => min($slotsMax, $activeProjectsCount),
                'slots_max' => $slotsMax,
                'admin_fee_percent' => $isPremium ? 0 : 5,
                'monthly_quota_tc' => (int) ($user->umkmProfile?->monthly_quota_tc ?? ($isPremium ? 500 : 20)),
                'active_subscription' => $activeSub ? $this->presentSubscription($activeSub) : null,
                'plans' => [
                    [
                        'plan_type' => 'monthly',
                        'label' => 'Bulanan',
                        'price_idr' => self::PLAN_PRICES_IDR['monthly'],
                        'duration_label' => '30 Hari',
                        'savings_label' => null,
                    ],
                    [
                        'plan_type' => 'yearly',
                        'label' => 'Tahunan',
                        'price_idr' => self::PLAN_PRICES_IDR['yearly'],
                        'duration_label' => '365 Hari',
                        'savings_label' => 'Hemat 2 bulan',
                    ],
                ],
            ],
        ]);
    }

    public function subscribe(Request $request): JsonResponse
    {
        $user = $request->user()->load('umkmProfile');
        $data = $request->validate([
            'plan_type' => ['required', 'string', 'in:monthly,yearly'],
            'payment_channel' => ['sometimes', 'string', 'in:qris_sandbox,va_bca,va_mandiri,gopay'],
        ]);

        $planType = $data['plan_type'];
        $channel = $data['payment_channel'] ?? 'qris_sandbox';
        $priceIdr = self::PLAN_PRICES_IDR[$planType];
        $startsAt = now();
        $expiresAt = $planType === 'yearly' ? now()->addYear() : now()->addMonth();

        $subscription = DB::transaction(function () use ($user, $planType, $priceIdr, $channel, $startsAt, $expiresAt) {
            MsmeSubscription::where('user_id', $user->id)
                ->where('status', 'active')
                ->update(['status' => 'replaced']);

            $sub = MsmeSubscription::create([
                'user_id' => $user->id,
                'plan_type' => $planType,
                'price_idr' => $priceIdr,
                'payment_channel' => $channel,
                'payment_reference' => 'PRO-'.strtoupper(Str::random(10)),
                'status' => 'active',
                'starts_at' => $startsAt,
                'expires_at' => $expiresAt,
            ]);

            $profile = $user->umkmProfile ?: UmkmProfile::create([
                'user_id' => $user->id,
                'business_name' => $user->name,
                'business_sector' => 'UMKM',
                'address' => 'Surabaya',
                'city' => 'Surabaya',
                'is_verified' => true,
            ]);

            $profile->update([
                'is_premium' => true,
                'monthly_quota_tc' => 500,
            ]);

            return $sub;
        }, 3);

        $planLabel = $planType === 'yearly' ? 'Tahunan' : 'Bulanan';
        $this->notifications->send(
            $user,
            'msme_partner_pro_activated',
            'Partner Pro Aktif!',
            "Paket Partner Pro ({$planLabel}) aktif hingga {$expiresAt->format('d M Y')}. Nikmati 10 slot proyek & 0% biaya admin top-up.",
            '/msme/upgrade-pro',
        );

        return response()->json([
            'status' => 'success',
            'message' => "Selamat! Akun tokomu kini aktif sebagai Partner Pro ({$planLabel}). Nikmati 10 slot proyek & 0% biaya admin.",
            'data' => [
                'is_premium' => true,
                'slots_max' => 10,
                'admin_fee_percent' => 0,
                'monthly_quota_tc' => 500,
                'active_subscription' => $this->presentSubscription($subscription),
            ],
        ], 201);
    }

    private function presentBarter(MsmeVoucherBarter $barter): array
    {
        $redeemedCount = (int) ($barter->reward?->redemptions_count ?? 0);
        $remainingStock = (int) ($barter->reward?->stock ?? max(0, $barter->quantity - $redeemedCount));
        $effectiveStatus = $remainingStock === 0
            ? 'redeemed_all'
            : ($barter->expires_at && $barter->expires_at->isPast() ? 'expired' : $barter->status);

        return [
            'id' => $barter->id,
            'reward_id' => $barter->reward_id,
            'voucher_type' => $barter->voucher_type,
            'title' => $barter->title,
            'quantity' => (int) $barter->quantity,
            'redeemed_count' => $redeemedCount,
            'remaining_stock' => $remainingStock,
            'value_idr' => (int) $barter->value_idr,
            'tc_per_voucher' => (int) $barter->tc_per_voucher,
            'total_tc' => (int) $barter->total_tc,
            'validity_days' => (int) $barter->validity_days,
            'expires_at' => $barter->expires_at?->toIso8601String(),
            'design_image_url' => $barter->design_image_url,
            'status' => $effectiveStatus,
            'created_at' => $barter->created_at?->toIso8601String(),
        ];
    }

    private function presentSubscription(MsmeSubscription $sub): array
    {
        return [
            'id' => $sub->id,
            'plan_type' => $sub->plan_type,
            'plan_label' => $sub->plan_type === 'yearly' ? 'Tahunan' : 'Bulanan',
            'price_idr' => (int) $sub->price_idr,
            'payment_channel' => $sub->payment_channel,
            'payment_reference' => $sub->payment_reference,
            'status' => $sub->status,
            'starts_at' => $sub->starts_at?->toIso8601String(),
            'expires_at' => $sub->expires_at?->toIso8601String(),
        ];
    }
}
