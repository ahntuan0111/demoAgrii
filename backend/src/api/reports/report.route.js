// src/api/reports/report.route.js
const express = require('express');
const router = express.Router();
const reportController = require('./report.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// @route   POST /api/v1/reports
// @desc    (Manager) Tạo một báo cáo sự cố mới
router.post(
  '/', 
  protect, 
  authorize('laonong', 'trangnong'), // Chỉ Lão/Tráng Nông
  reportController.createReport
);

// (Thêm các route cho Admin ở đây sau, ví dụ:)
// router.get('/', protect, authorize('admin'), reportController.getAllReports);

module.exports = router;