@extends('layouts.admin')
@section('content')
<div class="fixed inset-0 bg-slate-900/80 flex items-center justify-center">
  <div class="bg-white rounded-2xl w-full max-w-xl shadow-2xl">
    <div class="flex items-center justify-between px-6 py-4 border-b">
      <div class="font-semibold">{{ isset($item->_id) ? 'Cập nhật Lão nông' : 'Thêm Lão nông mới' }}</div>
      <a href="{{ route('laonong.index') }}" class="text-xl text-slate-400">×</a>
    </div>
    <form method="POST" action="{{ isset($item->_id) ? route('laonong.update',$item->_id) : route('laonong.store') }}" class="p-6 space-y-3">
      @csrf @if(isset($item->_id)) @method('PUT') @endif

<label class='text-xs'>Tên Lão nông *</label><input name='name' value='{{ old("name",$item->name) }}' class='w-full px-3 py-2 border rounded' required>
<label class='text-xs'>Số điện thoại *</label><input name='phone' value='{{ old("phone",$item->phone) }}' class='w-full px-3 py-2 border rounded' required>
<label class="text-xs">Khu vực phụ trách</label>
<input
    type="text"
    name="region"   {{-- 👈 tên field trùng với validate + fillable --}}
    value="{{ old('region', $item->region ?? '') }}"
    class="w-full px-3 py-2 border rounded"
/>
<div class='grid grid-cols-2 gap-3'>
   <div><label class='text-xs'>Trạng thái *</label>
    <select name='status' class='w-full px-3 py-2 border rounded'>
      <option value='active' {{ old('status',$item->status ?? 'active')=='active'?'selected':'' }}>Hoạt động</option>
      <option value='inactive' {{ old('status',$item->status)=='inactive'?'selected':'' }}>Ngưng</option>
    </select>
  </div>
</div>

      <div class="flex justify-end gap-2 pt-3 border-t">
        <a href="{{ route('laonong.index') }}" class="px-4 py-2 border rounded">{{ isset($item->_id) ? 'Đóng' : 'Huỷ' }}</a>
        <button class="px-4 py-2 bg-slate-900 text-white rounded">{{ isset($item->_id) ? 'Lưu thay đổi' : 'Lưu' }}</button>
      </div>
    </form>
  </div>
</div>
@endsection
