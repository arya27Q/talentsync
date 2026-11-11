<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;

class ApplyProjectRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'cover_letter' => ['required', 'string', 'min:20', 'max:5000'],
            'portfolio_ids' => ['sometimes', 'array'],
            'portfolio_ids.*' => ['integer'],
            'portfolio_link' => ['nullable', 'url', 'max:2048'],
            'timeline_commitment' => ['nullable', 'string', 'max:60'],
            'dedication_hours' => ['nullable', 'string', 'max:60'],
            'commitment_accepted' => ['required', 'accepted'],
        ];
    }

    public function messages(): array
    {
        return [
            'cover_letter.required' => 'Surat lamaran / pengantar wajib diisi.',
            'cover_letter.min' => 'Jelaskan kesiapan Anda minimal 20 karakter.',
            'commitment_accepted.accepted' => 'Anda harus menyetujui komitmen pengerjaan proyek.',
        ];
    }
}

