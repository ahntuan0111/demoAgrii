{{-- resources/views/laonong/index.blade.php --}}
@extends('layouts.admin')

@section('content')
<div class="px-6 py-4">
    {{-- Tiêu đề + nút thêm --}}
    <div class="flex items-center justify-between mb-4">
        <div>
            <h1 class="text-xl font-semibold text-slate-800">Danh mục Lão nông</h1>
            <p class="text-sm text-slate-500">
                Quản lý danh sách lão nông và khu vực phụ trách.
            </p>
        </div>

        <a href="{{ route('laonong.create') }}"
           class="inline-flex items-center px-4 py-2 text-sm font-medium text-white bg-emerald-600 rounded-lg hover:bg-emerald-700">
            + Thêm mới
        </a>
    </div>

    {{-- Bảng danh sách --}}
    <div class="bg-white rounded-xl shadow-sm border border-slate-200">
        <table class="min-w-full text-sm">
            <thead class="bg-slate-50 border-b border-slate-200">
                <tr>
                    <th class="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        Mã
                    </th>
                    <th class="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        Tên Lão nông
                    </th>
                    <th class="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        SĐT
                    </th>
                    <th class="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        Khu vực phụ trách
                    </th>
                    <th class="px-4 py-3 text-left text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        Trạng thái
                    </th>
                    <th class="px-4 py-3 text-right text-xs font-semibold text-slate-500 uppercase tracking-wide">
                        Actions
                    </th>
                </tr>
            </thead>

            <tbody class="divide-y divide-slate-100">
                @forelse($items as $item)
                    <tr class="hover:bg-slate-50">
                        {{-- Mã tự động LN*** (đã sinh trong model) --}}
                        <td class="px-4 py-2 text-slate-800">
                            {{ $item->code }}
                        </td>

                        {{-- Tên lão nông --}}
                        <td class="px-4 py-2 text-slate-800">
                            {{ $item->name }}
                        </td>

                        {{-- SĐT --}}
                        <td class="px-4 py-2 text-slate-700">
                            {{ $item->phone }}
                        </td>

                        {{-- Khu vực phụ trách (region) --}}
                        <td class="px-4 py-2 text-slate-700">
                            {{ $item->region ?? '-' }}
                        </td>

                        {{-- Trạng thái --}}
                        <td class="px-4 py-2">
                            @php
                                $status = $item->status ?? 'active';
                            @endphp
                            @if($status === 'active')
                                <span class="inline-flex px-2.5 py-0.5 text-xs font-medium rounded-full bg-emerald-50 text-emerald-700">
                                    Hoạt động
                                </span>
                            @else
                                <span class="inline-flex px-2.5 py-0.5 text-xs font-medium rounded-full bg-slate-100 text-slate-600">
                                    {{ $status }}
                                </span>
                            @endif
                        </td>

                        {{-- Actions --}}
                        <td class="px-4 py-2 text-right">
                            <div class="inline-flex items-center gap-2">
                                {{-- Sửa --}}
                                <a href="{{ route('laonong.edit', $item->_id) }}"
                                   class="inline-flex items-center px-2 py-1 text-xs font-medium text-slate-700 border border-slate-300 rounded hover:bg-slate-50">
                                    Sửa
                                </a>

                                {{-- Xoá --}}
                                <form action="{{ route('laonong.destroy', $item->_id) }}"
                                      method="POST"
                                      onsubmit="return confirm('Xác nhận xoá lão nông này?');">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit"
                                            class="inline-flex items-center px-2 py-1 text-xs font-medium text-red-600 border border-red-200 rounded hover:bg-red-50">
                                        Xoá
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="6" class="px-4 py-6 text-center text-sm text-slate-500">
                            Chưa có lão nông nào.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>

        {{-- Phân trang --}}
        @if(method_exists($items, 'links'))
            <div class="px-4 py-3 border-t border-slate-100">
                {{ $items->links() }}
            </div>
        @endif
    </div>
</div>
@endsection
