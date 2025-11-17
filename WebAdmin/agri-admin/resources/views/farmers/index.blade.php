{{-- resources/views/farmers/index.blade.php --}}
@extends('layouts.admin')

@section('content')
<div class="px-6 py-4">

    {{-- Thanh tiêu đề + tìm kiếm + nút thêm --}}
    <div class="flex items-center justify-between mb-4">
        <div>
            <h1 class="text-lg font-semibold text-slate-800">Nông dân</h1>
            <p class="text-xs text-slate-500">
                Quản lý danh sách nông dân, lão nông, tráng nông và tổng đơn / tổng chi.
            </p>
        </div>

        <div class="flex items-center gap-2">
            <form method="GET" action="{{ route('farmers.index') }}">
                <div class="relative">
                    <input
                        type="text"
                        name="q"
                        value="{{ request('q') }}"
                        placeholder="Tìm kiếm mã, tên, SĐT..."
                        class="h-9 w-64 rounded border border-slate-200 px-3 text-sm focus:border-slate-400 focus:outline-none"
                    >
                </div>
            </form>

            <a href="{{ route('farmers.create') }}"
               class="inline-flex items-center rounded bg-emerald-600 px-4 py-2 text-sm font-medium text-white hover:bg-emerald-700">
                + Thêm nông dân
            </a>
        </div>
    </div>

    {{-- Card + bảng --}}
    <div class="rounded-lg bg-white shadow border border-slate-100">
        {{-- tiêu đề nhỏ thẳng hàng với bảng --}}
        <div class="flex items-center justify-between px-4 py-3 border-b border-slate-100">
            <div class="text-sm font-semibold text-slate-700">
                Danh sách Nông dân ({{ $items->total() }})
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="min-w-full text-xs md:text-sm">
                <thead class="bg-slate-50 border-b border-slate-100">
                    <tr class="text-left text-[11px] font-semibold text-slate-500 uppercase tracking-wide">
                        <th class="px-4 py-2 w-20">Mã</th>
                        <th class="px-2 py-2 w-40">Tên nông dân</th>
                        <th class="px-2 py-2 w-32">SĐT</th>
                        <th class="px-2 py-2 w-32">Khu vực</th>
                        <th class="px-2 py-2 w-28">LN phụ trách</th>
                        <th class="px-2 py-2 w-28">TN phụ trách</th>
                        <th class="px-2 py-2 text-right w-24">Tổng đơn</th>
                        <th class="px-2 py-2 text-right w-32">Tổng chi</th>
                        <th class="px-4 py-2 text-right w-24">Actions</th>
                    </tr>
                </thead>

                <tbody>
                @forelse ($items as $item)
                    <tr class="border-b border-slate-100 hover:bg-slate-50">
                        {{-- Mã nông dân --}}
                        <td class="px-4 py-2 whitespace-nowrap text-slate-800">
                            {{ $item->code }}
                        </td>

                        {{-- Tên --}}
                        <td class="px-2 py-2 whitespace-nowrap">
                            {{ $item->name }}
                        </td>

                        {{-- SĐT --}}
                        <td class="px-2 py-2 whitespace-nowrap">
                            {{ $item->phone }}
                        </td>

                        {{-- Khu vực --}}
                        <td class="px-2 py-2 whitespace-nowrap">
                            {{ $item->region }}
                        </td>

                        {{-- Lão nông phụ trách: hiển thị theo MÃ --}}
                        <td class="px-2 py-2 whitespace-nowrap">
                            {{ $item->lao_nong_code }}
                        </td>

                        {{-- Tráng nông phụ trách: hiển thị theo MÃ --}}
                        <td class="px-2 py-2 whitespace-nowrap">
                            {{ $item->trang_nong_code }}
                        </td>

                        {{-- Tổng đơn --}}
                        <td class="px-2 py-2 text-right whitespace-nowrap">
                            {{ number_format($item->orders_count ?? 0) }}
                        </td>

                        {{-- Tổng chi --}}
                        <td class="px-2 py-2 text-right whitespace-nowrap">
                            {{ number_format($item->total_cost ?? 0) }} đ
                        </td>

                        {{-- Actions --}}
                        <td class="px-4 py-2 whitespace-nowrap">
                            <div class="flex justify-end gap-2">
                                <a href="{{ route('farmers.edit', $item->_id) }}"
                                   class="inline-flex items-center rounded border border-slate-200 px-2 py-1 text-[11px] font-medium text-slate-700 hover:bg-slate-100">
                                    Sửa
                                </a>

                                <form method="POST"
                                      action="{{ route('farmers.destroy', $item->_id) }}"
                                      onsubmit="return confirm('Xóa nông dân này?');">
                                    @csrf
                                    @method('DELETE')
                                    <button
                                        type="submit"
                                        class="inline-flex items-center rounded border border-red-100 bg-red-50 px-2 py-1 text-[11px] font-medium text-red-600 hover:bg-red-100">
                                        Xóa
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="9" class="px-4 py-6 text-center text-slate-400">
                            Không có nông dân nào.
                        </td>
                    </tr>
                @endforelse
                </tbody>
            </table>
        </div>

        {{-- Phân trang --}}
        <div class="px-4 py-3 border-t border-slate-100">
            {{ $items->withQueryString()->links() }}
        </div>
    </div>
</div>
@endsection
