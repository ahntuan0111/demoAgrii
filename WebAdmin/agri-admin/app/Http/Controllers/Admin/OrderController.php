<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    // Danh sách đơn
    public function index(Request $request)
    {
        $q = Order::query();

        // Tìm kiếm theo mã đơn / tên nông dân
        if ($s = $request->input('q')) {
            $q->where(function ($x) use ($s) {
                $x->where('code', 'like', "%{$s}%")
                  ->orWhere('farmer_name', 'like', "%{$s}%");
            });
        }

        // Filter trạng thái (nếu có)
        if ($status = $request->input('status')) {
            $q->where('status', (int) $status);
        }

        // Filter khu vực (nếu có)
        if ($region = $request->input('region')) {
            $q->where('region', $region);
        }

        $orders = $q->orderBy('_id', 'desc')->paginate(20);

        $statusOptions = Order::STATUS_LABELS;

        return view('orders.index', compact('orders', 'statusOptions'));
    }

    // Chi tiết đơn + timeline
    public function show($id)
    {
        // MongoDB: _id, MySQL: id => findOrFail đều được
        $order = Order::with('items')->findOrFail($id);

        // 11 bước timeline
        $steps = Order::STATUS_LABELS;

        return view('orders.show', compact('order', 'steps'));
    }
}