<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\SeniorFarmer;
use Illuminate\Http\Request;

class LaoNongController extends Controller
{
    public function index(Request $request){
        $q = SeniorFarmer::query();
        if ($s = $request->q) {
            $q->where(function($x) use ($s){
                $x->where('name','like',"%$s%");
            });
        }
        $items = $q->orderBy('_id','desc')->paginate(20);
        return view('laonong.index', compact('items'));
    }
    public function create(){ $item = new SeniorFarmer(); return view('laonong.form', compact('item')); }
   public function store(Request $request)
    {
        $data = $request->validate([
            'name'   => 'required',
            'phone'  => 'required',
            'region' => 'nullable',
            'status' => 'nullable',
        ]);

        // Model tự sinh mã LN*** trong SeniorFarmer::creating(...)
        SeniorFarmer::create($data);

        // ĐỪNG dùng route() nữa, redirect thẳng về URL list
        return redirect('/admin/lao-nong')
            ->with('success', 'Tạo lão nông thành công');
    }
    public function edit(SeniorFarmer $lao_nong){ $item = $lao_nong; return view('laonong.form', compact('item')); }
 public function update(Request $request, $id)
    {
        $lao_nong = SeniorFarmer::findOrFail($id);

        $data = $request->validate([
            'name'   => 'required',
            'phone'  => 'required',
            'region' => 'nullable',
            'status' => 'nullable',
        ]);

        $lao_nong->update($data);

        return redirect('/admin/lao-nong')
            ->with('success', 'Cập nhật lão nông thành công');
    }

    public function destroy(SeniorFarmer $lao_nong){
        $lao_nong->delete();
        return redirect()->route('laonong.index')->with('success','Đã xoá Lão nông thành công !!');
    }
}
