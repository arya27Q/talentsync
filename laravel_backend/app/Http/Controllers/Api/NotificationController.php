<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $notifications = $user->notifications()
            ->latest()
            ->paginate(min((int) $request->integer('per_page', 30), 100));

        return response()->json([
            'status' => 'success',
            'data' => $notifications->getCollection()->map(fn ($item) => [
                'id' => $item->id,
                'type' => $item->data['type'] ?? $item->type,
                'title' => $item->data['title'] ?? 'Notifikasi',
                'body' => $item->data['body'] ?? '',
                'target_route' => $item->data['target_route'] ?? null,
                'target_args' => $item->data['target_args'] ?? null,
                'is_read' => $item->read_at !== null,
                'read_at' => $item->read_at?->toIso8601String(),
                'created_at' => $item->created_at?->toIso8601String(),
            ]),
            'meta' => [
                'unread_count' => $user->unreadNotifications()->count(),
                'current_page' => $notifications->currentPage(),
                'last_page' => $notifications->lastPage(),
            ],
        ]);
    }

    public function markRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->whereKey($id)->firstOrFail();
        if ($notification->read_at === null) {
            $notification->markAsRead();
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $notification->id,
                'is_read' => true,
                'unread_count' => $request->user()->unreadNotifications()->count(),
            ],
        ]);
    }

    public function markAllRead(Request $request): JsonResponse
    {
        $request->user()->unreadNotifications->markAsRead();

        return response()->json([
            'status' => 'success',
            'message' => 'Semua notifikasi ditandai sudah dibaca.',
            'data' => ['unread_count' => 0],
        ]);
    }
}

