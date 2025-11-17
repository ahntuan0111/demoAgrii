{{-- PATCH STAMP: vtnn_in_form_ck_from_catalog @ 2025-11-13 --}}
@extends('layouts.admin')
@section('content')
@php
  $pct = function($v){
    if($v===null || $v==='') return '—';
    $n = is_numeric($v) ? (float)$v : 0;
    $n = $n > 1 ? $n : $n*100;
    $txt = number_format($n, (fmod($n,1.0)==0?0:2), ',', '.');
    return $txt.'%';
  };
  $catLabel = function($key) use ($categories){
    return $categories[$key] ?? $key;
  };
@endphp

<div class="mb-2">
  <h1 class="text-xl font-semibold">Sản phẩm</h1>
  <p class="text-sm text-slate-500">CK hiển thị theo <b>Catalog VTNN</b> dựa trên cửa hàng đã gán cho từng sản phẩm.</p>
</div>

<form method="GET" class="flex items-center justify-between gap-3 mb-4">
  <div class="flex-1">
    <input name="q" value="{{ request('q') }}" placeholder="Tìm kiếm SKU, tên sản phẩm..." class="w-full px-3 py-2 bg-white border rounded-lg text-sm">
  </div>
  <div>
    <select name="category" class="px-3 py-2 bg-white border rounded-lg text-sm" onchange="this.form.submit()">
      <option value="">Tất cả danh mục</option>
      @foreach($categories as $key=>$label)
        <option value="{{ $key }}" {{ (request('category') ?? '')===$key ? 'selected' : '' }}>{{ $label }}</option>
      @endforeach
    </select>
  </div>
  <div class="flex items-center gap-2">
    <a href="{{ route('products.create') }}" class="px-3 py-2 bg-emerald-600 text-white rounded text-sm">+ Thêm sản phẩm</a>
  </div>
</form>

<div class="bg-white rounded-xl border">
  <div class="overflow-x-auto">
    <table class="min-w-full text-xs">
      <thead class="bg-slate-50 text-slate-600">
        <tr>
          <th class="px-3 py-2 text-left">SKU</th>
          <th class="px-3 py-2 text-left">Tên sản phẩm</th>
          <th class="px-3 py-2 text-left">Danh mục</th>
          <th class="px-3 py-2 text-left">Đơn vị</th>
          <th class="px-3 py-2 text-right">Giá niêm yết</th>
          <th class="px-3 py-2 text-center">CK LN (theo VTNN)</th>
          <th class="px-3 py-2 text-center">CK TN (theo VTNN)</th>
          <th class="px-3 py-2 text-center">Override LN</th>
          <th class="px-3 py-2 text-right">Tồn kho</th>
          <th class="px-3 py-2 text-center">Actions</th>
        </tr>
      </thead>
      <tbody class="divide-y">
        @forelse($items as $item)
          @php
            $key = ($item->name ?? '').'|'.($item->vtnn_name ?? '');
            $ck = $catalogMap[$key] ?? null;
          @endphp
          <tr class="hover:bg-slate-50">
            <td class="px-3 py-2 font-mono text-[11px] text-slate-600">{{ $item->sku }}</td>
            <td class="px-3 py-2">
              <div class="font-medium">{{ $item->name }}</div>
              <div class="text-[11px] text-slate-500">VTNN: {{ $item->vtnn_name ?? '—' }}</div>
            </td>
            <td class="px-3 py-2">
              <span class="inline-block px-2 py-0.5 rounded bg-slate-100 text-slate-600 text-[11px]">
                {{ $catLabel($item->category) }}
              </span>
            </td>
            <td class="px-3 py-2">{{ $item->unit }}</td>
            <td class="px-3 py-2 text-right">{{ number_format((float)($item->list_price ?? 0), 0, ',', '.') }} đ</td>
            <td class="px-3 py-2 text-center">{{ $ck ? $pct($ck['ln']) : '—' }}</td>
            <td class="px-3 py-2 text-center">{{ $ck ? $pct($ck['tn']) : '—' }}</td>
            <td class="px-3 py-2 text-center">{{ $pct($item->override_ln) }}</td>
            <td class="px-3 py-2 text-right">{{ number_format((int)($item->stock ?? 0), 0, ',', '.') }}</td>
            <td class="px-3 py-2">
              <div class="flex gap-2 justify-center">
                <a href="{{ route('products.edit',$item->_id) }}" class="px-2 py-1 bg-slate-100 rounded" title="Sửa">✏️</a>
                <form method="POST" action="{{ route('products.destroy',$item->_id) }}" onsubmit="return confirm('Xác nhận xoá sản phẩm này?')">
                  @csrf @method('DELETE')
                  <button class="px-2 py-1 bg-slate-100 rounded text-rose-600" title="Xoá">🗑</button>
                </form>
              </div>
            </td>
          </tr>
        @empty
          <tr><td colspan="10" class="px-3 py-6 text-center text-slate-400">Chưa có sản phẩm</td></tr>
        @endforelse
      </tbody>
    </table>
  </div>
  <div class="p-3 text-right">{{ $items->withQueryString()->links() }}</div>
</div>
@endsection
