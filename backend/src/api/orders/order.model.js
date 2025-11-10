const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User', // Tham chiếu đến người dùng đã đặt
  },
  orderItems: [ // Danh sách các sản phẩm đã mua
    {
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
    },
  ],
  shippingAddress: { // Địa chỉ giao hàng
    address: { type: String, required: true },
    // (Bạn có thể thêm city, postalCode... sau)
  },
  paymentMethod: { // Phương thức thanh toán
    type: String,
    required: true,
    enum: ['cod', 'online'], // 'cod' = Thanh toán khi nhận hàng
    default: 'cod',
  },
  subtotal: { type: Number, required: true, default: 0.0 },
  shippingFee: { type: Number, required: true, default: 0.0 },
  vatFee: { type: Number, required: true, default: 0.0 },
  totalPrice: { type: Number, required: true, default: 0.0 },

  isPaid: { type: Boolean, default: false },
  paidAt: { type: Date },
  isDelivered: { type: Boolean, default: false },
  deliveredAt: { type: Date },
}, {
  timestamps: true, // Tự động thêm createdAt, updatedAt
});

module.exports = mongoose.model('Order', orderSchema);