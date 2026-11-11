<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\File;

class SwitchToMentorRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'selected_proof_ids' => ['sometimes', 'array'],
            'selected_proof_ids.*' => ['integer'],
            'teaching_skills' => ['required', 'array', 'min:1'],
            'teaching_skills.*' => ['required', 'string', 'max:80'],
            'title_headline' => ['nullable', 'string', 'max:150'],
            'bio' => ['nullable', 'string', 'max:5000'],
            'hourly_rate_tc' => ['nullable', 'integer', 'min:1', 'max:100000'],
            'portfolio_url' => ['nullable', 'url', 'max:2048'],
            'external_certificate_title' => ['nullable', 'string', 'max:200'],
            'external_certificate_issuer' => ['nullable', 'string', 'max:150'],
            'external_certificate_file' => ['sometimes', File::types(['pdf', 'jpg', 'jpeg', 'png', 'webp'])->max(5 * 1024)],
        ];
    }
}

