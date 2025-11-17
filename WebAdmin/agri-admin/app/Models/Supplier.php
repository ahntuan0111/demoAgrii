<?php
namespace App\Models;
use MongoDB\Laravel\Eloquent\Model;

class Supplier extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'suppliers';
    protected $fillable = ['code','name','phone','address','lat','lng','status'];
    protected $attributes = ['status' => 'active'];
}
