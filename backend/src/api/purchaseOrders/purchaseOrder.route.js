// src/api/purchaseOrders/purchaseOrder.route.js
const express = require('express');
const router = express.Router();
const poController = require('./purchaseOrder.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// --- API CHO APP VTNN ---

// @route   POST /api/v1/purchase-orders
// @desc    (VTNN) Tạo một PO mới
router.post(
  '/', 
  protect, 
  authorize('vtnn'), 
  poController.createPurchaseOrder
);

// @route   GET /api/v1/purchase-orders/my-pos
// @desc    (VTNN) Lấy danh sách PO của tôi
router.get(
  '/my-pos', 
  protect, 
  authorize('vtnn'), 
  poController.getVtnnPurchaseOrders
);


// --- API CHO APP ADMIN ---

// @route   GET /api/v1/purchase-orders/admin
// @desc    (Admin) Lấy tất cả PO (lọc theo trạng thái)
router.get(
  '/admin',
  protect,
  authorize('admin'),
  poController.getAdminPurchaseOrders
);

// @route   PUT /api/v1/purchase-orders/:id/status
// @desc    (Admin) Cập nhật trạng thái PO
router.put(
  '/:id/status',
  protect,
  authorize('admin'),
  poController.updatePurchaseOrderStatus
);


// --- ✅ THÊM ROUTE MỚI NÀY VÀO ---
// @route   PUT /api/v1/purchase-orders/:id/receive
// @desc    (VTNN) Xác nhận đã nhận hàng và nhập kho
router.put(
  '/:id/receive',
  protect,
  authorize('vtnn'),
  poController.receivePurchaseOrder
);

module.exports = router;