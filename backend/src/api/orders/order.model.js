const mongoose = require('mongoose');

// Schema cho 1 item trong đơn hàng (Giữ nguyên)
const orderItemSchema = new mongoose.Schema({
  name: { type: String, required: true },
  quantity: { type: Number, required: true },
  image: { type: String, required: true },
  price: { type: Number, required: true },
  variantName: { type: String, required: true },
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Product',
  },
});

const orderSchema = new mongoose.Schema({
  // --- LIÊN KẾT VAI TRÒ ---
  user: { // Người đặt hàng (Customer)
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  manager: { // Người quản lý/giao hàng (Lão/Tráng Nông) - Sẽ được Admin gán
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  store: { // Cửa hàng VTNN xử lý đơn - Sẽ được Admin gán
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },

  // --- THÔNG TIN ĐƠN HÀNG (Giữ nguyên) ---
  orderItems: [orderItemSchema],
  shippingAddress: {
    address: { type: String, required: true },
  },
  paymentMethod: {
    type: String,
    required: true,
    enum: ['cod', 'online'],
    default: 'cod',
  },
  shippingLocation: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [Kinh độ (Lon), Vĩ độ (Lat)]
    },
  },
  // --- GIÁ CẢ & HOA HỒNG ---
  subtotal: { type: Number, required: true, default: 0.0 }, // Tiền hàng
  shippingFee: { type: Number, required: true, default: 0.0 },
  vatFee: { type: Number, required: true, default: 0.0 },
  totalPrice: { type: Number, required: true, default: 0.0 }, // Tổng tiền Customer trả
  commission: { // Hoa hồng cho Lão/Tráng Nông (Admin sẽ set khi gán đơn)
    type: Number,
    required: true,
    default: 0.0,
  },
  // Số tiền Lão Nông phải trả cho VTNN (Giá gốc - Hoa hồng)
  amountPayableToStore: {
    type: Number,
    required: true,
    default: 0.0,
  },
  
  // --- ✅ MÁY TRẠNG THÁI (STATE MACHINE) MỚI ---
  status: {
    type: String,
    enum: [
      'pending_admin_approval', // (Customer) Mới đặt -> Chờ Admin
      'pending_vtnn_prep',      // (Admin) Đã gán -> Chờ VTNN
      'preparing',              // (VTNN) Đang soạn hàng
      'ready_for_pickup',       // (VTNN) Soạn xong -> Chờ Lão Nông
      'awaiting_payment',       // (VTNN) Lão Nông đã đến -> Chờ thanh toán
      'out_for_delivery',       // (VTNN) Đã nhận tiền, xuất kho -> Lão Nông đi giao
      'delivered',              // (Manager) Đã giao, chờ Customer xác nhận
      'completed',              // (Customer) Đã nhận hàng, Hoàn tất
      'cancelled'               // (Tất cả) Đã hủy
    ],
    default: 'pending_admin_approval', // Trạng thái đầu tiên
  },

  // --- THANH TOÁN (Manager -> VTNN) ---
  managerPaymentStatus: {
    type: String,
    enum: ['unpaid', 'paid_to_vtnn'],
    default: 'unpaid',
  },
  
  // --- BẰNG CHỨNG (Lưu URL ảnh) ---
  pickupPhotoUrl: { // Ảnh Lão Nông nhận hàng/biên lai tại VTNN
    type: String,
    default: null,
  },
  deliveryPhotoUrl: { // Ảnh Lão Nông giao hàng cho Customer (POD)
    type: String,
    default: null,
  },
  
}, {
  timestamps: true, 
});

// === ĐÃ VÔ HIỆU HÓA DÒNG NÀY ĐỂ SỬA LỖI ===
// orderSchema.index({ shippingLocation: '2dsphere' });

module.exports = mongoose.model('Order', orderSchema);