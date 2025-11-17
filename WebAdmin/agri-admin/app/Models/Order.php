<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use MongoDB\Laravel\Eloquent\Model; // dùng mongodb/laravel

class Order extends Model
{
    use HasFactory;

    protected $connection = 'mongodb';
    protected $collection = 'orders';

    protected $fillable = [
        'code',
        'farmer_id',
        'trang_nong_id',
        'lao_nong_id',
        'vtnn_id',          // cửa hàng VTNN
        'status_step',      // bước 1..11
        'status',           // nếu bạn muốn dùng thêm
        'total_amount',
        'items',
        'note',
    ];

    protected $casts = [
        'status_step'  => 'integer',
        'status'       => 'integer',
        'total_amount' => 'float',
        'items'        => 'array',
    ];

    /**
     * Map 11 trạng thái.
     */
    public const STATUS_STEPS = [
        1  => 'Mới',
        2  => 'Đang đến VTNN',
        3  => 'Chờ nộp tiền',
        4  => 'Đã duyệt',
        5  => 'Lấy hàng',
        6  => 'Giao hàng',
        7  => 'Gửi POD',
        8  => 'Duyệt POD',
        9  => 'Xác nhận COD',
        10 => 'Ghi KPI',
        11 => 'Đóng',
    ];

    /* ---------------------- Accessors ---------------------- */

    public function getStatusLabelAttribute(): string
    {
        return static::STATUS_STEPS[$this->status_step] ?? 'Không rõ';
    }

    /**
     * Khu vực: ưu tiên lấy từ Nông dân, nếu không có thì lấy
     * từ Tráng nông, nếu vẫn không có thì lấy từ Lão nông.
     */
    public function getRegionLabelAttribute(): ?string
    {
        // tuỳ bạn đặt tên field trong các model, mình hỗ trợ 2 kiểu: region hoặc khu_vuc
        $farmer = $this->farmer;
        if ($farmer) {
            if (!empty($farmer->region)) {
                return $farmer->region;
            }
            if (!empty($farmer->khu_vuc)) {
                return $farmer->khu_vuc;
            }
        }

        $trang = $this->trangNong;
        if ($trang) {
            if (!empty($trang->region)) {
                return $trang->region;
            }
            if (!empty($trang->khu_vuc)) {
                return $trang->khu_vuc;
            }
        }

        $lao = $this->laoNong;
        if ($lao) {
            if (!empty($lao->region)) {
                return $lao->region;
            }
            if (!empty($lao->khu_vuc)) {
                return $lao->khu_vuc;
            }
        }

        return null;
    }

    public function getFarmerCodeAttribute(): ?string
    {
        return optional($this->farmer)->code;
    }

    public function getTrangNongCodeAttribute(): ?string
    {
        return optional($this->trangNong)->code;
    }

    public function getLaoNongCodeAttribute(): ?string
    {
        return optional($this->laoNong)->code;
    }

    public function getStoreNameAttribute(): ?string
    {
        return optional($this->store)->name;
    }

    /* ---------------------- Quan hệ ------------------------ */

    // Nông dân
    public function farmer()
    {
        return $this->belongsTo(Farmer::class, 'farmer_id');
    }

    // Tráng nông
    public function trangNong()
    {
        return $this->belongsTo(TrangNong::class, 'trang_nong_id');
    }

    // Lão nông (model bạn đã đổi tên thành SeniorFarmer)
    public function laoNong()
    {
        return $this->belongsTo(SeniorFarmer::class, 'lao_nong_id');
    }

    // Alias cho tương thích nếu controller đang gọi seniorFarmer()
    public function seniorFarmer()
    {
        return $this->laoNong();
    }

    // Cửa hàng VTNN
    public function store()
    {
        return $this->belongsTo(Supplier::class, 'vtnn_id');
    }
}
