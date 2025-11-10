const Order = require('./order.model');
const Cart = require('../cart/cart.model'); // Cần Cart model để xóa giỏ hàng

// @desc    Tạo đơn hàng mới
// @route   POST /api/v1/orders
// @access  Private (Cần token)
exports.createOrder = async (req, res) => {
  try {
    const userId = req.user._id;

    // 1. Lấy dữ liệu từ FE (CheckoutController sẽ gửi lên)
    const {
      shippingAddress,
      paymentMethod,
      items, // Đây là cartItems
      subtotal,
      shippingFee,
      vatFee,
      totalPrice,
    } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'Không có sản phẩm nào trong giỏ hàng' });
    }

    // 2. Tạo đối tượng Order mới
    const order = new Order({
      user: userId,
      orderItems: items,
      shippingAddress: { address: shippingAddress }, // (Sửa lại nếu FE gửi object)
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      shippingFee: shippingFee,
      vatFee: vatFee,
      totalPrice: totalPrice,
    });

    // 3. Lưu đơn hàng vào DB
    const createdOrder = await order.save();

    // 4. (QUAN TRỌNG) Xóa giỏ hàng của người dùng sau khi đã đặt hàng
    await Cart.findOneAndDelete({ user: userId });

    // 5. Trả về đơn hàng đã tạo cho FE
    res.status(201).json(createdOrder);

  } catch (error) {
    console.error('Lỗi khi tạo đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// (Tùy chọn) Thêm hàm lấy lịch sử đơn hàng của user
// @desc    Lấy đơn hàng của tôi
// @route   GET /api/v1/orders/myorders
// @access  Private
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id }).sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};