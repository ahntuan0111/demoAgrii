// src/api/users/user.route.js
const express = require('express');
const router = express.Router();
const userController = require('./user.controller');
const { protect } = require('../../middleware/auth.middleware');

// @route   PUT /api/v1/users/me/location
// @desc    User cập nhật vị trí của chính họ
router.put('/me/location', protect, userController.updateUserLocation);

// (Sau này bạn có thể thêm các route khác như:
// GET /me (lấy thông tin cá nhân)
// PUT /me (cập nhật hồ sơ)
// ...
// )

module.exports = router;