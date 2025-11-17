<?php

namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class TrangNong extends Model
{
    protected $connection = 'mongodb';
    protected $collection  = 'trang_nongs'; // tên collection thật

    protected $fillable = ['code', 'name', 'phone', 'region', 'status'];

    protected $attributes = [
        'status' => 'active',
    ];
}
