@extends('layouts.admin')

@section('content')
<div class="fixed inset-0 bg-slate-900/80 flex items-center justify-center">
  <div class="bg-white rounded-2xl w-full max-w-xl shadow-2xl">
    <div class="flex items-center justify-between px-6 py-4 border-b">
      <div class="font-semibold">
        {{ isset($item->_id) ? 'Cập nhật Tráng nông' : 'Thêm Tráng nông' }}
      </div>
      <a href="{{ route('trangnong.index') }}" class="text-xl text-slate-400">×</a>
    </div>

    <form method="POST"
          action="{{ isset($item->_id) ? route('trangnong.update', $item->_id) : route('trangnong.store') }}"
          class="p-6 space-y-3">
      @csrf
      @if(isset($item->_id)) @method('PUT') @endif

      <label class="text-xs">Tên Tráng nông *</label>
      <input name="name"
             value="{{ old('name', $item->name ?? '') }}"
             class="w-full px-3 py-2 border rounded"
             required>

      <label class="text-xs">Số điện thoại *</label>
      <input name="phone"
             value="{{ old('phone', $item->phone ?? '') }}"
             class="w-full px-3 py-2 border rounded"
             required>

      <label class="text-xs">Khu vực *</label>
      <input name="area"
             value="{{ old('area', $item->area ?? '') }}"
             class="w-full px-3 py-2 border rounded"
             required>

      {{-- LÃO NÔNG GIÁM SÁT --}}
      <label class="text-xs">Lão nông giám sát *</label>
      <select name="laonong_id" class="w-full px-3 py-2 border rounded" required>
        <option value="">Chọn lão nông...</option>
        @foreach($laonongs as $ln)
          <option value="{{ $ln->_id }}"
            {{ old('laonong_id', $item->laonong_id ?? '') == $ln->_id ? 'selected' : '' }}>
            {{ $ln->name }}
          </option>
        @endforeach
      </select>

      {{-- CỬA HÀNG VTNN ĐƯỢC GÁN --}}
      <label class="text-xs mt-3">Cửa hàng VTNN được gán *</label>
      <select name="store_id" class="w-full px-3 py-2 border rounded" required>
        <option value="">Chọn cửa hàng...</option>
        @foreach($stores as $store)
          <option value="{{ $store->_id }}"
            {{ old('store_id', $item->store_id ?? '') == $store->_id ? 'selected' : '' }}>
            {{ $store->name ?? $store->store_name }}
          </option>
        @endforeach
      </select>

      <label class="text-xs">Trạng thái *</label>
      <select name="status" class="w-full px-3 py-2 border rounded">
        <option value="active"   {{ old('status', $item->status ?? 'active') == 'active'   ? 'selected' : '' }}>Hoạt động</option>
        <option value="inactive" {{ old('status', $item->status) == 'inactive' ? 'selected' : '' }}>Ngưng</option>
      </select>

      <div class="flex justify-end gap-2 pt-3 border-t">
        <a href="{{ route('trangnong.index') }}" class="px-4 py-2 border rounded">
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
