// app/Models/OrderItem.php
namespace App\Models;

use MongoDB\Laravel\Eloquent\Model;

class OrderItem extends Model
{
    // Nếu dùng MongoDB:
    protected $connection = 'mongodb';
    protected $collection = 'order_items';

    protected $fillable = [
        'order_id',

        'product_id',
        'product_code',
        'product_name',

        'qty',
        'price',
        'subtotal',
    ];

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}