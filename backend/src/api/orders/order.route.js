const express = require('express');
const router = express.Router();
const orderController = require('./order.controller');
const { protect } = require('../../middleware/auth.middleware');

// --- TẤT CẢ API ĐƠN HÀNG ĐỀU PHẢI ĐĂNG NHẬP ---
router.use(protect);

// POST /api/v1/orders
// Tạo đơn hàng mới
router.post('/', orderController.createOrder);

// GET /api/v1/orders/myorders
// Lấy lịch sử đơn hàng của user đang đăng nhập
router.get('/myorders', orderController.getMyOrders);

module.exports = router;