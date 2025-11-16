const express = require('express');
const router = express.Router();
const authController = require('./auth.controller');

// --- APP 1: NÔNG DÂN (CUSTOMER) ---
router.post('/phone', authController.verifyPhoneCustomer);
router.post('/register', authController.registerCustomer);

// --- APP 2: LÃO NÔNG / TRÁNG NÔNG (MANAGER) ---
router.post('/phone/manager', authController.verifyPhoneManager);
router.post('/register/manager', authController.registerManager);

// --- APP 3: VẬT TƯ NÔNG NGHIỆP (STORE/VTNN) ---
router.post('/phone/store', authController.verifyPhoneStore);
router.post('/register/store', authController.registerStore);

// --- API ĐĂNG NHẬP CHUNG ---
router.post('/login', authController.login);

module.exports = router;