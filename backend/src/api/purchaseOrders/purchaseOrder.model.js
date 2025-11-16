// src/api/purchaseOrders/purchaseOrder.model.js
const mongoose = require('mongoose');

// Schema cho 1 sản phẩm BÊN TRONG đơn đặt hàng
const poItemSchema = new mongoose.Schema({
  // Liên kết đến sản phẩm gốc (Master Product)
  product: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Product',
  },
  quantity: {
    type: Number,
    required: true,
  },
  // Lưu lại tên và giá tại thời điểm đặt
  name: { type: String, required: true },
  price: { type: Number, required: true }, // Giá gốc (giá Admin bán cho VTNN)

  variantName: { type: String, required: true }, // VD: "Bao 10kg"
  image: { type: String, required: true }, // Ảnh của sản phẩm
  
});

const purchaseOrderSchema = new mongoose.Schema({
  // Liên kết đến VTNN (Cửa hàng) đã tạo đơn này
  store: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  
  // Số PO (VD: PO-AGRII-20251112-001)
  poNumber: {
    type: String,
    unique: true,
    required: true,
    default: function() {
      // Tạo một số PO đơn giản dựa trên ngày tháng
      const now = new Date();
      const year = now.getFullYear();
      const month = (now.getMonth() + 1).toString().padStart(2, '0');
      const day = now.getDate().toString().padStart(2, '0');
      const random = Math.floor(1000 + Math.random() * 9000); // 4 số ngẫu nhiên
      return `PO-AGRII-${year}${month}${day}-${random}`;
    }
  },

  // Danh sách các sản phẩm VTNN muốn nhập
  items: [poItemSchema],
  
  // Tổng giá trị đơn hàng (VTNN phải trả cho Admin)
  totalAmount: {
    type: Number,
    required: true,
  },

  // Trạng thái (do Admin quản lý)
  status: {
    type: String,
    enum: [
      'pending',      // Chờ xử lý (Màu cam)
      'processing',   // Đang xử lý
      'shipped',      // Đang giao
      'completed',    // Đã nhận (Đã nhập kho VTNN)
      'cancelled'     // Đã hủy
    ],
    default: 'pending', // Mặc định là "Chờ xử lý"
  },
  
  // Ghi chú (nếu có)
  notes: {
    type: String,
    trim: true,
  },

}, {
  timestamps: true, // Tự động thêm createdAt, updatedAt
});

module.exports = mongoose.model('PurchaseOrder', purchaseOrderSchema);