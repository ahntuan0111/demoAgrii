const Order = require('./order.model');
const Cart = require('../cart/cart.model');
const User = require('../users/user.model');
const StoreInventory = require('../inventory/inventory.model');

// @desc    (Customer) Tạo đơn hàng mới
// @route   POST /api/v1/orders
// @access  Private (customer)
exports.createOrder = async (req, res) => {
  try {
    const {
      items,
      shippingAddress,
      paymentMethod,
      subtotal,
      shippingFee,
      vatFee,
      totalPrice
    } = req.body;

    const customer = req.user; // Từ middleware 'protect'

    // Kiểm tra 1: Phải có Cửa hàng
    if (!customer.preferredStore) {
      return res.status(400).json({ 
        message: 'Lỗi: Bạn chưa chọn cửa hàng VTNN (preferredStore).' 
      });
    }

    // --- ✅ KIỂM TRA MỚI ---
    // Kiểm tra 2: Phải có Manager (Lão Nông)
    if (!customer.managedBy) {
      return res.status(400).json({
        message: 'Lỗi: Tài khoản của bạn chưa được gán Lão Nông/Tráng Nông (managedBy).'
      });
    }

    const order = new Order({
      user: customer._id,
      store: customer.preferredStore,  // Tự động gán Cửa hàng
      
      // --- ✅ DÒNG THÊM VÀO QUAN TRỌNG ---
      manager: customer.managedBy,    // Tự động gán Manager
      
      // Dữ liệu từ FE
      orderItems: items, 
      shippingAddress: { address: shippingAddress },
      paymentMethod: paymentMethod,
      subtotal: subtotal,
      shippingFee: shippingFee,
      vatFee: vatFee,
      totalPrice: totalPrice,

      // --- ✅ CẬP NHẬT TRẠNG THÁI ---
      // Vì đã auto-assign, chuyển thẳng cho VTNN, không cần Admin duyệt
      status: 'pending_admin_approval', 
    });

    const createdOrder = await order.save();
    res.status(201).json(createdOrder);

  } catch (error) {
    console.error('Lỗi khi tạo đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// --- 2. HÀM CHO ADMIN ---
// (Các hàm getPendingOrdersForAdmin và assignOrder giữ nguyên)

// @desc    (Admin) Lấy tất cả đơn hàng chờ duyệt
// @route   GET /api/v1/orders/admin/pending
exports.getPendingOrdersForAdmin = async (req, res) => {
  try {
    const orders = await Order.find({ status: 'pending_admin_approval' })
      .populate('user', 'name phoneNumber') 
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (Admin) Gán (assign) đơn hàng cho VTNN và Lão Nông
// @route   PUT /api/v1/orders/:id/assign
exports.assignOrder = async (req, res) => {
  const { managerId, storeId, commissionPercent, shippingFee, vatPercent } = req.body; 
  
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    if (order.status !== 'pending_admin_approval') {
      return res.status(400).json({ message: 'Đơn hàng đã được xử lý.' });
    }
    
    const subtotal = order.subtotal;
    const shipping = Number(shippingFee) || 0;
    const vat = subtotal * (Number(vatPercent) / 100 || 0);
    const total = subtotal + shipping + vat;
    const commission = subtotal * (Number(commissionPercent) / 100 || 0);
    const amountPayableToStore = subtotal - commission;

    order.manager = managerId;
    order.store = storeId;
    order.commission = commission;
    order.amountPayableToStore = amountPayableToStore;
    order.shippingFee = shipping;
    order.vatFee = vat;
    order.totalPrice = total;
    order.status = 'pending_vtnn_prep'; // Chuyển cho VTNN chuẩn bị

    const updatedOrder = await order.save();
    res.json(updatedOrder);
  } catch (error) { 
    console.error('Lỗi khi gán đơn hàng:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

// --- 3. HÀM CHO VTNN (Cửa hàng) ---

// @desc    (VTNN) Lấy TẤT CẢ đơn hàng được gán cho mình
// @route   GET /api/v1/orders/store
exports.getStoreOrders = async (req, res) => {
  try {
    const orders = await Order.find({ 
      store: req.user._id,
      status: { $ne: 'pending_admin_approval' } 
    })
    .populate('user', 'name phoneNumber') 
    .populate('manager', 'name phoneNumber role') 
    .sort({ createdAt: -1 });
    
    res.json(orders);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

// @desc    (VTNN) Cập nhật trạng thái
// @route   PUT /api/v1/orders/:id/status/store
exports.updateStatusByStore = async (req, res) => {
  try {
    const { status: newStatus } = req.body; // Đọc 'status' từ body
  
    const allowedStatuses = [
      'preparing',
      'ready_for_pickup',
      'out_for_delivery'
    ];

    if (!allowedStatuses.includes(newStatus)) {
      return res.status(400).json({ message: 'Trạng thái không hợp lệ.' });
    }
    
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    if (order.store.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền' });
    }
    
    // Logic máy trạng thái
    if (newStatus === 'preparing') {
      if (order.status !== 'pending_vtnn_prep') {
        return res.status(400).json({ message: 'Không thể chuẩn bị đơn hàng này.' });
      }
      order.status = newStatus;
    }
    
    else if (newStatus === 'ready_for_pickup') {
      if (order.status !== 'preparing') {
        return res.status(400).json({ message: 'Đơn hàng chưa chuẩn bị xong.' });
      }
      order.status = newStatus;
    }

    else if (newStatus === 'out_for_delivery') {
      if (order.status !== 'awaiting_payment') {
        return res.status(400).json({ message: 'Lão nông chưa đến lấy hàng hoặc đơn chưa sẵn sàng.' });
      }
      order.status = 'out_for_delivery'; 
      order.managerPaymentStatus = 'paid_to_vtnn';
    }

    const updatedOrder = await order.save();
    
    const populatedOrder = await Order.findById(updatedOrder._id)
                                      .populate('user', 'name phoneNumber')
                                      .populate('manager', 'name phoneNumber role');
                                      
    res.status(200).json(populatedOrder);
    
  } catch (error) { 
    console.error('Lỗi updateStatusByStore:', error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

// @desc    (VTNN) Xác nhận Lão Nông đã thanh toán và xuất kho (Dự phòng)
// @route   POST /api/v1/orders/:id/dispatch
exports.dispatchOrder = async (req, res) => {
  const { pickupPhotoUrl } = req.body; 
  if (!pickupPhotoUrl) return res.status(400).json({ message: 'Vui lòng cung cấp ảnh biên lai.' });
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    if (order.store.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền' });
    }
    if (order.status !== 'awaiting_payment') {
      return res.status(400).json({ message: 'Lão nông chưa đến lấy hàng hoặc đơn chưa sẵn sàng.' });
    }
    order.status = 'out_for_delivery';
    order.managerPaymentStatus = 'paid_to_vtnn';
    order.pickupPhotoUrl = pickupPhotoUrl;
    await order.save();
    res.json(order);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};


// --- 4. HÀM CHO LÃO NÔNG / TRÁNG NÔNG (Manager) ---

// @desc    (Manager) Lấy các đơn hàng được gán
// @route   GET /api/v1/orders/manager
//
// --- ✅ ĐÂY LÀ HÀM ĐÃ ĐƯỢC VIẾT LẠI HOÀN TOÀN ---
exports.getManagerOrders = async (req, res) => {
  try {
    const manager = req.user; // Lấy Lão Nông/Tráng Nông đang đăng nhập
    
    // (Đã xóa kiểm tra 'manager.location')

    const targetStatuses = ['ready_for_pickup', 'awaiting_payment', 'out_for_delivery', 'delivered'];

    // (Đã sửa) Dùng aggregate, BỎ $geoNear, thay bằng $match và $sort
    const orders = await Order.aggregate([
      {
        // STAGE 1: Tìm các đơn hàng khớp
        $match: { 
          manager: manager._id, // Phải được gán cho TÔI
          status: { $in: targetStatuses } // Và phải ở 1 trong các trạng thái này
        }
      },
      {
        // STAGE 2: Sắp xếp (ví dụ: mới nhất lên trước)
        $sort: { createdAt: -1 }
      },
      {
        // STAGE 3: Lấy thông tin Nông dân (User)
        $lookup: {
          from: 'users',
          localField: 'user',
          foreignField: '_id',
          as: 'customerInfo'
        }
      },
      {
        // STAGE 4: Lấy thông tin Cửa hàng (Store)
        $lookup: {
          from: 'users',
          localField: 'store',
          foreignField: '_id',
          as: 'storeInfo'
        }
      },
      {
        // STAGE 5: Định dạng lại đầu ra (đã XÓA 'distance')
        $project: {
          _id: 1,
          status: 1,
          shippingAddress: 1, 
          totalPrice: 1,
          commission: 1,
          amountPayableToStore: 1, 
          // 'distance' đã bị xóa
          
          customerName: { $arrayElemAt: ["$customerInfo.name", 0] },
          storeName: { $arrayElemAt: ["$storeInfo.name", 0] },
          storeLocation: { $arrayElemAt: ["$storeInfo.location", 0] },
          
          shippingLocation: 1, // Vẫn lấy để dự phòng, nhưng không dùng để sort
          
          orderItems: 1, 
          customerPhone: { $arrayElemAt: ["$customerInfo.phoneNumber", 0] } 
        }
      }
    ]);

    res.json(orders);
  } catch (error) { 
    console.error("Lỗi getManagerOrders:", error);
    res.status(500).json({ message: 'Lỗi server' }); 
  }
};

exports.acceptDelivery = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    
    if (order.manager.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền' });
    }
    if (order.status !== 'ready_for_pickup') {
      return res.status(400).json({ message: 'Đơn hàng chưa sẵn sàng hoặc đã được nhận.' });
    }
    
    order.status = 'awaiting_payment';
    await order.save();
    res.json(order);

  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

exports.confirmDeliveryByManager = async (req, res) => {
  const { deliveryPhotoUrl } = req.body;
  if (!deliveryPhotoUrl) return res.status(400).json({ message: 'Vui lòng cung cấp ảnh giao hàng (POD).' });

  try {
    const order = await Order.findById(req.params.id);
    if (order.manager.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền' });
    }
    if (order.status !== 'out_for_delivery') {
      return res.status(400).json({ message: 'Đơn hàng chưa được xuất kho từ VTNN.' });
    }

    order.status = 'delivered';
    order.deliveryPhotoUrl = deliveryPhotoUrl;
    
    await order.save();
    res.json(order);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};


// --- 5. HÀM CHO NÔNG DÂN (Customer) ---
// (Các hàm getMyOrders và completeOrderByCustomer giữ nguyên)
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user._id })
      .populate('manager', 'name')
      .populate('store', 'name')
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};

exports.completeOrderByCustomer = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: 'Không tìm thấy đơn hàng' });
    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền' });
    }
    if (order.status !== 'delivered') {
      return res.status(400).json({ message: 'Đơn hàng chưa được giao.' });
    }

    order.status = 'completed';
    await order.save();
    res.json(order);
  } catch (error) { res.status(500).json({ message: 'Lỗi server' }); }
};