const mongoose = require('mongoose');

// Schema này định nghĩa một Biến thể (VD: Gói 25kg)
const variantSchema = new mongoose.Schema({
  name: { // Tên biến thể: "Gói 25kg", "Chai 1L"
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
  quantity: { // Số lượng tồn kho của riêng biến thể này
    type: Number,
    required: true,
    default: 0,
  },
  // (Tùy chọn) Bạn có thể thêm SKU (Mã quản lý kho) ở đây sau
  // sku: { type: String, unique: true, sparse: true }
});

module.exports = variantSchema;