<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Farmer;
use App\Models\SeniorFarmer;
use App\Models\TrangNong;

class FarmerController extends Controller
{
    public function index(Request $request)
    {
        $q = Farmer::query();

        if ($s = $request->q) {
            $q->where(function ($x) use ($s) {
                $x->where('name', 'like', "%$s%")
                  ->orWhere('phone', 'like', "%$s%")
                  ->orWhere('code', 'like', "%$s%");
            });
        }

        $items = $q->orderBy('_id', 'desc')->paginate(20);

        return view('farmers.index', compact('items'));
    }

    public function create()
    {
        $item = new Farmer();

        // lấy danh sách Lão nông & Tráng nông
        $seniorFarmers = SeniorFarmer::orderBy('code')->get();
        $trangNongs    = TrangNong::orderBy('code')->get();

        return view('farmers.form', compact('item', 'seniorFarmers', 'trangNongs'));
    }

    public function store(Request $r)
    {
        $data = $r->validate([
            'name'            => 'required',
            'phone'           => 'required',
            'address'         => 'required',
            'region'          => 'required',
            'lao_nong_code'   => 'required',
            'trang_nong_code' => 'required',
        ]);

        // tự sinh mã NNC-***
        $data['code'] = $this->nextFarmerCode();

        $farmer = new Farmer($data);
        $farmer->save();

        return redirect()->route('farmers.index')
            ->with('success', 'Tạo nông dân thành công');
    }

    public function edit($id)
    {
        $item = Farmer::findOrFail($id);

        $seniorFarmers = SeniorFarmer::orderBy('code')->get();
        $trangNongs    = TrangNong::orderBy('code')->get();

        return view('farmers.form', compact('item', 'seniorFarmers', 'trangNongs'));
    }

    public function update(Request $r, $id)
    {
        $item = Farmer::findOrFail($id);

        $data = $r->validate([
            'name'            => 'required',
            'phone'           => 'required',
            'address'         => 'required',
            'region'          => 'required',
            'lao_nong_code'   => 'required',
            'trang_nong_code' => 'required',
        ]);

        $item->fill($data)->save();

        return redirect()->route('farmers.index')
            ->with('success', 'Cập nhật nông dân thành công');
    }

    private function nextFarmerCode()
    {
        // ví dụ: NNC-001, NNC-002…
        $last = Farmer::orderBy('code', 'desc')->first();
        if (!$last || !preg_match('/^NNC-(\d+)$/', $last->code, $m)) {
            return 'NNC-001';
        }
        $num = (int) $m[1] + 1;
        return 'NNC-' . str_pad($num, 3, '0', STR_PAD_LEFT);
    }
    public function destroy(Farmer $farmer){
        $farmer->delete();
        return redirect()->route('farmers.index')->with('success','Đã xoá nhà nông thành công !!');
    }
}
