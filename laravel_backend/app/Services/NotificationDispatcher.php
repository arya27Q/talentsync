<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Str;

class NotificationDispatcher
{
    public function send(
        User|int $recipient,
        string $type,
        string $title,
        string $body,
        ?string $targetRoute = null,
        ?array $targetArgs = null,
    ): void {
        $user = $recipient instanceof User ? $recipient : User::find($recipient);
        if (! $user) {
            return;
        }

        $user->notifications()->create([
            'id' => (string) Str::uuid(),
            'type' => $type,
            'data' => [
                'type' => $type,
                'title' => $title,
                'body' => $body,
                'target_route' => $targetRoute,
                'target_args' => $targetArgs,
            ],
        ]);
    }
}

