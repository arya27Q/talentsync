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
            'avatar_file' => ['sometimes', File::image()->max(2 * 1024)],
            'remove_avatar' => ['sometimes', 'boolean'],
            'ktm_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'webp', 'pdf'])->max(5 * 1024)],
            'skills' => ['sometimes', 'array'],
            'skills.*' => ['required'],
        ];
    }
}

