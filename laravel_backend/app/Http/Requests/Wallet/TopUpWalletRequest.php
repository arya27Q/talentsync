<?php

namespace App\Http\Requests\Wallet;

use Illuminate\Foundation\Http\FormRequest;

class TopUpWalletRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'amount_tc' => ['required', 'integer', 'min:10', 'max:100000'],
            'payment_channel' => ['sometimes', 'string', 'in:qris_sandbox,va_bca,va_mandiri,gopay'],
        ];
    }
}

