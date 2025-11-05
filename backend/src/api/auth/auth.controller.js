// src/api/auth/auth.controller.js
const admin = require('../../config/firebase');
const User = require('../users/user.model');
const jwt = require('jsonwebtoken');
// 1. Thêm BCRYPTJS
const bcrypt = require('bcryptjs'); 

/**
 * 2. CHUẨN HÓA HÀM TẠO TOKEN
 * Bây giờ sẽ dùng ID của MongoDB (user._id) làm khóa chính
 * để JWT có thể dùng chung cho cả 2 kiểu đăng nhập.
 */
const generateApiToken = (userId, role) => {
  const secret = process.env.JWT_SECRET;
  // Ký token với MongoDB _id
  return jwt.sign({ userId, role }, secret, { expiresIn: '7d' });
};

// ===================================
// HÀM ĐĂNG NHẬP BẰNG SĐT (CẬP NHẬT)
// ===================================
exports.verifyPhoneTokenAndLogin = async (req, res) => {
  const { token } = req.body;
  if (!token) {
    return res.status(401).json({ message: 'Vui lòng cung cấp token' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { uid, phone_number } = decodedToken;

    let user = await User.findOne({ uid: uid });

    if (!user) {
      user = new User({
        uid: uid,
        phoneNumber: phone_number,
        role: 'customer',
      });
      await user.save();
    }
    
    // 3. CẬP NHẬT: Dùng user._id thay vì user.uid
    const apiToken = generateApiToken(user._id, user.role);

    res.status(200).json({
      message: 'Xác thực thành công',
      token: apiToken,
      user: {
        id: user._id,
        uid: user.uid,
        phoneNumber: user.phoneNumber,
        role: user.role,
        name: user.name,
      },
    });

  } catch (error) {
    console.error('Lỗi xác thực token:', error);
    res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn' });
  }
};

// ===================================
// 4. HÀM ĐĂNG KÝ MỚI
// ===================================
exports.register = async (req, res) => {
  try {
    const { fullName, username, password } = req.body;

    // 1. Kiểm tra đầu vào
    if (!username || !password || !fullName) {
      return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin' });
    }
    if (password.length < 6) {
      return res.status(400).json({ message: 'Mật khẩu phải có ít nhất 6 ký tự' });
    }

    // 2. Kiểm tra user tồn tại
    const existingUser = await User.findOne({ username: username.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: 'Tên tài khoản đã tồn tại' });
    }

    // 3. Tạo user mới
    // (Mật khẩu sẽ tự động được băm nhờ 'pre-save' hook trong model)
    const user = new User({
      name: fullName,
      username: username.toLowerCase(),
      password: password,
    });
    
    await user.save();

    // 4. Tạo token và trả về
    const apiToken = generateApiToken(user._id, user.role);

    res.status(201).json({ // 201 Created
      message: 'Đăng ký thành công',
      token: apiToken,
      user: {
        id: user._id,
        username: user.username,
        role: user.role,
        name: user.name,
      },
    });

  } catch (error) {
    console.error('Lỗi đăng ký:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// ===================================
// 5. HÀM ĐĂNG NHẬP MỚI
// ===================================
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    // 1. Kiểm tra đầu vào
    if (!username || !password) {
      return res.status(400).json({ message: 'Vui lòng cung cấp username và password' });
    }

    // 2. Tìm người dùng
    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user) {
      return res.status(401).json({ message: 'Tên tài khoản hoặc mật khẩu không đúng' });
    }

    // 3. Kiểm tra user SĐT (họ không có mật khẩu)
    if (!user.password) {
      return res.status(401).json({ 
        message: 'Tài khoản này được đăng ký qua SĐT. Vui lòng đăng nhập bằng SĐT.' 
      });
    }

    // 4. So sánh mật khẩu
    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Tên tài khoản hoặc mật khẩu không đúng' });
    }

    // 5. Tạo token và trả về
    const apiToken = generateApiToken(user._id, user.role);

    res.status(200).json({
      message: 'Đăng nhập thành công',
      token: apiToken,
      user: {
        id: user._id,
        username: user.username,
        role: user.role,
        name: user.name,
      },
    });

  } catch (error) {
    console.error('Lỗi đăng nhập:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};