<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>Agri Admin</title>
<script src="https://cdn.tailwindcss.com"></script>
<style>
    .order-status-flow {
        display: flex;
        align-items: flex-start;
        margin: 8px 0 16px;
        font-family: system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }

    .order-step {
        position: relative;
        flex: 1 1 0;
        text-align: center;
        padding-top: 4px;
    }

    /* đường nối giữa các chấm (vẽ từ giữa chấm sang phải) */
    .order-step::after {
        content: "";
        position: absolute;
        top: 18px;          /* ngang tâm vòng tròn */
        left: 50%;
        right: -50%;
        height: 2px;
        background-color: #e5e7eb; /* xám nhạt */
        z-index: 0;
    }
    .order-step:last-child::after {
        content: none;
    }

    .order-step__circle {
        width: 32px;
        height: 32px;
        border-radius: 999px;
        background-color: #e5e7eb; /* xám nhạt */
        color: #6b7280;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        font-weight: 600;
        margin: 0 auto;
        position: relative;
        z-index: 1;
    }

    .order-step__label {
        margin-top: 6px;
        font-size: 13px;
        line-height: 1.2;
        color: #4b5563;
        white-space: pre-line;
    }

    /* đã qua hoặc hiện tại: line + vòng tròn xanh */
    .order-step.is-done .order-step__circle,
    .order-step.is-current .order-step__circle {
        background-color: #46a942;   /* xanh giống hình */
        color: #ffffff;
    }
    .order-step.is-done::after,
    .order-step.is-current::after {
        background-color: #46a942;
    }

    /* bước hiện tại: label đậm & xanh */
    .order-step.is-current .order-step__label {
        color: #46a942;
        font-weight: 600;
    }
</style>

</head>
<body class="bg-slate-50 text-slate-800">
<div class="min-h-screen flex">
  <aside class="w-64 bg-white border-r border-slate-200">
    <div class="px-6 py-4 border-b font-semibold">Agri Admin</div>
    <nav class="p-3 space-y-1 text-sm">
    <a href="{{ route('farmers.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/farmers*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Nông dân
    </a>

    <a href="{{ route('trangnong.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/trangnong*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Tráng nông
    </a>

    <a href="{{ route('laonong.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/laonong*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Lão nông
    </a>

    <a href="{{ route('suppliers.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/suppliers*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Cửa hàng VTNN
    </a>

    <a href="{{ route('products.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/products*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Sản phẩm
    </a>

    <a href="{{ route('catalog.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/catalog*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Catalog VTNN
    </a>

    {{-- ✅ MỤC MỚI: ĐIỀU PHỐI ĐƠN --}}
    <a href="{{ route('orders.index') }}"
       class="block px-3 py-2 rounded
              {{ request()->is('admin/orders*') ? 'bg-emerald-50 text-emerald-600' : 'text-slate-700 hover:bg-slate-50' }}">
        Điều phối đơn
    </a>
</nav>

  </aside>
  <main class="flex-1 p-6 relative">
    @yield('content')
    @if(session('success')||session('error'))
    <div class="fixed inset-0 bg-slate-900/60 flex items-center justify-center z-50">
      <div class="bg-white rounded-2xl shadow-2xl w-[320px] p-6" data-bubble>
        <div class="font-semibold mb-2">Message Bubble</div>
        <p class="text-sm mb-4">{{ session('success') ?? session('error') }}</p>
        <button onclick="this.closest('[data-bubble]').parentElement.remove()" class="w-full py-2 rounded bg-emerald-600 text-white text-sm">Xác nhận</button>
      </div>
    </div>
    @endif
  </main>
</div>
</body></html>
