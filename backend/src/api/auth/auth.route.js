const express = require('express');
const router = express.Router();
const authController = require('./auth.controller');

// --- CÁC ROUTE CHO ỨNG DỤNG NGƯỜI DÙNG (Customer App) ---
// (Các route này không gửi 'role', nên controller sẽ mặc định là 'customer')

// @route   POST /api/v1/auth/phone
// @desc    Xác thực SĐT (Customer)
router.post('/phone', authController.verifyPhoneTokenAndLogin);

// @route   POST /api/v1/auth/register
// @desc    Đăng ký bằng Username/Password (Customer)
router.post('/register', authController.register);

// @route   POST /api/v1/auth/login
// @desc    Đăng nhập (Dùng chung cho cả hai app)
router.post('/login', authController.login);


// --- ✅ THÊM CÁC ROUTE MỚI CHO ỨNG DỤNG "LÃO NÔNG" (Employee App) ---

// Middleware để chèn role 'employee'
const setRoleEmployee = (req, res, next) => {
  req.body.role = 'employee';
  next();
};

// @route   POST /api/v1/auth/phone/employee
// @desc    Xác thực SĐT (Employee)
router.post('/phone/employee', setRoleEmployee, authController.verifyPhoneTokenAndLogin);

// @route   POST /api/v1/auth/register/employee
// @desc    Đăng ký bằng Username/Password (Employee)
router.post('/register/employee', setRoleEmployee, authController.register);


module.exports = router;