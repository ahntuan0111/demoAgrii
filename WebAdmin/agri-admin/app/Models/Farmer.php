<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class Farmer extends Model
{
    // Dùng connection mongodb giống Supplier
    protected $connection = 'mongodb';

    // Tên collection trong Mongo (tùy DB của em đang tạo)
    protected $collection = 'farmers';

    // Các field được phép fill
    protected $fillable = [
        'code',            // mã nông dân: NNC-001,...
        'name',
        'phone',
        'address',
        'region',          // khu vực (Miền Bắc / Miền Trung / Miền Nam...)
        'lat',
        'lng',
        'trang_nong_code', // mã TN phụ trách (TN001,...)
        'lao_nong_code',   // mã LN phụ trách (LN001,...)
        'orders_count',    // tổng đơn
        'total_cost',      // tổng chi
        'status',
    ];

    // Giá trị mặc định
    protected $attributes = [
        'status'       => 'active',
        'orders_count' => 0,
        'total_cost'   => 0,
    ];
}
