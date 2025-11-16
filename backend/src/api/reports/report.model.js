// src/api/reports/report.model.js
const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  // Liên kết đến Đơn hàng (Order)
  order: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'Order',
  },
  
  // Liên kết đến người báo cáo (Lão Nông/Tráng Nông)
  reportedBy: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },

  // --- Thông tin sự cố ---
  issueType: { // Loại sự cố (VD: "Hàng hư hỏng")
    type: String,
    required: [true, 'Vui lòng cung cấp loại sự cố.'],
    trim: true,
  },
  description: { // Mô tả chi tiết
    type: String,
    required: [true, 'Vui lòng cung cấp mô tả.'],
    trim: true,
  },
  
  // URL của ảnh minh chứng (tải lên Firebase Storage)
  imageUrl: {
    type: String,
    default: null,
  },

  // Trạng thái của báo cáo (Admin sẽ xử lý)
  status: {
    type: String,
    enum: ['pending', 'resolved', 'rejected'],
    default: 'pending', // Mặc định là "Chờ xử lý"
  },
  
}, {
  timestamps: true, // Tự động thêm createdAt, updatedAt
});

module.exports = mongoose.model('Report', reportSchema);