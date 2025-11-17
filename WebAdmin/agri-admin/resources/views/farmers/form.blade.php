@extends('layouts.admin')

@section('content')
<div class="fixed inset-0 bg-slate-900/70 flex items-center justify-center">
    <div class="bg-white rounded-2xl w-full max-w-xl shadow-2xl">
        <div class="flex items-center justify-between px-6 py-4 border-b">
            <div class="font-semibold">
                {{ isset($item->_id) ? 'Cập nhật nông dân' : 'Thêm nông dân mới' }}
            </div>
            <a href="{{ route('farmers.index') }}" class="text-xl text-slate-400">×</a>
        </div>

        <form method="POST"
              action="{{ isset($item->_id) ? route('farmers.update', $item->_id) : route('farmers.store') }}"
              class="p-6 space-y-3">
            @csrf
            @if(isset($item->_id)) @method('PUT') @endif

            <label class="text-xs">Tên nông dân *</label>
            <input name="name"
                   value="{{ old('name', $item->name) }}"
                   class="w-full px-3 py-2 border rounded"
                   required>

            <label class="text-xs">Số điện thoại *</label>
            <input name="phone"
                   value="{{ old('phone', $item->phone) }}"
                   class="w-full px-3 py-2 border rounded"
                   required>

            <label class="text-xs">Địa chỉ *</label>
            <input name="address"
                   value="{{ old('address', $item->address) }}"
                   class="w-full px-3 py-2 border rounded"
                   required>

            <label class="text-xs">Khu vực *</label>
            <input name="region"
                   value="{{ old('region', $item->region) }}"
                   class="w-full px-3 py-2 border rounded"
                   required>

            {{-- Lão nông phụ trách --}}
            <label class="text-xs">LN phụ trách *</label>
            <select name="lao_nong_code"
                    class="w-full px-3 py-2 border rounded"
                    required>
                <option value="">Chọn lão nông phụ trách</option>
                @foreach($seniorFarmers as $ln)
                    <option value="{{ $ln->code }}"
                        {{ old('lao_nong_code', $item->lao_nong_code ?? '') == $ln->code ? 'selected' : '' }}>
                        {{ $ln->code }} - {{ $ln->name }}
                    </option>
                @endforeach
            </select>

            {{-- Tráng nông phụ trách --}}
            <label class="text-xs">TN phụ trách *</label>
            <select name="trang_nong_code"
                    class="w-full px-3 py-2 border rounded"
                    required>
                <option value="">Chọn tráng nông phụ trách</option>
                @foreach($trangNongs as $tn)
                    <option value="{{ $tn->code }}"
                        {{ old('trang_nong_code', $item->trang_nong_code ?? '') == $tn->code ? 'selected' : '' }}>
                        {{ $tn->code }} - {{ $tn->name }}
                    </option>
                @endforeach
            </select>

            <div class="flex justify-end gap-2 pt-3 border-t mt-2">
                <a href="{{ route('farmers.index') }}"
                   class="px-4 py-2 border rounded">
                    {{ isset($item->_id) ? 'Đóng' : 'Huỷ' }}
                </a>
                <button class="px-4 py-2 bg-slate-900 text-white rounded">
                    {{ isset($item->_id) ? 'Lưu thay đổi' : 'Lưu' }}
                </button>
            </div>
        </form>
    </div>
</div>
@endsection
