// src/api/users/user.model.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  // --- Dùng cho đăng nhập SĐT ---
  uid: {
    type: String,
    unique: true,
    sparse: true, // Cho phép null/trống, nhưng nếu có thì phải là duy nhất
    index: true,
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true, // Tương tự
  },

  // --- Dùng cho đăng nhập Username/Password ---
  username: {
    type: String,
    unique: true,
    sparse: true, // Tương tự
    lowercase: true,
    trim: true,
  },
  password: {
    type: String,
    // Không 'required' ở đây vì user SĐT sẽ không có
  },

  // --- Thông tin chung ---
  name: { // Sẽ dùng cho 'fullName'
    type: String,
    trim: true,
  },
  email: {
    type: String,
    trim: true,
    lowercase: true,
    unique: true,
    sparse: true, // Tương tự
  },
  role: {
    type: String,
    enum: ['customer', 'employee', 'admin'],
    default: 'customer',
  },
}, {
  timestamps: true,
});

// Mã hóa mật khẩu tự động trước khi lưu
UserSchema.pre('save', async function(next) {
  // Chỉ mã hóa nếu mật khẩu được thay đổi (hoặc là user mới)
  if (!this.isModified('password') || !this.password) {
    return next();
  }
  try {
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
    next();
  } catch (err) {
    next(err);
  }
});

// Thêm một method để so sánh mật khẩu
UserSchema.methods.comparePassword = function(candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', UserSchema);