const express = require('express');
const router = express.Router();
const cartController = require('./cart.controller');
const { protect } = require('../../middleware/auth.middleware');

// --- TẤT CẢ API GIỎ HÀNG ĐỀU PHẢI ĐĂNG NHẬP ---
router.use(protect);

// GET /api/v1/cart
// Lấy giỏ hàng của user
router.get('/', cartController.getCart);

// POST /api/v1/cart
// Thêm một sản phẩm (hoặc cập nhật nếu đã tồn tại)
router.post('/', cartController.addItemToCart);

// PUT /api/v1/cart/:cartItemId
// Cập nhật số lượng của một sản phẩm
router.put('/:cartItemId', cartController.updateItemQuantity);

// DELETE /api/v1/cart/:cartItemId
// Xóa một sản phẩm khỏi giỏ hàng
router.delete('/:cartItemId', cartController.removeItemFromCart);

module.exports = router;