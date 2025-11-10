const mongoose = require('mongoose');
const variantSchema = require('./variant.schema');

// Tạo một schema nhỏ cho Đánh giá (Ratings)
const reviewSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User', // Tham chiếu đến model User (người đã đăng nhập)
  },
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
  comment: {
    type: String,
    required: true,
  },
}, {
  timestamps: true,
});

// Schema Sản phẩm chính
const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Vui lòng nhập tên sản phẩm'],
    trim: true,
  },
  description: {
    type: String,
    required: [true, 'Vui lòng nhập chi tiết sản phẩm'],
  },
  images: [
    {
      type: String, // Chúng ta sẽ lưu một mảng các URL của ảnh
      required: true,
    },
  ],
  price: {
    type: Number,
    required: [true, 'Vui lòng nhập giá hiển thị (thấp nhất)'],
  },

  category: {
    type: String,
    required: true,
    enum: {
      values: [
        'seeds',     // Hạt giống
        'tools',     // Dụng cụ
        'protection',// Sản phẩm bảo vệ
        'organic',   // Sản phẩm hữu cơ
      ],
      message: 'Category không hợp lệ',
    },
  },
  brand: {
    type: String,
    required: [true, 'Vui lòng nhập thương hiệu'],
    trim: true,
  },

  variants: [variantSchema],

  videoUrl: {
    type: String,
    default: null, // Cho phép trống
  },
  
  status: {
    type: String,
    enum: ['active', 'inactive'], // 'active' = đang bán, 'inactive' = ẩn
    default: 'active',
  },
  reviews: [reviewSchema], // Mảng các đánh giá
  averageRating: {
    type: Number,
    default: 0,
  },
  numReviews: {
    type: Number,
    default: 0,
  },
  // (Tùy chọn) Thêm tham chiếu đến người tạo/quản lý sản phẩm này
  // user: {
  //   type: mongoose.Schema.Types.ObjectId,
  //   required: true,
  //   ref: 'User',
  // }
}, {
  timestamps: true,
});

// Thêm index cho các trường hay bị filter để tăng tốc độ truy vấn
productSchema.index({ category: 1 });
productSchema.index({ brand: 1 });
productSchema.index({ price: 1 });

module.exports = mongoose.model('Product', productSchema);