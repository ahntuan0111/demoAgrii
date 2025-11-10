const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const UserSchema = new mongoose.Schema({
  // --- Dùng cho đăng nhập SĐT ---
  uid: {
    type: String,
    unique: true,
    sparse: true, 
    index: true,
  },
  phoneNumber: {
    type: String,
    unique: true,
    sparse: true, 
  },

  // --- Dùng cho đăng nhập Username/Password ---
  username: {
    type: String,
    unique: true,
    sparse: true, 
    lowercase: true,
    trim: true,
  },
  password: {
    type: String,
  },

  // --- Thông tin chung ---
  name: {
    type: String,
    trim: true,
  },
  email: {
    type: String,
    trim: true,
    lowercase: true,
    unique: true,
    sparse: true, 
  },
  role: {
    type: String,
    // ✅ Đảm bảo 'employee' (cho app Lão Nông) có ở đây
    enum: ['customer', 'employee', 'admin'],
    default: 'customer', // Mặc định là 'customer'
  },
  
  // --- Vị trí (GeoJSON) ---
  location: {
    type: {
      type: String,
      enum: ['Point'],
      default: 'Point',
    },
    coordinates: {
      type: [Number], // [Kinh độ (Lon), Vĩ độ (Lat)]
      default: [0, 0],
    },
  },
}, {
  timestamps: true,
});

// Mã hóa mật khẩu tự động trước khi lưu
UserSchema.pre('save', async function(next) {
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

// Index 2dsphere cho tìm kiếm vị trí
UserSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('User', UserSchema);