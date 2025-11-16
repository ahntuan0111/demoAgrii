// src/api/purchaseOrders/purchaseOrder.controller.js
const PurchaseOrder = require('./purchaseOrder.model');
const Product = require('../products/product.model'); // Cần để lấy giá gốc
const StoreInventory = require('../inventory/inventory.model');

// --- HÀM CHO APP VTNN ---

// @desc    (VTNN) Tạo một Đơn đặt hàng (PO) mới
// @route   POST /api/v1/purchase-orders
// @access  Private (vtnn)
exports.createPurchaseOrder = async (req, res) => {
  try {
    // 1. Lấy danh sách items (Sản phẩm) từ FE
    const { items } = req.body; // VD: [{ productId: 'abc', quantity: 10 }, ...]
    const storeId = req.user._id; // VTNN đang đăng nhập

    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'Vui lòng thêm sản phẩm vào đơn hàng.' });
    }

    let totalAmount = 0;
    const processedItems = [];

    // 2. Lấy thông tin giá gốc từ 'Products' (Master list của Admin)
    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(404).json({ message: `Không tìm thấy sản phẩm với ID: ${item.productId}` });
      }
      
      const itemPrice = product.price * item.quantity;
      totalAmount += itemPrice;
      
      processedItems.push({
        product: item.productId,
        quantity: item.quantity,
        name: product.name,
        price: product.price, // Giá gốc
      });
    }

    // 3. Tạo PO mới
    const purchaseOrder = new PurchaseOrder({
      store: storeId,
      items: processedItems,
      totalAmount: totalAmount,
      status: 'pending', // Chờ Admin xử lý
      // poNumber sẽ được tự động tạo bởi model
    });

    const createdPO = await purchaseOrder.save();
    res.status(201).json(createdPO);

  } catch (error) {
    console.error('Lỗi khi tạo Đơn đặt hàng (PO):', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (VTNN) Lấy lịch sử các Đơn đặt hàng (PO) của mình
// @route   GET /api/v1/purchase-orders/my-pos
// @access  Private (vtnn)
exports.getVtnnPurchaseOrders = async (req, res) => {
  try {
    const storeId = req.user._id;
    
    // Tìm tất cả PO mà 'store' (cửa hàng) là user này
    const orders = await PurchaseOrder.find({ store: storeId })
      .sort({ createdAt: -1 }); // Sắp xếp mới nhất lên đầu
      
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};


// --- HÀM CHO APP ADMIN ---

// @desc    (Admin) Lấy tất cả Đơn đặt hàng (PO) (để quản lý)
// @route   GET /api/v1/purchase-orders/admin
// @access  Private (admin)
exports.getAdminPurchaseOrders = async (req, res) => {
  try {
    const filter = {};
    if (req.query.status) {
      filter.status = req.query.status; // Lọc theo ?status=pending
    }
    
    const orders = await PurchaseOrder.find(filter)
      .populate('store', 'name phoneNumber') // Lấy tên/SĐT của VTNN
      .sort({ createdAt: -1 });
      
    res.status(200).json(orders);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (Admin) Cập nhật trạng thái một Đơn đặt hàng (PO)
// @route   PUT /api/v1/purchase-orders/:id/status
// @access  Private (admin)
exports.updatePurchaseOrderStatus = async (req, res) => {
  try {
    const { status } = req.body; // Trạng thái mới (processing, shipped, completed...)
    
    const order = await PurchaseOrder.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn đặt hàng.' });
    }

    order.status = status;
    
    // (Logic nâng cao sau này: Nếu status = 'completed',
    //  thì tự động cộng số lượng vào 'StoreInventory' của VTNN đó)
    
    await order.save();
    res.status(200).json(order);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// --- ✅ HÀM NÀY ĐƯỢC VIẾT LẠI HOÀN TOÀN ---
// @desc    (VTNN) Tạo một Đơn đặt hàng (PO) mới
// @route   POST /api/v1/purchase-orders
// @access  Private (vtnn)
exports.createPurchaseOrder = async (req, res) => {
  try {
    // 1. Lấy danh sách items từ FE
    // FE sẽ gửi: [{ productId, variantName, quantity }, ...]
    const { items } = req.body; 
    const storeId = req.user._id;

    if (!items || items.length === 0) {
      return res.status(400).json({ message: 'Vui lòng thêm sản phẩm vào đơn hàng.' });
    }

    let totalAmount = 0;
    const processedItems = [];

    // 2. Lấy thông tin giá từ 'Products' VÀ 'Variants'
    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(404).json({ message: `Không tìm thấy sản phẩm với ID: ${item.productId}` });
      }

      // Tìm đúng "Đóng gói" (Variant)
      const variant = product.variants.find(v => v.name === item.variantName);
      if (!variant) {
        return res.status(404).json({ message: `Không tìm thấy đóng gói '${item.variantName}' cho sản phẩm '${product.name}'.` });
      }
      
      // 3. Tính giá
      const itemPrice = variant.price * item.quantity;
      totalAmount += itemPrice;
      
      processedItems.push({
        product: item.productId,
        quantity: item.quantity,
        name: product.name,
        price: variant.price, // Dùng giá của Variant
        variantName: variant.name, // Lưu tên Variant
        image: product.images.length > 0 ? product.images[0] : '', // Lưu ảnh
      });
    }

    // 4. Tạo PO mới
    const purchaseOrder = new PurchaseOrder({
      store: storeId,
      items: processedItems,
      totalAmount: totalAmount,
      status: 'pending',
    });

    const createdPO = await purchaseOrder.save();
    res.status(201).json(createdPO);

  } catch (error) {
    console.error('Lỗi khi tạo Đơn đặt hàng (PO):', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// --- ✅ 2. THÊM HÀM MỚI NÀY VÀO CUỐI FILE ---

// @desc    (VTNN) Xác nhận đã nhận hàng (Nhập kho)
// @route   PUT /api/v1/purchase-orders/:id/receive
// @access  Private (vtnn)
exports.receivePurchaseOrder = async (req, res) => {
  try {
    const orderId = req.params.id;
    const storeId = req.user._id; // VTNN đang đăng nhập

    // 1. Tìm đơn đặt hàng (PO)
    const order = await PurchaseOrder.findById(orderId);
    if (!order) {
      return res.status(404).json({ message: 'Không tìm thấy đơn đặt hàng.' });
    }

    // 2. (Bảo mật) Đảm bảo đúng là VTNN của đơn hàng này
    if (order.store.toString() !== storeId.toString()) {
      return res.status(403).json({ message: 'Bạn không có quyền với đơn hàng này.' });
    }
    
    // 3. (Logic) Chỉ xác nhận được khi Admin đã "Gửi hàng"
    if (order.status !== 'shipped') {
      return res.status(400).json({ 
        message: `Không thể xác nhận đơn ở trạng thái '${order.status}'. Chỉ xác nhận khi 'Đã gửi hàng'.` 
      });
    }

    // 4. --- LOGIC NHẬP KHO TỰ ĐỘNG ---
    // (Đây là phần quan trọng nhất)
    const updates = order.items.map(item => {
      return StoreInventory.findOneAndUpdate(
        { 
          store: storeId, 
          product: item.product // (item.product là ObjectId)
        },
        { 
          $inc: { quantity: item.quantity }, // Tăng số lượng tồn kho
          $set: { 
            price: item.price, // (Tùy chọn: Cập nhật giá bán)
            status: 'available' 
          }
        },
        { 
          upsert: true, // Nếu VTNN chưa có SP này -> tạo mới
          new: true 
        }
      );
    });
    
    await Promise.all(updates); // Thực thi tất cả các cập nhật kho
    
    // 5. Cập nhật trạng thái PO -> Hoàn tất
    order.status = 'completed';
    await order.save();

    res.status(200).json({
      message: 'Đã xác nhận nhận hàng và cập nhật kho thành công.',
      order: order
    });

  } catch (error) {
    console.error('Lỗi khi xác nhận nhận hàng (receivePurchaseOrder):', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};