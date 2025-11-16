// src/api/inventory/inventory.controller.js
const StoreInventory = require('./inventory.model');
const User = require('../users/user.model'); // Cần để tìm 'preferredStore'

// @desc    (App VTNN) Lấy danh sách tồn kho của chính mình
// @route   GET /api/v1/inventory/my-store
// @access  Private (vtnn)
exports.getMyStoreInventory = async (req, res) => {
  try {
    const storeId = req.user._id; // Lấy ID VTNN đang đăng nhập
    
    const inventory = await StoreInventory.find({ store: storeId })
      .populate('product'); // Lấy chi tiết sản phẩm gốc (tên, ảnh...)
      
    res.status(200).json(inventory);
  } catch (error) {
    console.error('Lỗi khi lấy tồn kho VTNN:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    (App Nông Dân) Lấy danh sách sản phẩm TỪ VTNN MÀ MÌNH ĐÃ CHỌN
// @route   GET /api/v1/inventory/customer-store
// @access  Private (customer)
exports.getCustomerStoreInventory = async (req, res) => {
  try {
    const customerId = req.user._id;
    
    // 1. Tìm Nông Dân để biết họ đã chọn VTNN (preferredStore) nào
    const customer = await User.findById(customerId);
    if (!customer.preferredStore) {
      return res.status(400).json({ message: 'Bạn chưa chọn cửa hàng VTNN.' });
    }
    
    const storeId = customer.preferredStore;

    // 2. Lấy kho của VTNN đó
    const inventory = await StoreInventory.find({ 
      store: storeId,
      status: 'available', // Chỉ lấy hàng đang 'available'
      quantity: { $gt: 0 } // Chỉ lấy hàng còn trong kho (quantity > 0)
    })
      .populate('product'); // Lấy chi tiết sản phẩm gốc (tên, ảnh, variants...)
      
    res.status(200).json(inventory);
  } catch (error) {
    console.error('Lỗi khi lấy kho hàng của Customer:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// (Bạn có thể thêm các hàm CRUD (Create, Update, Delete) cho VTNN
//  để họ tự quản lý kho ở đây sau)