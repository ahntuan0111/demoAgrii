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

// --- 1. CHO APP NÔNG DÂN (CUSTOMER) ---
// (Phần này giữ nguyên, không thay đổi)
exports.registerCustomer = async (req, res) => {
  try {
    const { fullName, username, password, phoneNumber } = req.body;
    if (!username || !password || !fullName || !phoneNumber) {
      return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin' });
    }
    const existingUser = await User.findOne({ $or: [{ username: username.toLowerCase() }, { phoneNumber: phoneNumber }] });
    if (existingUser) { return res.status(400).json({ message: 'Tên tài khoản hoặc SĐT đã tồn tại' }); }

    const user = new User({
      name: fullName,
      username: username.toLowerCase(),
      password: password,
      phoneNumber: phoneNumber,
      role: 'customer', // Gán cứng
    });
    
    await user.save();
    const apiToken = generateApiToken(user._id, user.role);
    res.status(201).json({ token: apiToken, user });
  } catch (error) { 
    console.error('Lỗi registerCustomer:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

exports.verifyPhoneCustomer = async (req, res) => {
  const { token } = req.body; 
  if (!token) { return res.status(401).json({ message: 'Vui lòng cung cấp token' }); }
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { uid, phone_number } = decodedToken;
    let user = await User.findOne({ uid: uid });
    if (!user) {
      user = new User({ uid: uid, phoneNumber: phone_number, role: 'customer' }); // Gán cứng
      await user.save();
    }
    const apiToken = generateApiToken(user._id, user.role);
    res.status(200).json({ token: apiToken, user });
  } catch (error) { 
    console.error('Lỗi verifyPhoneCustomer:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};


// --- 2. CHO APP LÃO NÔNG / TRÁNG NÔNG (MANAGER) ---
// (ĐÃ CẬP NHẬT THEO LOGIC MỚI CỦA BẠN)

// @desc    Đăng ký Manager (Mặc định 'trangnong', không cần 'reportsTo')
exports.registerManager = async (req, res) => {
  try {
    // 1. ✅ BỎ 'reportsTo' khỏi req.body
    const { fullName, username, password, phoneNumber } = req.body;

    // 2. ✅ BỎ KIỂM TRA 'reportsTo'
    // if (!reportsTo) { ... }
    
    // (Kiểm tra đầu vào, không còn 'reportsTo')
    if (!username || !password || !fullName || !phoneNumber) {
      return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin' });
    }
    const existingUser = await User.findOne({ $or: [{ username: username.toLowerCase() }, { phoneNumber: phoneNumber }] });
    if (existingUser) { return res.status(400).json({ message: 'Tên tài khoản hoặc SĐT đã tồn tại' }); }

    const user = new User({
      name: fullName,
      username: username.toLowerCase(),
      password: password,
      phoneNumber: phoneNumber,
      role: 'trangnong', // 3. ✅ GÁN CỨNG LÀ 'trangnong'
      reportsTo: null, // 4. ✅ MẶC ĐỊNH LÀ 'null'
    });
    
    await user.save();
    const apiToken = generateApiToken(user._id, user.role);
    res.status(201).json({ token: apiToken, user });

  } catch (error) { 
    console.error('Lỗi registerManager:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

// @desc    Xác thực SĐT Manager (Mặc định 'trangnong', không cần 'reportsTo')
exports.verifyPhoneManager = async (req, res) => {
  // 5. ✅ BỎ 'reportsTo' khỏi req.body
  const { token } = req.body; 
  if (!token) { return res.status(401).json({ message: 'Vui lòng cung cấp token' }); }
  
  try {
    // 6. ✅ BỎ KIỂM TRA 'reportsTo'
    
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { uid, phone_number } = decodedToken;
    let user = await User.findOne({ uid: uid });

    if (!user) {
      user = new User({
        uid: uid,
        phoneNumber: phone_number,
        role: 'trangnong', // 7. ✅ GÁN CỨNG LÀ 'trangnong'
        reportsTo: null, // 8. ✅ MẶC ĐỊNH LÀ 'null'
      });
      await user.save();
    }
    
    const apiToken = generateApiToken(user._id, user.role);
    res.status(200).json({ token: apiToken, user });
  } catch (error) { 
    console.error('Lỗi verifyPhoneManager:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

// --- 3. CHO APP VẬT TƯ (VTNN / STORE) ---
// (Các hàm 'registerStore' và 'verifyPhoneStore' giữ nguyên, không đổi)
exports.registerStore = async (req, res) => {
  try {
    const { fullName, username, password, phoneNumber } = req.body;
    // (Kiểm tra đầu vào và user tồn tại...)
    const existingUser = await User.findOne({ $or: [{ username: username.toLowerCase() }, { phoneNumber: phoneNumber }] });
    if (existingUser) { return res.status(400).json({ message: 'Tên tài khoản hoặc SĐT đã tồn tại' }); }

    const user = new User({
      name: fullName, // Tên cửa hàng
      username: username.toLowerCase(),
      password: password,
      phoneNumber: phoneNumber,
      role: 'vtnn', // Gán cứng là 'vtnn'
    });
    
    await user.save();
    const apiToken = generateApiToken(user._id, user.role);
    res.status(201).json({ token: apiToken, user });
  } catch (error) { 
    console.error('Lỗi registerStore:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

exports.verifyPhoneStore = async (req, res) => {
  const { token } = req.body; 
  if (!token) { return res.status(401).json({ message: 'Vui lòng cung cấp token' }); }
  try {
    const decodedToken = await admin.auth().verifyIdToken(token);
    const { uid, phone_number } = decodedToken;
    let user = await User.findOne({ uid: uid });
    if (!user) {
      user = new User({
        uid: uid,
        name: `Cửa hàng ${phone_number.slice(-4)}`, // Tên tạm
        phoneNumber: phone_number,
        role: 'vtnn' // Gán cứng
      });
      await user.save();
    }
    const apiToken = generateApiToken(user._id, user.role);
    res.status(200).json({ token: apiToken, user });
  } catch (error) { 
    console.error('Lỗi verifyPhoneStore:', error);
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