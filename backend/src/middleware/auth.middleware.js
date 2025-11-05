// src/middleware/auth.middleware.js
const jwt = require('jsonwebtoken');
const User = require('../api/users/user.model');

// Middleware: Kiểm tra xem người dùng đã đăng nhập chưa
exports.protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      // 1. Xác thực token
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // 2. CẬP NHẬT: Tìm user bằng MongoDB ID (decoded.userId)
      // thay vì 'uid' của Firebase
      req.user = await User.findById(decoded.userId).select('-password'); // Bỏ qua mật khẩu

      if (!req.user) {
         return res.status(401).json({ message: 'Không tìm thấy người dùng' });
      }

      next();
    } catch (error) {
      console.error(error);
      res.status(401).json({ message: 'Xác thực thất bại, token không hợp lệ' });
    }
  }

  if (!token) {
    res.status(401).json({ message: 'Xác thực thất bại, không tìm thấy token' });
  }
};

// Middleware: Kiểm tra vai trò (phân quyền)
// (Hàm này giữ nguyên, không cần đổi)
exports.authorize = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ 
        message: `Vai trò ${req.user.role} không có quyền truy cập chức năng này` 
      });
    }
    next();
  };
};