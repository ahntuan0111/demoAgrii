<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model; // nếu xài mongodb/laravel

class SeniorFarmer extends Model
{
    protected $collection = 'senior_farmers'; // hoặc tên collection bạn dùng

    protected $fillable = [
        'code',
        'name',
        'phone',
        'region',   // 👈 thêm dòng này
        'status',
    ];

    protected static function booted()
    {
        static::creating(function ($model) {
            if (!$model->code) {
                $last = static::orderBy('code', 'desc')->first();
                $nextNumber = 1;

                if ($last && preg_match('/LN(\d+)/', $last->code, $m)) {
                    $nextNumber = (int)$m[1] + 1;
                }

                $model->code = 'LN' . str_pad($nextNumber, 3, '0', STR_PAD_LEFT);
            }
        });
    }
}