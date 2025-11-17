<?php
namespace App\Models;
use MongoDB\Laravel\Eloquent\Model;

class CatalogItem extends Model
{
    protected $connection = 'mongodb';
    protected $collection = 'catalog_items';   // tên collection của Catalog

    protected $fillable = [
        'store_id',      // id cửa hàng VTNN (Supplier)
        'product_id',    // id sản phẩm (Product)
        'price',
        'discount_tn',
        'discount_ln',
        'stock',
        'status',
    ];

    // Cửa hàng VTNN
    public function store()
    {
        return $this->belongsTo(Supplier::class, 'store_id');
    }

    // Sản phẩm
    public function product()
    {
        return $this->belongsTo(Product::class, 'product_id');
    }
}