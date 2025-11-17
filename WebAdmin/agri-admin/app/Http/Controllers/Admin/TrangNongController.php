<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\TrangNong;
use App\Models\SeniorFarmer;  
use App\Http\Controllers\LaoNongController;
use App\Models\Supplier; // model Cửa hàng VTNN
use Illuminate\Http\Request;

class TrangNongController extends Controller
{
    public function index(Request $request)
    {
        $q = TrangNong::query();

        if ($s = $request->q) {
            $q->where('name', 'like', "%$s%")
              ->orWhere('phone', 'like', "%$s%");
        }

        $items = $q->orderBy('code')->paginate(20);

        return view('trangnong.index', compact('items'));
    }

    public function create()
    {
        $item = new TrangNong();

        // lấy danh sách lão nông & cửa hàng VTNN
        $laonongs = SeniorFarmer::orderBy('name')->get();        // field name của Lão nông
        $stores   = Supplier::orderBy('name')->get();       // hoặc store_name, shop_name...

        return view('trangnong.form', compact('item', 'laonongs', 'stores'));
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'name'       => 'required|string',
            'phone'      => 'required|string',
            'area'       => 'required|string',
            'laonong_id' => 'required',   // chọn từ dropdown
            'store_id'   => 'required',   // chọn từ dropdown
            'status'     => 'required',
        ]);

        $data['code'] = TrangNong::nextCode(); // TN001...

        TrangNong::create($data);

        return redirect()->route('trangnong.index')
            ->with('success', 'Tạo tráng nông mới thành công !!');
    }

    public function edit($id)
    {
        $item = TrangNong::findOrFail($id);

        $laonongs = SeniorFarmer::orderBy('name')->get();
        $stores   = Supplier::orderBy('name')->get();

        return view('trangnong.form', compact('item', 'laonongs', 'stores'));
    }

    public function update(Request $r, $id)
    {
        $data = $r->validate([
            'name'       => 'required|string',
            'phone'      => 'required|string',
            'area'       => 'required|string',
            'laonong_id' => 'required',
            'store_id'   => 'required',
            'status'     => 'required',
        ]);

        $item = TrangNong::findOrFail($id);
        $item->update($data);

        return redirect()->route('trangnong.index')
            ->with('success', 'Cập nhật tráng nông thành công !!');
    }
}
