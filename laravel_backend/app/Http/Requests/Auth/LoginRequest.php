<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'identifier' => ['required_without:email', 'nullable', 'string', 'max:150'],
            'email' => ['required_without:identifier', 'nullable', 'email', 'max:150'],
            'password' => ['required', 'string'],
        ];
    }

    public function messages(): array
    {
        return [
            'identifier.required_without' => 'Akun belum terdaftar. Silakan lakukan pendaftaran terlebih dahulu.',
            'email.required_without' => 'Akun belum terdaftar. Silakan lakukan pendaftaran terlebih dahulu.',
            'password.required' => 'Kata sandi yang Anda masukkan salah. Harap periksa kembali.',
        ];
    }

    public function identifierValue(): string
    {
        return trim((string) ($this->input('identifier') ?: $this->input('email')));
    }
}

