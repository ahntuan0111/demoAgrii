{{-- PATCH STAMP: vtnn_in_form_ck_from_catalog @ 2025-11-13 --}}
@extends('layouts.admin')
@section('content')
<div class="fixed inset-0 bg-slate-900/80 flex items-center justify-center">
  <div class="bg-white rounded-2xl w-full max-w-xl shadow-2xl">
    <div class="flex items-center justify-between px-6 py-4 border-b">
      <div class="font-semibold">{{ isset($item->_id) ? 'Cập nhật sản phẩm' : 'Thêm sản phẩm mới' }}</div>
      <a href="{{ route('products.index') }}" class="text-xl text-slate-400">×</a>
    </div>
    <form method="POST" action="{{ isset($item->_id) ? route('products.update',$item->_id) : route('products.store') }}" class="p-6 space-y-3">
      @csrf @if(isset($item->_id)) @method('PUT') @endif

      {{-- KHÔNG có trường CK LN / CK TN trong form; CK sẽ lấy theo Catalog VTNN --}}

      <label class='text-xs'>Tên sản phẩm *</label>
      <input name='name' value='{{ old("name",$item->name) }}' class='w-full px-3 py-2 border rounded' required>

      <label class='text-xs'>Danh mục *</label>
      <select name="category" class="w-full px-3 py-2 border rounded" required>
        @foreach(['phan_bon'=>'Phân bón','thuoc_bvtv'=>'Thuốc BVTV','giong_cay_trong'=>'Giống cây trồng'] as $key=>$label)
          <option value="{{ $key }}" {{ old('category',$item->category) === $key ? 'selected' : '' }}>{{ $label }}</option>
        @endforeach
      </select>

      <label class='text-xs'>Cửa hàng VTNN (lấy CK) *</label>
      <select name="vtnn_name" class="w-full px-3 py-2 border rounded" required>
        <option value="">— Chọn cửa hàng —</option>
        @foreach(($suppliers ?? []) as $name)
          <option value="{{ $name }}" {{ old('vtnn_name',$item->vtnn_name) === $name ? 'selected' : '' }}>{{ $name }}</option>
        @endforeach
      </select>

      <div class='grid grid-cols-2 gap-3'>
        <div>
          <label class='text-xs'>Đơn vị tính *</label>
          <input name='unit' value='{{ old("unit",$item->unit) }}' class='w-full px-3 py-2 border rounded' required>
        </div>
        <div>
          <label class='text-xs'>Giá niêm (VND) *</label>
          <input type='number' name='list_price' value='{{ old("list_price",$item->list_price) }}' class='w-full px-3 py-2 border rounded' required>
        </div>
      </div>

      <div class='grid grid-cols-2 gap-3'>
        <div><label class='text-xs'>Tồn kho</label>
          <input type='number' name='stock' value='{{ old("stock",$item->stock) }}' class='w-full px-3 py-2 border rounded'></div>
        <div>
          <label class='text-xs'>Trạng thái *</label>
          <select name='status' class='w-full px-3 py-2 border rounded'>
            <option value='active' {{ old('status',$item->status ?? 'active')=='active'?'selected':'' }}>Hoạt động</option>
            <option value='inactive' {{ old('status',$item->status)=='inactive'?'selected':'' }}>Ngưng</option>
          </select>
        </div>
      </div>

      <label class='text-xs'>Mô tả / Specs</label>
      <textarea name='description' rows='3' class='w-full px-3 py-2 border rounded'>{{ old("description",$item->description) }}</textarea>

      <div class="flex justify-end gap-2 pt-3 border-t">
        <a href="{{ route('products.index') }}" class="px-4 py-2 border rounded">{{ isset($item->_id) ? 'Đóng' : 'Huỷ' }}</a>
        <button class="px-4 py-2 bg-slate-900 text-white rounded">{{ isset($item->_id) ? 'Lưu thay đổi' : 'Lưu' }}</button>
      </div>
    </form>
  </div>
</div>
@endsection
