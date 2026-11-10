<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'role_id'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    public function mentorProfile()
    {
        return $this->hasOne(MentorProfile::class);
    }

    public function roleRecord()
    {
        return $this->belongsTo(Role::class, 'role_id');
    }

    public function studentProfile()
    {
        return $this->hasOne(StudentProfile::class);
    }

    public function umkmProfile()
    {
        return $this->hasOne(UmkmProfile::class);
    }

    public function hasRole(string $role): bool
    {
        return $this->roleRecord?->name === $role;
    }

    public function mentoringClasses()
    {
        return $this->hasMany(MentoringClass::class, 'mentor_id');
    }

    public function timeCoinWallet()
    {
        return $this->hasOne(TimeCoinWallet::class);
    }
}
