<?php

namespace App\Http\Requests\Wallet;

use Illuminate\Foundation\Http\FormRequest;

class TransferTimeCoinRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'recipient_identifier' => ['required', 'string', 'max:150'],
            'amount_tc' => ['required', 'integer', 'min:1', 'max:1000000'],
        ];
    }
}

