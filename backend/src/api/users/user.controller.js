// src/api/users/user.controller.js
const User = require('./user.model');

// @desc    Cập nhật vị trí của người dùng (chính họ)
// @route   PUT /api/v1/users/me/location
// @access  Private
exports.updateUserLocation = async (req, res) => {
  // 1. Lấy lat, lon từ FE (SituateController sẽ gửi)
  const { latitude, longitude } = req.body;

  if (latitude == null || longitude == null) {
    return res.status(400).json({ message: 'Vui lòng cung cấp vĩ độ và kinh độ.' });
  }

  try {
    // 2. Cập nhật user đang đăng nhập (lấy từ req.user._id)
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id, // req.user._id được cung cấp bởi middleware 'protect'
      {
        location: {
          type: 'Point',
          // 3. (CỰC KỲ QUAN TRỌNG) MongoDB lưu trữ [Kinh độ (Lon), Vĩ độ (Lat)]
          coordinates: [longitude, latitude] 
        }
      },
      { new: true, runValidators: true } // 'new: true' để trả về user đã cập nhật
    );

    if (!updatedUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
    }

    // 4. Trả về thông báo thành công
    res.status(200).json({
      message: 'Cập nhật vị trí thành công',
      location: updatedUser.location
    });

  } catch (error) {
    console.error('Lỗi khi cập nhật vị trí:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};