<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\File;

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
            'linkedin_url' => ['nullable', 'url', 'max:2048'],
            'cv_url' => ['nullable', 'url', 'max:2048'],
            'cv_file' => ['nullable', File::types(['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'])->max(5 * 1024)],
            'github_url' => ['nullable', 'url', 'max:2048'],
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
            'linkedin_url.url' => 'Tautan LinkedIn harus berupa URL yang valid (diawali https://).',
            'cv_url.url' => 'Tautan CV harus berupa URL yang valid (diawali https://).',
            'cv_file.max' => 'Ukuran file CV maksimal 5 MB.',
            'github_url.url' => 'Tautan GitHub harus berupa URL yang valid (diawali https://).',
            'commitment_accepted.accepted' => 'Anda harus menyetujui komitmen pengerjaan proyek.',
        ];
    }
}
