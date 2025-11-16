const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// --- ✅ PHẦN BỊ THIẾU CỦA BẠN LÀ ĐÂY ---
// Schema này định nghĩa các trường trong ảnh của bạn
const managerProfileSchema = new mongoose.Schema({
  operatingArea: { // Khu vực hoạt động (VD: "Long An")
    type: String,
    trim: true,
  },
  mainCrops: { // Cây trồng chính (VD: ["Lúa", "Ngô"])
    type: [String], // Mảng các chuỗi
    default: [],
  },
  address: { // Địa chỉ (VD: "")
    type: String,
    trim: true,
  }
}, { _id: false });


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

// --- ✅ VAI TRÒ & QUAN HỆ (PHẦN MỚI) ---
  role: {
    type: String,
    enum: [
      'customer',   // Nông dân (App 1)
      'trangnong',  // Tráng nông (App 2)
      'laonong',    // Lão nông (App 2)
      'vtnn',       // Vật tư nông nghiệp (App 3 - Cửa hàng)
      'admin'       // Quản trị viên
    ],
    required: true,
    default: 'customer',
  },

  // --- Dùng cho 'customer' (Nông dân) ---
  managedBy: { // Nông dân này do ai quản lý? (Lão nông / Tráng nông)
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  preferredStore: { // Nông dân này chọn mua hàng ở VTNN nào?
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },

  // --- Dùng cho 'trangnong' (Tráng nông) ---
  reportsTo: { // Tráng nông này báo cáo cho Lão nông nào?
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  
  // --- Dùng cho 'trangnong' & 'laonong' (Quản lý) ---
  affiliatedStore: { // Lão nông/Tráng nông này lấy hàng từ VTNN nào?
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },

  avatar: {
    type: String, // Sẽ lưu URL ảnh từ Firebase Storage
    default: null,
  },

  kyc: {
    nationalIdFrontUrl: { // Mặt trước CMND
      type: String,
      default: null,
    },
    nationalIdBackUrl: { // Mặt sau CMND
      type: String,
      default: null,
    },
    selfieUrl: { // Ảnh chân dung
      type: String,
      default: null,
    },
    status: {
      type: String,
      enum: ['none', 'pending', 'approved', 'rejected'], // Trạng thái duyệt
      default: 'none',
    },
  },
  // --- Schema con cho thông tin quản lý (dùng cho 'laonong' và 'trangnong') ---
  managerProfile: {
    type: managerProfileSchema, // Sử dụng schema con ở trên
    default: null // Sẽ là null cho customer, vtnn, admin
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