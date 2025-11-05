// src/api/auth/auth.route.js
const express = require('express');
const router = express.Router();
const authController = require('./auth.controller');

// @route   POST /api/v1/auth/phone
// @desc    Xác thực bằng SĐT (Firebase Token)
router.post('/phone', authController.verifyPhoneTokenAndLogin);

// @route   POST /api/v1/auth/register
// @desc    Đăng ký bằng Username/Password
router.post('/register', authController.register);

// @route   POST /api/v1/auth/login
// @desc    Đăng nhập bằng Username/Password
router.post('/login', authController.login);

module.exports = router;