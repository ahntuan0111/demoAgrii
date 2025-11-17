<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\Supplier;
use Illuminate\Http\Request;

class SupplierController extends Controller
{
    public function index(Request $request){
        $q = Supplier::query();
        if ($s = $request->q) {
            $q->where(function($x) use ($s){
                $x->where('name','like',"%$s%");
            });
        }
        $items = $q->orderBy('_id','desc')->paginate(20);
        return view('suppliers.index', compact('items'));
    }
    public function create(){ $item = new Supplier(); return view('suppliers.form', compact('item')); }
    public function store(Request $r){
        $data = $r->validate([
            'name'=>'required','phone'=>'required','address'=>'required',
            'lat'=>'nullable|numeric','lng'=>'nullable|numeric','status'=>'nullable|in:active,inactive'
        ]);
        $data['code'] = $r->input('code', uniqid('S'));
        Supplier::create($data);
        return redirect()->route('suppliers.index')->with('success','Tạo VTNN mới thành công !!');
    }
    public function edit(Supplier $supplier){ $item = $supplier; return view('suppliers.form', compact('item')); }
    public function update(Request $r, Supplier $supplier){
        $data = $r->validate([
            'name'=>'required','phone'=>'required','address'=>'required',
            'lat'=>'nullable|numeric','lng'=>'nullable|numeric','status'=>'nullable|in:active,inactive'
        ]);
        $supplier->update($data);
        return redirect()->route('suppliers.index')->with('success','Cập nhật VTNN thành công !!');
    }
    public function destroy(Supplier $supplier){
        $supplier->delete();
        return redirect()->route('suppliers.index')->with('success','Đã xoá VTNN thành công !!');
    }
}
