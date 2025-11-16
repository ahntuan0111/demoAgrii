const User = require('./user.model');

// @desc    Cập nhật vị trí của người dùng (chính họ)
// @route   PUT /api/v1/users/me/location
exports.updateUserLocation = async (req, res) => {
  const { latitude, longitude } = req.body;
  if (latitude == null || longitude == null) {
    return res.status(400).json({ message: 'Vui lòng cung cấp vĩ độ và kinh độ.' });
  }
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.user._id,
      { location: { type: 'Point', coordinates: [longitude, latitude] } },
      { new: true, runValidators: true }
    );
    if (!updatedUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
    }
    res.status(200).json({
      message: 'Cập nhật vị trí thành công',
      location: updatedUser.location
    });
  } catch (error) {
    console.error('Lỗi khi cập nhật vị trí:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Manager App) Lấy 2 'customer' (Nông dân) gần nhất
// @route   GET /api/v1/users/nearest-customers
exports.getNearestCustomers = async (req, res) => {
  try {
    const manager = req.user;
    if (!manager.location || !manager.location.coordinates[0] === 0) {
      return res.status(400).json({ message: 'Vị trí của bạn chưa được thiết lập.' });
    }
    const customers = await User.aggregate([
      {
        $geoNear: {
          near: manager.location,
          distanceField: "distance",
          query: { role: 'customer' },
          distanceMultiplier: 0.001,
          spherical: true
        }
      },
      { $limit: 2 },
      { $project: { _id: 1, name: 1, location: 1, distance: 1, phoneNumber: 1 } }
    ]);
    res.status(200).json(customers);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Manager App - TrangNong) Lấy danh sách Lão Nông để chọn
// @route   GET /api/v1/users/list/laonong
exports.getLaoNongList = async (req, res) => {
  try {
    const laonongs = await User.find({ role: 'laonong' }).select('name _id');
    res.status(200).json(laonongs);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Customer App) Lấy 'manager' (Lão Nông/Tráng Nông) gần nhất
// @route   GET /api/v1/users/nearest-managers
exports.getNearestManagers = async (req, res) => {
  try {
    const customer = req.user;
    if (!customer.location || !customer.location.coordinates[0] === 0) {
      return res.status(400).json({ message: 'Vị trí của bạn chưa được thiết lập.' });
    }
    const managers = await User.aggregate([
      {
        $geoNear: {
          near: customer.location,
          distanceField: "distance",
          query: { $or: [{ role: 'laonong' }, { role: 'trangnong' }] },
          distanceMultiplier: 0.001,
          spherical: true
        }
      },
      { $limit: 2 },
      { $project: { _id: 1, name: 1, location: 1, distance: 1, role: 1 } }
    ]);
    res.status(200).json(managers);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Customer App) Lấy 'vtnn' (Cửa hàng) gần nhất
// @route   GET /api/v1/users/nearest-stores
exports.getNearestStores = async (req, res) => {
  try {
    const customer = req.user;
    if (!customer.location || !customer.location.coordinates[0] === 0) {
      return res.status(400).json({ message: 'Vị trí của bạn chưa được thiết lập.' });
    }
    const stores = await User.aggregate([
      {
        $geoNear: {
          near: customer.location,
          distanceField: "distance",
          query: { role: 'vtnn' },
          distanceMultiplier: 0.001,
          spherical: true
        }
      },
      { $limit: 2 },
      { $project: { _id: 1, name: 1, location: 1, distance: 1, phoneNumber: 1 } }
    ]);
    res.status(200).json(stores);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Customer App) Chọn Manager (Lão/Tráng Nông)
// @route   PUT /api/v1/users/me/select-manager
exports.selectManager = async (req, res) => {
  const { managerId } = req.body;
  const customerId = req.user._id;
  try {
    const manager = await User.findById(managerId);
    if (!manager || (manager.role !== 'laonong' && manager.role !== 'trangnong')) {
      return res.status(404).json({ message: 'Không tìm thấy Quản lý này.' });
    }
    const updatedCustomer = await User.findByIdAndUpdate(
      customerId, { managedBy: managerId }, { new: true }
    ).select('name role managedBy');
    res.status(200).json({ message: `Đã gán Quản lý '${manager.name}' cho bạn.`, user: updatedCustomer });
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Customer App) Chọn Cửa hàng VTNN
// @route   PUT /api/v1/users/me/select-store
exports.selectStore = async (req, res) => {
  const { storeId } = req.body;
  const customerId = req.user._id;
  try {
    const store = await User.findById(storeId);
    if (!store || store.role !== 'vtnn') {
      return res.status(404).json({ message: 'Không tìm thấy Cửa hàng này.' });
    }
    const updatedCustomer = await User.findByIdAndUpdate(
      customerId, { preferredStore: storeId }, { new: true }
    ).select('name role preferredStore');
    res.status(200).json({ message: `Đã chọn Cửa hàng '${store.name}'.`, user: updatedCustomer });
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Admin) Thăng cấp 1 Tráng nông lên Lão nông
// @route   PUT /api/v1/users/:id/promote
exports.promoteToLaoNong = async (req, res) => {
  try {
    const userIdToPromote = req.params.id;
    const trangnong = await User.findById(userIdToPromote);
    if (!trangnong || trangnong.role !== 'trangnong') {
      return res.status(404).json({ message: 'Không tìm thấy Tráng nông này.' });
    }
    trangnong.role = 'laonong';
    trangnong.reportsTo = null;
    await trangnong.save();
    res.status(200).json({ message: `Đã thăng cấp ${trangnong.name} lên Lão nông.`, user: trangnong });
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};


// --- CÁC HÀM QUẢN LÝ CỦA ADMIN ---

// @desc    (Admin) Lấy tất cả người dùng (có thể lọc theo role)
// @route   GET /api/v1/users
// @access  Admin
exports.getAllUsers = async (req, res) => {
  try {
    const filter = {};
    if (req.query.role) {
      filter.role = req.query.role; // Lọc theo ?role=customer
    }
    
    const users = await User.find(filter).select('-password'); // Bỏ qua password
    res.status(200).json(users);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Admin) Lấy chi tiết 1 người dùng bằng ID
// @route   GET /api/v1/users/:id
// @access  Admin
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    res.status(200).json(user);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Admin) Cập nhật thông tin 1 người dùng
// @route   PUT /api/v1/users/:id
// @access  Admin
exports.updateUser = async (req, res) => {
  try {
    const { name, role, managedBy, reportsTo, affiliatedStore } = req.body;
    
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id,
      { name, role, managedBy, reportsTo, affiliatedStore },
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedUser) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
    }
    res.status(200).json(updatedUser);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Admin) Xóa 1 người dùng
// @route   DELETE /api/v1/users/:id
// @access  Admin
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      // --- ✅ SỬA LỖI Ở ĐÂY ---
      return res.status(404).json({ message: 'Không tìm thấy người dùng' });
      // ----------------------
    }
    
    await User.findByIdAndDelete(req.params.id);

    res.status(200).json({ message: `Đã xóa người dùng ${user.name}` });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Tất cả User) Cập nhật ảnh đại diện (avatar)
// @route   PUT /api/v1/users/me/avatar
// @access  Private
exports.updateAvatar = async (req, res) => {
  const { avatarUrl } = req.body; // FE gửi URL từ Firebase Storage

  if (!avatarUrl) {
    return res.status(400).json({ message: 'Vui lòng cung cấp URL avatar.' });
  }

  try {
    // Cập nhật avatar cho user đang đăng nhập
    await User.findByIdAndUpdate(req.user._id, { avatar: avatarUrl });
    
    res.status(200).json({
      message: 'Cập nhật avatar thành công',
      avatarUrl: avatarUrl
    });

  } catch (error) {
    console.error('Lỗi khi cập nhật avatar:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};


// @desc    (Lão Nông/Tráng Nông) Gửi thông tin KYC để duyệt
// @route   PUT /api/v1/users/me/kyc
// @access  Private (Chỉ laonong, trangnong)
exports.submitKyc = async (req, res) => {
  const { nationalIdFrontUrl, nationalIdBackUrl, selfieUrl } = req.body;

  // 1. Kiểm tra đầu vào (FE phải gửi 3 URL)
  if (!nationalIdFrontUrl || !nationalIdBackUrl || !selfieUrl) {
    return res.status(400).json({ message: 'Vui lòng cung cấp đủ 3 ảnh (trước, sau, chân dung).' });
  }

  try {
    // 2. Tìm user (đã được authorize) và cập nhật
    const user = await User.findById(req.user._id);

    // (Middleware 'authorize' đã kiểm tra role,
    //  nhưng chúng ta kiểm tra lại cho chắc)
    if (user.role !== 'laonong' && user.role !== 'trangnong') {
       return res.status(403).json({ message: 'Chức năng này không dành cho bạn.' });
    }

    // 3. Cập nhật object kyc
    user.kyc = {
      nationalIdFrontUrl: nationalIdFrontUrl,
      nationalIdBackUrl: nationalIdBackUrl,
      selfieUrl: selfieUrl,
      status: 'pending' // <-- Đặt trạng thái là "Chờ duyệt"
    };

    await user.save();
    
    // 4. Trả về thông báo thành công
    res.status(200).json({
      message: 'Đã gửi thông tin KYC thành công. Vui lòng chờ Admin duyệt.',
      kycStatus: user.kyc.status
    });

  } catch (error) {
    console.error('Lỗi khi gửi KYC:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// --- ✅ THÊM HÀM MỚI NÀY VÀO CUỐI FILE ---

// @desc    (Lão/Tráng Nông) Cập nhật hồ sơ (Khu vực, Cây trồng, Địa chỉ)
// @route   PUT /api/v1/users/me/manager-profile
// @access  Private (laonong, trangnong)
exports.updateManagerProfile = async (req, res) => {
  try {
    // 1. Lấy dữ liệu từ FE (Màn hình "Thiết lập tài khoản")
    const { operatingArea, mainCrops, address } = req.body;

    // 2. Tìm user (đang đăng nhập)
    const user = await User.findById(req.user._id);

    if (!user) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng.' });
    }

    // (Middleware 'authorize' đã kiểm tra, nhưng ta kiểm tra lại cho chắc)
    if (user.role !== 'laonong' && user.role !== 'trangnong') {
      return res.status(403).json({ message: 'Chức năng này không dành cho vai trò của bạn.' });
    }

    // 3. Cập nhật hoặc tạo mới sub-document 'managerProfile'
    user.managerProfile = {
      operatingArea: operatingArea,
      mainCrops: mainCrops,
      address: address,
    };

    // 4. Lưu lại user
    const updatedUser = await user.save();

    res.status(200).json({
      message: 'Cập nhật hồ sơ thành công.',
      user: updatedUser // Trả về user đã cập nhật
    });

  } catch (error) {
    console.error('Lỗi khi cập nhật manager profile:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};