<?php
namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Supplier;
use App\Models\CatalogItem;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    private const CATEGORIES = [
        'phan_bon' => 'Phân bón',
        'thuoc_bvtv' => 'Thuốc BVTV',
        'giong_cay_trong' => 'Giống cây trồng',
    ];

    public function index(Request $request){
        $q = Product::query();
        if ($s = $request->q) {
            $q->where(function($x) use ($s){
                $x->where('name','like',"%$s%")->orWhere('sku','like',"%$s%");
            });
        }
        if ($cat = $request->get('category')) $q->where('category',$cat);
        $items = $q->orderBy('_id','desc')->paginate(20);

        // Build CK map by (product_name | vtnn_name)
        $names = $items->pluck('name')->filter()->unique()->values()->all();
        $stores = $items->pluck('vtnn_name')->filter()->unique()->values()->all();
        $catalogMap = [];
        if ($names && $stores) {
            $catalogs = CatalogItem::whereIn('product_name', $names)
                        ->whereIn('vtnn_name', $stores)
                        ->get(['product_name','vtnn_name','discount_tn','discount_ln']);
            foreach ($catalogs as $c) {
                $key = ($c->product_name ?? '') . '|' . ($c->vtnn_name ?? '');
                $catalogMap[$key] = ['tn'=>$c->discount_tn, 'ln'=>$c->discount_ln];
            }
        }

        $categories = self::CATEGORIES;
        return view('products.index', compact('items','categories','catalogMap','cat'));
    }

    private function nextSku(?string $category): string
    {
        $prefixMap = ['phan_bon'=>'PHN','thuoc_bvtv'=>'TBV','giong_cay_trong'=>'GCT'];
        $prefix = $prefixMap[$category] ?? 'SKU';
        $max = Product::when($category, fn($q) => $q->where('category', $category))
            ->pluck('sku')->map(function($s) use ($prefix){
                $s = (string)$s;
                if (preg_match('/^'.preg_quote($prefix,'/').'-?(\d+)$/', $s, $m)) return (int)$m[1];
                if (preg_match('/(\d+)$/', $s, $m)) return (int)$m[1];
                return 0;
            })->max() ?? 0;
        return $prefix . '-' . str_pad((string)($max+1), 3, '0', STR_PAD_LEFT);
    }

    public function create(){
        $item = new Product();
        $categories = self::CATEGORIES;
        $suppliers = Supplier::orderBy('name')->pluck('name')->all();
        return view('products.form', compact('item','categories','suppliers'));
    }

    public function store(Request $r){
        $data = $r->validate([
            'name'=>'required',
            'category'=>'required|in:phan_bon,thuoc_bvtv,giong_cay_trong',
            'unit'=>'required',
            'list_price'=>'required|numeric',
            'vtnn_name'=>'required',
            'description'=>'nullable',
            'status'=>'nullable|in:active,inactive',
            'override_ln'=>'nullable|numeric',
            'stock'=>'nullable|integer',
        ]);
        $data['sku'] = $this->nextSku($r->input('category'));
        Product::create($data);
        return redirect()->route('products.index')->with('success','Đã thêm sản phẩm mới thành công !!');
    }

    public function edit(Product $product){
        $item = $product;
        $categories = self::CATEGORIES;
        $suppliers = Supplier::orderBy('name')->pluck('name')->all();
        return view('products.form', compact('item','categories','suppliers'));
    }

    public function update(Request $r, Product $product){
        $data = $r->validate([
            'name'=>'required',
            'category'=>'required|in:phan_bon,thuoc_bvtv,giong_cay_trong',
            'unit'=>'required',
            'list_price'=>'required|numeric',
            'vtnn_name'=>'required',
            'description'=>'nullable',
            'status'=>'nullable|in:active,inactive',
            'override_ln'=>'nullable|numeric',
            'stock'=>'nullable|integer',
        ]);
        $product->update($data);
        return redirect()->route('products.index')->with('success','Đã lưu thay đổi sản phẩm thành công !!');
    }

    public function destroy(Product $product){
        $product->delete();
        return redirect()->route('products.index')->with('success','Đã xoá sản phẩm thành công !!');
    }
}
