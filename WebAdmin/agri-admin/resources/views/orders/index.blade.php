@extends('layouts.admin')

@section('content')
<div class="px-6 py-4">
    <h1 class="text-xl font-semibold mb-4">Điều phối đơn</h1>

    {{-- Thanh filter --}}
    <div class="flex items-center justify-between mb-4 gap-3">
        <form method="GET" class="flex items-center gap-2 flex-1">
            <input
                type="text"
                name="q"
                value="{{ request('q') }}"
                placeholder="Tìm mã đơn, nông dân, LN, TN…"
                class="w-full px-3 py-2 border rounded-lg text-sm"
            >

            <select name="status" class="px-3 py-2 border rounded-lg text-sm">
                <option value="">Tất cả trạng thái</option>
                @foreach($statusOptions as $value => $step)
                    <option value="{{ $value }}" {{ request('status') == $value ? 'selected' : '' }}>
                        {{ $step['label'] }}
                    </option>
                @endforeach
            </select>

            <input
                type="text"
                name="region"
                value="{{ request('region') }}"
                placeholder="Tất cả khu vực"
                class="px-3 py-2 border rounded-lg text-sm w-40"
            >

            <button class="px-4 py-2 bg-slate-900 text-white rounded-lg text-sm">
                Lọc
            </button>
        </form>

        <div class="text-xs text-slate-500">
            Tổng: {{ $orders->total() }} đơn
        </div>
    </div>

    {{-- Bảng đơn hàng --}}
    <div class="bg-white rounded-xl shadow-sm border overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="bg-slate-50">
                <tr>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">Mã đơn</th>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">Nông dân</th>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">Khu vực</th>
                    <th class="px-4 py-2 text-right font-semibold text-xs text-slate-500">Tổng tiền</th>
                    <th class="px-4 py-2 text-center font-semibold text-xs text-slate-500">Trạng thái</th>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">Ngày tạo</th>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">TN/LN</th>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">VTNN</th>
                    <th class="px-4 py-2 text-right font-semibold text-xs text-slate-500">Action</th>
                </tr>
            </thead>
            <tbody>
                @forelse($orders as $order)
                    <tr class="border-t hover:bg-slate-50">
                        <td class="px-4 py-2 align-middle font-medium text-slate-800">
                            {{ $order->code }}
                        </td>
                        <td class="px-4 py-2 align-middle">
                            {{ $order->farmer_name }}
                        </td>
                        <td class="px-4 py-2 align-middle text-slate-600">
                            {{ $order->region }}
                        </td>
                        <td class="px-4 py-2 align-middle text-right">
                            {{ number_format($order->total_amount, 0, ',', '.') }} đ
                        </td>
                        <td class="px-4 py-2 align-middle text-center">
                            <span class="inline-flex px-2 py-1 rounded-full text-xs font-medium {{ $order->status_badge_class }}">
                                {{ $order->status_label }}
                            </span>
                        </td>
                        <td class="px-4 py-2 align-middle text-slate-600">
                            {{ optional($order->created_at)->format('d/m/Y') }}
                        </td>
                        <td class="px-4 py-2 align-middle text-slate-600">
                            {{-- Hiển thị mã TN / LN --}}
                            {{ $order->trang_nong_code }} / {{ $order->lao_nong_code }}
                        </td>
                        <td class="px-4 py-2 align-middle text-slate-600">
                            {{ $order->store_code }}
                        </td>
                        <td class="px-4 py-2 align-middle text-right">
                            <a href="{{ route('orders.show', $order->_id ?? $order->id) }}"
                               class="text-sm text-emerald-600 hover:underline">
                                Chi tiết
                            </a>
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="9" class="px-4 py-6 text-center text-slate-500">
                            Chưa có đơn hàng nào.
                        </td>
                    </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <div class="mt-4">
        {{ $orders->withQueryString()->links() }}
    </div>
</div>
@endsection
