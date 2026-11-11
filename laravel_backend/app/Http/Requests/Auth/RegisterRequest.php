<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\File;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:150'],
            'email' => ['required', 'email', 'max:150', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'role' => ['required', 'in:student,msme'],
            'university' => ['required_if:role,student', 'nullable', 'string', 'max:150'],
            'major' => ['required_if:role,student', 'nullable', 'string', 'max:100'],
            'student_id_number' => ['required_if:role,student', 'nullable', 'string', 'max:50', 'unique:student_profiles,student_id_number'],
            'ktm_document_url' => ['nullable', 'url', 'max:2048'],
            'ktm_file' => ['sometimes', File::types(['jpg', 'jpeg', 'png', 'webp', 'pdf'])->max(5 * 1024)],
            'avatar_file' => ['sometimes', File::image()->max(2 * 1024)],
            'cohort_year' => ['nullable', 'string', 'max:20'],
            'bio' => ['nullable', 'string', 'max:2000'],
            'skills' => ['sometimes', 'array'],
            'skills.*' => ['string', 'max:80'],
            'business_name' => ['required_if:role,msme', 'nullable', 'string', 'max:150'],
            'business_sector' => ['required_if:role,msme', 'nullable', 'string', 'max:100'],
            'address' => ['required_if:role,msme', 'nullable', 'string', 'max:5000'],
            'business_document_url' => ['nullable', 'url', 'max:2048'],
        ];
    }

    public function messages(): array
    {
        return [
            'student_id_number.unique' => 'NIM sudah terdaftar pada akun lain.',
            'email.unique' => 'Alamat email sudah terdaftar.',
            'ktm_file.max' => 'Ukuran dokumen KTM maksimal 5 MB.',
        ];
    }
}

