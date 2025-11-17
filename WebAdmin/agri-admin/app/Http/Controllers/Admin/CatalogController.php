<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CatalogItem;
use App\Models\Supplier;   // Cửa hàng VTNN
use App\Models\Product;    // Sản phẩm
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    public function index(Request $request)
    {
        $q = CatalogItem::with(['store', 'product']);

        // nếu có filter/tìm kiếm thì bạn giữ nguyên logic cũ ở đây...

        $items = $q->orderBy('_id', 'desc')->paginate(20);

        return view('catalog.index', compact('items'));
    }

    public function create()
    {
        $item    = new CatalogItem();
        $stores  = Supplier::orderBy('name')->get();
        $products = Product::orderBy('name')->get();

        return view('catalog.form', compact('item', 'stores', 'products'));
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'store_id'     => 'required',
            'product_id'   => 'required',
            'price'        => 'required|numeric|min:0',
            'discount_tn'  => 'required|numeric|min:0',
            'discount_ln'  => 'required|numeric|min:0',
            'stock'        => 'required|integer|min:0',
            'status'       => 'required|in:active,inactive',
        ]);

        CatalogItem::create($data);

        return redirect()
            ->route('catalog.index')
            ->with('success', 'Tạo Catalog VTNN thành công');
    }

    public function edit($id)
    {
        $item     = CatalogItem::findOrFail($id);
        $stores   = Supplier::orderBy('name')->get();
        $products = Product::orderBy('name')->get();

        return view('catalog.form', compact('item', 'stores', 'products'));
    }

    public function update(Request $r, $id)
    {
        $data = $r->validate([
            'store_id'     => 'required',
            'product_id'   => 'required',
            'price'        => 'required|numeric|min:0',
            'discount_tn'  => 'required|numeric|min:0',
            'discount_ln'  => 'required|numeric|min:0',
            'stock'        => 'required|integer|min:0',
            'status'       => 'required|in:active,inactive',
        ]);

        $item = CatalogItem::findOrFail($id);
        $item->update($data);

        return redirect()
            ->route('catalog.index')
            ->with('success', 'Cập nhật Catalog VTNN thành công');
    }
}
