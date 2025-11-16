const mongoose = require('mongoose');

// Schema này định nghĩa Tồn kho của Cửa hàng
// Nó liên kết 1 'store' (VTNN) với 1 'product' (Sản phẩm gốc)
const storeInventorySchema = new mongoose.Schema({
  // Liên kết đến VTNN (Cửa hàng)
  store: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  // Liên kết đến Sản phẩm gốc (Master Product)
  product: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Product',
  },
  
  // --- Thông tin của riêng VTNN ---
  
  // Giá mà VTNN này bán (có thể khác giá Admin đề xuất)
  price: {
    type: Number,
    required: true,
  },
  // Số lượng tồn kho tại VTNN này
  quantity: {
    type: Number,
    required: true,
    default: 0,
  },
  
  // (Tùy chọn: Thêm các biến thể (variants) nếu cần)
  
  status: {
    type: String,
    enum: ['available', 'unavailable'], // Hàng có sẵn/Không có sẵn
    default: 'available',
  },
}, {
  timestamps: true,
  // Tạo 1 index phức hợp để đảm bảo 1 VTNN chỉ có 1 SP
  // (Tránh trùng lặp)
  index: { unique: true, fields: { store: 1, product: 1 } },

  collection: 'inventory'
});

module.exports = mongoose.model('StoreInventory', storeInventorySchema);