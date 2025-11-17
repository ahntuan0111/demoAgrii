@extends('layouts.admin')
@section('content')
<div class="flex items-center justify-between mb-4">
  <h1 class="text-xl font-semibold">Danh mục Cửa hàng VTNN</h1>
  <a href="{{ route('suppliers.create') }}" class="px-3 py-2 bg-emerald-600 text-white rounded text-sm">+ Thêm mới</a>
</div>
<div class="bg-white rounded-xl border">
  <div class="overflow-x-auto">
    <table class="min-w-full text-xs">
      <thead class="bg-slate-50 text-slate-600">
        <tr><th class='px-3 py-2'>Mã</th><th class='px-3 py-2'>Tên cửa hàng</th><th class='px-3 py-2'>SĐT</th><th class='px-3 py-2'>Địa chỉ</th><th class='px-3 py-2'>Trạng thái</th><th class='px-3 py-2'>Actions</th></tr>
      </thead>
      <tbody class="divide-y">
        @forelse($items as $item)
        <tr>
<td class='px-3 py-2'>{{ $item->code ?? '' }}</td>
<td class='px-3 py-2'>{{ $item->name ?? '' }}</td>
<td class='px-3 py-2'>{{ $item->phone ?? '' }}</td>
<td class='px-3 py-2'>{{ $item->address ?? '' }}</td>
<td class='px-3 py-2'>{{ $item->status ?? '' }}</td>
          <td class="px-3 py-2">
            <div class="flex gap-2 justify-center">
              <a href="{{ route('suppliers.edit',$item->_id) }}" class="px-2 py-1 bg-slate-100 rounded">✏️</a>
              <form method="POST" action="{{ route('suppliers.destroy',$item->_id) }}" onsubmit="return confirm('Xác nhận xoá?')">
                @csrf @method('DELETE')
                <button class="px-2 py-1 bg-slate-100 rounded text-rose-600">🗑</button>
              </form>
            </div>
          </td>
        </tr>
        @empty
        <tr><td colspan="6" class="px-3 py-4 text-center text-slate-400">Chưa có dữ liệu</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>
  <div class="p-3 text-right">{{ $items->withQueryString()->links() }}</div>
</div>
@endsection
