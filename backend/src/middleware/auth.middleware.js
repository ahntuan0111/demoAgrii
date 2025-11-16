const jwt = require('jsonwebtoken');
const User = require('../api/users/user.model');

exports.protect = async (req, res, next) => {
  let token;

  // Dòng debug 1 (Đã có)
  console.log('SECRET TRONG MIDDLEWARE:', process.env.JWT_SECRET);

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      // === THÊM DÒNG DEBUG 2 NÀY VÀO ===
      console.log('TOKEN ĐANG KIỂM TRA:', token);
      // ===================================

      // Dòng này đang báo lỗi:
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      req.user = await User.findById(decoded.userId).select('-password'); 

      if (!req.user) {
        return res.status(401).json({ message: 'Không tìm thấy người dùng' });
      }

      next();
    } catch (error) {
      console.error(error); // Lỗi 'invalid signature' sẽ xuất hiện ở đây
      res.status(401).json({ message: 'Xác thực thất bại, token không hợp lệ' });
    }
  }
},

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