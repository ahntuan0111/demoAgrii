<?php
namespace App\Models;
use MongoDB\Laravel\Eloquent\Model;

class Product extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'products';
    protected $fillable = [
        'sku','name','category','unit','list_price','description','status',
        'override_ln','stock','vtnn_name'
    ];
    protected $casts = [
        'list_price' => 'float',
        'override_ln' => 'float',
        'stock' => 'int',
    ];
    protected $attributes = ['status' => 'active'];
}
