// src/api/reports/report.controller.js
const Report = require('./report.model');
const Order = require('../orders/order.model');

// @desc    (Manager) Tạo một báo cáo sự cố mới
// @route   POST /api/v1/reports
// @access  Private (laonong, trangnong)
exports.createReport = async (req, res) => {
  try {
    // 1. Lấy dữ liệu từ FE (ReportIssueController sẽ gửi)
    const { orderId, issueType, description, imageUrl } = req.body;
    
    // 2. Lấy ID của Manager đang đăng nhập
    const managerId = req.user._id;

    if (!orderId || !issueType || !description) {
      return res.status(400).json({ message: 'Vui lòng cung cấp đầy đủ thông tin sự cố.' });
    }

    // 3. (Kiểm tra) Đảm bảo đơn hàng này thực sự được gán cho Manager này
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn hàng.' });
    }
    if (order.manager.toString() !== managerId.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền báo cáo cho đơn hàng này.' });
    }

    // 4. Tạo báo cáo mới
    const report = new Report({
      order: orderId,
      reportedBy: managerId,
      issueType: issueType,
      description: description,
      imageUrl: imageUrl, // (Có thể null nếu FE không gửi)
      status: 'pending',
    });

    // 5. Lưu vào DB
    const createdReport = await report.save();
    
    // (Tùy chọn) Bạn có thể cập nhật trạng thái đơn hàng (Order) thành 'cancelled'
    // nếu 'issueType' là "Hàng hư hỏng"
    // Ví dụ:
    // if (issueType === 'Hàng hư hỏng') {
    //   order.status = 'cancelled';
    //   await order.save();
    // }

    res.status(201).json(createdReport);

  } catch (error) {
    console.error('Lỗi khi tạo báo cáo sự cố:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// (Bạn có thể thêm các hàm cho Admin sau:
//  exports.getAllReports = ...
//  exports.updateReportStatus = ...
// )