<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\File;

class UpdateStudentProfileRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['sometimes', 'required', 'string', 'max:150'],
            'headline' => ['sometimes', 'nullable', 'string', 'max:150'],
            'bio' => ['sometimes', 'nullable', 'string', 'max:2000'],
            'university' => ['sometimes', 'required', 'string', 'max:150'],
            'major' => ['sometimes', 'required', 'string', 'max:100'],
            'cohort_year' => ['sometimes', 'nullable', 'string', 'max:20'],
            'semester' => ['sometimes', 'nullable', 'integer', 'min:1', 'max:14'],
            'linkedin_url' => ['sometimes', 'nullable', 'string', 'max:255'],
            'github_username' => ['sometimes', 'nullable', 'string', 'max:100'],
            'is_public_profile' => ['sometimes', 'boolean'],
            'is_open_for_projects' => ['sometimes', 'boolean'],
            'avatar_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png'])->max(3 * 1024)],
            'avatar_url' => ['sometimes', 'nullable', 'string', 'max:2048'],
            'remove_avatar' => ['sometimes', 'boolean'],
            'ktm_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'pdf'])->max(5 * 1024)],
            'skills' => ['sometimes', 'array'],
            'skills.*' => ['required'],
        ];
    }

    public function messages(): array
    {
        return [
            'avatar_file.mimes' => 'Format foto profil hanya mendukung PNG atau JPG/JPEG.',
            'avatar_file.max' => 'Ukuran foto profil maksimal 3 MB.',
            'ktm_file.mimes' => 'Format berkas KTM harus PNG, JPG, atau PDF.',
            'ktm_file.max' => 'Ukuran berkas KTM maksimal 5 MB.',
        ];
    }
}

