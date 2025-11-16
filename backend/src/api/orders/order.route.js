// src/api/orders/order.route.js (BẢN CHỈNH SỬA HOÀN CHỈNH)
const express = require('express');
const router = express.Router();
const orderController = require('./order.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// --- API CHO APP NÔNG DÂN (Customer) ---
// Tạo đơn hàng
router.post(
  '/', 
  protect, 
  authorize('customer'), 
  orderController.createOrder
);
// Lấy lịch sử đơn hàng
router.get(
  '/myorders', 
  protect, 
  authorize('customer'), 
  orderController.getMyOrders
);
// Xác nhận "Đã nhận được hàng"
router.put(
  '/:id/complete', 
  protect, 
  authorize('customer'), 
  orderController.completeOrderByCustomer
);

// --- API CHO APP LÃO NÔNG / TRÁNG NÔNG (Manager) ---
// Lấy danh sách đơn hàng được gán (Màn hình Tiếp nhận đơn hàng)
router.get(
  '/manager',
  protect,
  authorize('laonong', 'trangnong'),
  orderController.getManagerOrders
);

router.put(
  '/:id/accept-delivery',
  protect,
  authorize('laonong', 'trangnong'),
  orderController.acceptDelivery
);

// Xác nhận đã giao hàng (Gửi ảnh POD)
router.put(
  '/:id/deliver',
  protect,
  authorize('laonong', 'trangnong'),
  orderController.confirmDeliveryByManager
);

// --- API CHO APP VẬT TƯ (VTNN) ---
// Lấy danh sách đơn hàng mới (chờ chuẩn bị)
router.get(
  '/store',
  protect,
  authorize('vtnn'),
  orderController.getStoreOrders
);
// Cập nhật trạng thái (Chuẩn bị/Sẵn sàng)
router.put(
  '/:id/status/store',
  protect,
  authorize('vtnn'),
  orderController.updateStatusByStore
);
// Xác nhận Manager đã trả tiền và xuất kho (Gửi ảnh biên lai)
router.post(
  '/:id/dispatch',
  protect,
  authorize('vtnn'),
  orderController.dispatchOrder
);

// --- API CHO ADMIN ---
// Lấy các đơn hàng chờ duyệt
router.get(
  '/admin/pending',
  protect,
  authorize('admin'),
  orderController.getPendingOrdersForAdmin
);
// Gán đơn hàng cho VTNN và Manager
router.put(
  '/:id/assign',
  protect,
  authorize('admin'),
  orderController.assignOrder
);

module.exports = router;