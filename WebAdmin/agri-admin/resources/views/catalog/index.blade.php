@extends('layouts.admin')

@section('content')
<div class="px-6 py-6">

    {{-- Tiêu đề + nút thêm mới --}}
    <div class="flex items-center justify-between mb-4">
        <div>
            <h1 class="text-lg font-semibold">Danh mục Sản phẩm tại VTNN</h1>
            <p class="mt-1 text-xs text-slate-500">
                Giá bán, chiết khấu TN/LN và tồn kho cho từng sản phẩm tại từng cửa hàng VTNN.
            </p>
        </div>

        <a href="{{ route('catalog.create') }}"
           class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-emerald-600 rounded-lg hover:bg-emerald-700">
            + Thêm mới
        </a>
    </div>

    {{-- Message thành công --}}
    @if(session('success'))
        <div class="mb-4 text-sm text-emerald-700 bg-emerald-50 border border-emerald-200 px-4 py-2 rounded-lg">
            {{ session('success') }}
        </div>
    @endif

    {{-- Thanh tìm kiếm --}}
    <div class="flex items-center justify-between mb-4">
        <form method="GET" action="{{ route('catalog.index') }}" class="flex-1 max-w-md">
            <div class="relative">
                <input
                    type="text"
                    name="q"
                    value="{{ request('q') }}"
                    placeholder="Tìm kiếm VTNN, sản phẩm..."
                    class="w-full px-3 py-2 text-sm border rounded-lg focus:outline-none focus:ring-1 focus:ring-slate-500"
                >
            </div>
        </form>
    </div>

    {{-- Bảng danh sách --}}
    <div class="overflow-hidden bg-white border rounded-xl">
        <table class="min-w-full text-sm">
            <thead class="bg-slate-50 text-xs text-slate-500">
                <tr>
                    <th class="px-4 py-2 text-left align-middle">VTNN</th>
                    <th class="px-4 py-2 text-left align-middle">Sản phẩm</th>
                    <th class="px-4 py-2 text-right align-middle">Giá bán</th>
                    <th class="px-4 py-2 text-center align-middle">Chiết khấu TN</th>
                    <th class="px-4 py-2 text-center align-middle">Chiết khấu LN</th>
                    <th class="px-4 py-2 text-center align-middle">Tồn kho</th>
                    <th class="px-4 py-2 text-center align-middle w-24">Trạng thái</th>
                    <th class="px-4 py-2 text-center align-middle w-28">Hành động</th>
                </tr>
            </thead>

            <tbody class="divide-y">
            @forelse($items as $item)
                <tr class="hover:bg-slate-50">
                    {{-- VTNN --}}
                    <td class="px-4 py-2 align-middle whitespace-nowrap">
                        @if($item->store)
                            {{ $item->store->name }}
                            @if(!empty($item->store->code))
                                ({{ $item->store->code }})
                            @endif
                        @endif
                    </td>

                    {{-- Sản phẩm --}}
                    <td class="px-4 py-2 align-middle whitespace-nowrap">
                        @if($item->product)
                            {{ $item->product->name }}
                            @if(!empty($item->product->sku))
                                ({{ $item->product->sku }})
                            @endif
                        @endif
                    </td>

                    {{-- Giá bán --}}
                    <td class="px-4 py-2 text-right align-middle whitespace-nowrap">
                        {{ number_format($item->price ?? 0, 0, ',', '.') }}đ
                    </td>

                    {{-- CK TN --}}
                    <td class="px-4 py-2 text-center align-middle whitespace-nowrap">
                        {{ $item->discount_tn ?? 0 }}%
                    </td>

                    {{-- CK LN --}}
                    <td class="px-4 py-2 text-center align-middle whitespace-nowrap">
                        {{ $item->discount_ln ?? 0 }}%
                    </td>

                    {{-- Tồn kho --}}
                    <td class="px-4 py-2 text-center align-middle whitespace-nowrap">
                        {{ $item->stock ?? 0 }}
                    </td>

                    {{-- Trạng thái --}}
                    <td class="px-4 py-2 text-center align-middle">
                        @if(($item->status ?? 'active') === 'active')
                            <span class="px-2 py-0.5 text-xs font-medium text-emerald-700 bg-emerald-50 rounded-full">
                                Hoạt động
                            </span>
                        @else
                            <span class="px-2 py-0.5 text-xs font-medium text-rose-700 bg-rose-50 rounded-full">
                                Ngưng
                            </span>
                        @endif
                    </td>

                    {{-- Hành động --}}
                    <td class="px-4 py-2 text-center align-middle">
                        <div class="flex items-center justify-center gap-2">
                            {{-- Sửa --}}
                            <a href="{{ route('catalog.edit', $item->_id) }}"
                               class="inline-flex items-center justify-center w-7 h-7 text-xs bg-slate-100 hover:bg-slate-200 rounded-md"
                               title="Sửa">
                                ✏️
                            </a>

                            {{-- Xoá --}}
                            <form action="{{ route('catalog.destroy', $item->_id) }}"
                                  method="POST"
                                  onsubmit="return confirm('Xoá mục Catalog này?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit"
                                        class="inline-flex items-center justify-center w-7 h-7 text-xs text-white bg-rose-500 hover:bg-rose-600 rounded-md"
                                        title="Xoá">
                                    🗑
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
            @empty
                <tr>
                    <td colspan="8" class="px-4 py-6 text-sm text-center text-slate-500">
                        Chưa có dữ liệu Catalog VTNN.
                    </td>
                </tr>
            @endforelse
            </tbody>
        </table>
    </div>

    {{-- Phân trang --}}
    <div class="mt-4">
        {{ $items->links() }}
    </div>
</div>
@endsection