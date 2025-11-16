// src/api/inventory/inventory.route.js
const express = require('express');
const router = express.Router();
const inventoryController = require('./inventory.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// @route   GET /api/v1/inventory/my-store
// @desc    (App VTNN) Lấy danh sách tồn kho của chính mình
router.get(
  '/my-store', 
  protect, 
  authorize('vtnn'), 
  inventoryController.getMyStoreInventory
);

// @route   GET /api/v1/inventory/customer-store
// @desc    (App Nông Dân) Lấy sản phẩm từ VTNN mà mình đã chọn
router.get(
  '/customer-store', 
  protect, 
  authorize('customer'), 
  inventoryController.getCustomerStoreInventory
);

module.exports = router;