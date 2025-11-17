<li class="{{ request()->is('admin/orders*') ? 'bg-slate-100 text-slate-900' : '' }}">
    <a href="{{ route('orders.index') }}" class="flex items-center gap-2 px-3 py-2 text-sm">
        <span class="w-4 h-4 rounded-full bg-slate-300"></span>
        <span>Điều phối đơn</span>
    </a>
</li>
