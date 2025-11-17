@extends('layouts.admin')

@section('content')
<div class="fixed inset-0 bg-slate-900/80 flex items-center justify-center">
  <div class="bg-white rounded-2xl w-full max-w-xl shadow-2xl">
    <div class="flex items-center justify-between px-6 py-4 border-b">
      <div class="font-semibold">
        {{ isset($item->_id) ? 'Cập nhật Catalog VTNN' : 'Thêm Catalog VTNN' }}
      </div>
      <a href="{{ route('catalog.index') }}" class="text-xl text-slate-400">×</a>
    </div>

    <form method="POST"
          action="{{ isset($item->_id) ? route('catalog.update',$item->_id) : route('catalog.store') }}"
          class="p-6 space-y-3">
      @csrf
      @if(isset($item->_id)) @method('PUT') @endif

      {{-- Cửa hàng VTNN --}}
      <label class="text-xs">Cửa hàng VTNN *</label>
      <select name="store_id"
              class="w-full px-3 py-2 border rounded"
              required>
        <option value="">Vui lòng chọn cửa hàng</option>
        @foreach($stores as $store)
          <option value="{{ $store->_id }}"
            {{ old('store_id', $item->store_id ?? '') == $store->_id ? 'selected' : '' }}>
            {{ $store->name }} @if(!empty($store->code)) ({{ $store->code }}) @endif
          </option>
        @endforeach
      </select>

      {{-- Sản phẩm --}}
      <label class="text-xs">Sản phẩm *</label>
      <select name="product_id"
              class="w-full px-3 py-2 border rounded"
              required>
        <option value="">Vui lòng chọn sản phẩm</option>
        @foreach($products as $product)
          <option value="{{ $product->_id }}"
            {{ old('product_id', $item->product_id ?? '') == $product->_id ? 'selected' : '' }}>
            {{ $product->name }} @if(!empty($product->sku)) ({{ $product->sku }}) @endif
          </option>
        @endforeach
      </select>

      {{-- Giá & chiết khấu --}}
      <label class="text-xs">Giá bán (VND) *</label>
      <input type="number" name="price"
             value="{{ old('price', $item->price ?? '') }}"
             class="w-full px-3 py-2 border rounded" required>

      <div class="grid grid-cols-2 gap-3">
        <div>
          <label class="text-xs">Chiết khấu TN *</label>
          <input type="number" step="0.01" name="discount_tn"
                 value="{{ old('discount_tn', $item->discount_tn ?? '') }}"
                 class="w-full px-3 py-2 border rounded" required>
        </div>
        <div>
          <label class="text-xs">Chiết khấu LN *</label>
          <input type="number" step="0.01" name="discount_ln"
                 value="{{ old('discount_ln', $item->discount_ln ?? '') }}"
                 class="w-full px-3 py-2 border rounded" required>
        </div>
      </div>

      {{-- Tồn kho --}}
      <label class="text-xs">Số lượng tồn kho *</label>
      <input type="number" name="stock"
             value="{{ old('stock', $item->stock ?? '') }}"
             class="w-full px-3 py-2 border rounded" required>

      {{-- Trạng thái --}}
      <label class="text-xs">Trạng thái *</label>
      <select name="status" class="w-full px-3 py-2 border rounded">
        <option value="active"
          {{ old('status', $item->status ?? 'active') == 'active' ? 'selected' : '' }}>
          Hoạt động
        </option>
        <option value="inactive"
          {{ old('status', $item->status ?? '') == 'inactive' ? 'selected' : '' }}>
          Ngưng
        </option>
      </select>

      <div class="flex justify-end gap-2 pt-3 border-t">
        <a href="{{ route('catalog.index') }}"
           class="px-4 py-2 border rounded">
           {{ isset($item->_id) ? 'Đóng' : 'Huỷ' }}
        </a>
        <button class="px-4 py-2 bg-slate-900 text-white rounded">
          {{ isset($item->_id) ? 'Lưu thay đổi' : 'Lưu' }}
        </button>
      </div>
    </form>
  </div>
</div>
@endsection
