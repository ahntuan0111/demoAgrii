const express = require('express');
const router = express.Router();
const userController = require('./user.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// --- API CHUNG ---
// User (bất kỳ ai) cập nhật vị trí của chính họ
router.put('/me/location', protect, userController.updateUserLocation);

// --- API CHO APP NÔNG DÂN (Customer) ---
// Lấy 2 Quản lý (Lão/Tráng nông) gần nhất
router.get('/nearest-managers', protect, authorize('customer'), userController.getNearestManagers);
// Lấy 2 Cửa hàng (VTNN) gần nhất
router.get('/nearest-stores', protect, authorize('customer'), userController.getNearestStores);
// Chọn 1 Quản lý
router.put('/me/select-manager', protect, authorize('customer'), userController.selectManager);
// Chọn 1 Cửa hàng
router.put('/me/select-store', protect, authorize('customer'), userController.selectStore);

// --- API CHO APP QUẢN LÝ (Lão/Tráng Nông) ---
// Lấy 2 Nông dân (customer) gần nhất
router.get('/nearest-customers', protect, authorize('laonong', 'trangnong'), userController.getNearestCustomers);
// (App Tráng Nông) Lấy danh sách Lão Nông (để chọn khi đăng ký)
router.get('/list/laonong', protect, userController.getLaoNongList);

router.put(
  '/me/kyc', 
  protect, 
  authorize('laonong', 'trangnong'), // Chỉ 2 role này được gọi
  userController.submitKyc
);

// --- ✅ THÊM ROUTE MỚI NÀY VÀO ---
// @route   PUT /api/v1/users/me/manager-profile
// @desc    (Lão/Tráng Nông) Cập nhật hồ sơ (Khu vực, Cây trồng)
router.put(
  '/me/manager-profile',
  protect, 
  authorize('laonong', 'trangnong'), // Chỉ 2 role này
  userController.updateManagerProfile
);

// --- API CHO ADMIN ---
// (Tất cả các route GET, PUT, DELETE, /promote của Admin giữ nguyên)
router.get('/', protect, authorize('admin'), userController.getAllUsers);
router.get('/:id', protect, authorize('admin'), userController.getUserById);
router.put('/:id', protect, authorize('admin'), userController.updateUser);
router.delete('/:id', protect, authorize('admin'), userController.deleteUser);
router.put('/:id/promote', protect, authorize('admin'), userController.promoteToLaoNong);

module.exports = router;