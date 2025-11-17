@extends('layouts.admin')

@section('content')
<div class="px-6 py-4 space-y-6">

    {{-- Header --}}
    <div class="flex items-center justify-between">
        <div>
            <h1 class="text-xl font-semibold">
                Đơn hàng {{ $order->code }}
            </h1>
            <p class="text-sm text-slate-500 mt-1">
                Nông dân: <span class="font-medium text-slate-700">{{ $order->farmer_name }}</span> ·
                Khu vực: <span class="font-medium text-slate-700">{{ $order->region }}</span>
            </p>
        </div>

        <a href="{{ route('orders.index') }}" class="text-sm text-slate-600 hover:underline">
            ← Quay lại danh sách
        </a>
    </div>

    {{-- TIMELINE 11 TRẠNG THÁI --}}
    <div class="bg-white rounded-xl shadow-sm border px-6 py-4">
        @php $current = (int) $order->status; @endphp

        <ol class="flex items-center justify-between">
            @foreach($steps as $value => $step)
                <li class="flex-1 flex flex-col items-center">
                    <div class="flex items-center w-full">
                        <div class="flex items-center justify-center w-8 h-8 rounded-full text-xs font-semibold
                            {{ $value <= $current ? 'bg-emerald-500 text-white' : 'bg-slate-200 text-slate-600' }}">
                            {{ $loop->iteration }}
                        </div>

                        @if(!$loop->last)
                            <div class="h-0.5 flex-1 mx-1
                                {{ $value < $current ? 'bg-emerald-500' : 'bg-slate-200' }}">
                            </div>
                        @endif
                    </div>
                    <p class="mt-2 text-[11px] text-center text-slate-700 leading-tight">
                        {{ $step['label'] }}
                    </p>
                </li>
            @endforeach
        </ol>
    </div>

    {{-- Thông tin đơn --}}
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-white rounded-xl shadow-sm border p-4 space-y-2">
            <h2 class="text-sm font-semibold text-slate-700 mb-2">Thông tin nông dân</h2>
            <p class="text-sm">Tên: <span class="font-medium">{{ $order->farmer_name }}</span></p>
            <p class="text-sm">Khu vực: <span class="font-medium">{{ $order->region }}</span></p>
        </div>

        <div class="bg-white rounded-xl shadow-sm border p-4 space-y-2">
            <h2 class="text-sm font-semibold text-slate-700 mb-2">LN / TN phụ trách</h2>
            <p class="text-sm">Lão nông: <span class="font-medium">{{ $order->lao_nong_code }}</span></p>
            <p class="text-sm">Tráng nông: <span class="font-medium">{{ $order->trang_nong_code }}</span></p>
        </div>

        <div class="bg-white rounded-xl shadow-sm border p-4 space-y-2">
            <h2 class="text-sm font-semibold text-slate-700 mb-2">Cửa hàng VTNN</h2>
            <p class="text-sm">Mã cửa hàng: <span class="font-medium">{{ $order->store_code }}</span></p>
            <p class="text-sm">Tổng tiền:
                <span class="font-semibold text-emerald-600">
                    {{ number_format($order->total_amount, 0, ',', '.') }} đ
                </span>
            </p>
            <p class="text-sm">Trạng thái:
                <span class="inline-flex px-2 py-1 rounded-full text-xs font-medium {{ $order->status_badge_class }}">
                    {{ $order->status_label }}
                </span>
            </p>
        </div>
    </div>

    {{-- Bảng hàng hóa --}}
    <div class="bg-white rounded-xl shadow-sm border overflow-x-auto">
        <table class="min-w-full text-sm">
            <thead class="bg-slate-50">
                <tr>
                    <th class="px-4 py-2 text-left font-semibold text-xs text-slate-500">Sản phẩm</th>
                    <th class="px-4 py-2 text-center font-semibold text-xs text-slate-500">SL</th>
                    <th class="px-4 py-2 text-right font-semibold text-xs text-slate-500">Giá</th>
                    <th class="px-4 py-2 text-right font-semibold text-xs text-slate-500">Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                @forelse($order->items as $item)
                    <tr class="border-t">
                        <td class="px-4 py-2 align-middle">
                            <div class="font-medium text-slate-800">
                                {{ $item->product_code }} - {{ $item->product_name }}
                            </div>
                        </td>
                        <td class="px-4 py-2 align-middle text-center">
                            {{ $item->qty }}
                        </td>
                        <td class="px-4 py-2 align-middle text-right">
                            {{ number_format($item->price, 0, ',', '.') }} đ
                        </td>
                        <td class="px-4 py-2 align-middle text-right">
                            {{ number_format($item->subtotal, 0, ',', '.') }} đ
                        </td>
                    </tr>
                @empty
                    <tr>
                        <td colspan="4" class="px-4 py-6 text-center text-slate-500">
                            Đơn hàng chưa có sản phẩm.
                        </td>
                    </tr>
                @endforelse
            </tbody>
            <tfoot class="bg-slate-50">
                <tr>
                    <td colspan="3" class="px-4 py-2 text-right font-semibold">
                        Tổng cộng
                    </td>
                    <td class="px-4 py-2 text-right font-semibold text-emerald-600">
                        {{ number_format($order->total_amount, 0, ',', '.') }} đ
                    </td>
                </tr>
            </tfoot>
        </table>
    </div>
</div>
@endsection
