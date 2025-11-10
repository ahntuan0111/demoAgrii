const admin = require('../../config/firebase');
const User = require('../users/user.model');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs'); 

/**
 * Tạo API Token (JWT của server)
 * Dùng MongoDB _id để dùng chung cho cả 2 kiểu đăng nhập
 */
const generateApiToken = (userId, role) => {
  const secret = process.env.JWT_SECRET;
  return jwt.sign({ userId, role }, secret, { expiresIn: '7d' });
};

// ===================================
// HÀM ĐĂNG NHẬP BẰNG SĐT (CẬP NHẬT)
// ===================================
exports.verifyPhoneTokenAndLogin = async (req, res) => {
  // 1. ✅ Đọc 'role' từ req.body (do route chèn vào)
  const { token, role } = req.body; 

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
        // 2. ✅ Sử dụng 'role' (nếu có), nếu không thì mặc định là 'customer'
        role: role || 'customer', 
      });
      await user.save();
    }
    
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
// HÀM ĐĂNG KÝ MỚI (CẬP NHẬT)
// ===================================
exports.register = async (req, res) => {
  try {
    // 3. ✅ Đọc 'role' từ req.body
    const { fullName, username, password, phoneNumber, role } = req.body;

    // (Kiểm tra đầu vào)
    if (!username || !password || !fullName || !phoneNumber) {
      return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin' });
    }
    if (password.length < 6) {
      return res.status(400).json({ message: 'Mật khẩu phải có ít nhất 6 ký tự' });
    }

    // (Kiểm tra user tồn tại)
    const existingUser = await User.findOne({ 
      $or: [
        { username: username.toLowerCase() }, 
        { phoneNumber: phoneNumber }
      ] 
    });
    if (existingUser) {
      if (existingUser.username === username.toLowerCase()) {
         return res.status(400).json({ message: 'Tên tài khoản đã tồn tại' });
      } else {
         return res.status(400).json({ message: 'Số điện thoại này đã được đăng ký' });
      }
    }

    // 4. ✅ Sử dụng 'role' (nếu có), nếu không thì mặc định là 'customer'
    const user = new User({
      name: fullName,
      username: username.toLowerCase(),
      password: password,
      phoneNumber: phoneNumber,
      role: role || 'customer', 
    });
    
    await user.save();

    const apiToken = generateApiToken(user._id, user.role);

    res.status(201).json({
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
// HÀM ĐĂNG NHẬP (KHÔNG THAY ĐỔI)
// ===================================
exports.login = async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ message: 'Vui lòng cung cấp username và password' });
    }

    const user = await User.findOne({ username: username.toLowerCase() });
    if (!user) {
      return res.status(401).json({ message: 'Tên tài khoản hoặc mật khẩu không đúng' });
    }

    if (!user.password) {
      return res.status(401).json({ 
        message: 'Tài khoản này được đăng ký qua SĐT. Vui lòng đăng nhập bằng SĐT.' 
      });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: 'Tên tài khoản hoặc mật khẩu không đúng' });
    }

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