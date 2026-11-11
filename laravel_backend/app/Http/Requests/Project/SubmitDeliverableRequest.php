<?php

namespace App\Http\Requests\Project;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\File;

class SubmitDeliverableRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'submission_format' => ['sometimes', 'in:link,file,note'],
            'deliverable_url' => ['nullable', 'url', 'max:2048'],
            'deliverable_file' => ['sometimes', File::types(['zip', 'pdf', 'png', 'jpg', 'jpeg', 'webp'])->max(10 * 1024)],
            'submission_notes' => ['nullable', 'string', 'max:5000'],
            'attachment_links' => ['sometimes', 'array'],
            'attachment_links.*' => ['string', 'max:2048'],
        ];
    }

    public function withValidator($validator): void
    {
        $validator->after(function ($validator) {
            $hasUrl = filled($this->input('deliverable_url'));
            $hasNotes = filled($this->input('submission_notes'));
            $hasFile = $this->hasFile('deliverable_file');
            $hasLinks = is_array($this->input('attachment_links')) && count(array_filter($this->input('attachment_links'))) > 0;

            if (! $hasUrl && ! $hasNotes && ! $hasFile && ! $hasLinks) {
                $validator->errors()->add('deliverable_url', 'Lampirkan tautan hasil kerja, berkas, atau catatan pengerjaan.');
            }
        });
    }
}

