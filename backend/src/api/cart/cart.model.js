const mongoose = require('mongoose');

// Đây là schema cho 1 MẶT HÀNG (item) BÊN TRONG giỏ hàng
const cartItemSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Product', // Tham chiếu đến model Product
    required: true,
  },
  variantName: { // Ví dụ: "Gói 1kg", "Chai 500ml"
    type: String,
    required: true,
  },
  quantity: {
    type: Number,
    required: true,
    min: [1, 'Số lượng không thể nhỏ hơn 1'],
    default: 1,
  },
  // Chúng ta lưu lại giá, tên, ảnh tại thời điểm thêm vào giỏ
  // để tránh bị thay đổi nếu admin cập nhật sản phẩm
  price: {
    type: Number,
    required: true,
  },
  name: {
    type: String,
    required: true,
  },
  image: {
    type: String,
    required: true,
  },
});

// Đây là schema cho GIỎ HÀNG
const cartSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true, // Đảm bảo mỗi user chỉ có 1 giỏ hàng
  },
  items: [cartItemSchema], // Giỏ hàng là một mảng các mặt hàng
}, {
  timestamps: true,
  // Thêm Virtuals để tự động tính tổng tiền
  toJSON: { virtuals: true },
  toObject: { virtuals: true }
});

// Virtual property để tính tổng tiền (subtotal)
cartSchema.virtual('subtotal').get(function() {
  if (!this.items) return 0;
  return this.items.reduce((total, item) => total + (item.price * item.quantity), 0);
});

module.exports = mongoose.model('Cart', cartSchema);