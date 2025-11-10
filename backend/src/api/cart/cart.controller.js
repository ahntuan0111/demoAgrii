const Cart = require('./cart.model');
const Product = require('../products/product.model'); // Cần để lấy thông tin sản phẩm

// Hàm helper để tìm giỏ hàng của user, nếu chưa có thì tạo mới
async function getUserCart(userId) {
  let cart = await Cart.findOne({ user: userId });
  if (!cart) {
    cart = new Cart({ user: userId, items: [] });
    await cart.save();
  }
  return cart;
}

// @desc    Lấy giỏ hàng của người dùng
// @route   GET /api/v1/cart
// @access  Private (Cần token)
exports.getCart = async (req, res) => {
  try {
    // req.user._id đến từ middleware 'protect'
    const cart = await getUserCart(req.user._id);
    res.status(200).json(cart);
  } catch (error) {
    console.error('Lỗi khi lấy giỏ hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    Thêm hoặc cập nhật sản phẩm trong giỏ
// @route   POST /api/v1/cart
// @access  Private
exports.addItemToCart = async (req, res) => {
  // FE sẽ gửi lên 3 thông tin này
  const { productId, variantName, quantity } = req.body;
  const userId = req.user._id;

  if (!productId || !variantName || !quantity) {
    return res.status(400).json({ message: 'Thiếu thông tin sản phẩm' });
  }

  try {
    // 1. Lấy thông tin sản phẩm (Product) và Biến thể (Variant)
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm' });
    }

    const variant = product.variants.find(v => v.name === variantName);
    if (!variant) {
      return res.status(404).json({ message: 'Không tìm thấy biến thể sản phẩm' });
    }
    
    // 2. Lấy giỏ hàng của user
    const cart = await getUserCart(userId);

    // 3. Kiểm tra xem sản phẩm (với biến thể) đã có trong giỏ chưa
    const itemIndex = cart.items.findIndex(
      item => item.productId.toString() === productId && item.variantName === variantName
    );

    if (itemIndex > -1) {
      // Nếu có -> Cập nhật số lượng
      cart.items[itemIndex].quantity += quantity;
    } else {
      // Nếu chưa có -> Thêm mới vào mảng
      cart.items.push({
        productId: productId,
        variantName: variant.name,
        quantity: quantity,
        price: variant.price, // Lấy giá từ biến thể
        name: product.name,
        image: product.images.length > 0 ? product.images[0] : '', // Lấy ảnh đầu
      });
    }

    // 4. Lưu giỏ hàng và trả về
    const updatedCart = await cart.save();
    res.status(200).json(updatedCart);

  } catch (error) {
    console.error('Lỗi khi thêm vào giỏ hàng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    Cập nhật số lượng (tăng/giảm)
// @route   PUT /api/v1/cart/:cartItemId
// @access  Private
exports.updateItemQuantity = async (req, res) => {
  const { cartItemId } = req.params;
  const { newQuantity } = req.body; // FE sẽ gửi số lượng mới (ví dụ: 2, 3, 1)

  try {
    const cart = await getUserCart(req.user._id);
    
    // .id() là hàm đặc biệt của Mongoose để tìm sub-document
    const item = cart.items.id(cartItemId);

    if (!item) {
      return res.status(404).json({ message: 'Không tìm thấy sản phẩm trong giỏ' });
    }

    if (newQuantity <= 0) {
      // Nếu số lượng <= 0, ta xóa sản phẩm
      cart.items.pull(cartItemId);
    } else {
      item.quantity = newQuantity;
    }

    const updatedCart = await cart.save();
    res.status(200).json(updatedCart);
  } catch (error) {
    console.error('Lỗi khi cập nhật số lượng:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};

// @desc    Xóa một sản phẩm khỏi giỏ hàng
// @route   DELETE /api/v1/cart/:cartItemId
// @access  Private
exports.removeItemFromCart = async (req, res) => {
  const { cartItemId } = req.params;

  try {
    const cart = await getUserCart(req.user._id);

    // Dùng hàm pull của Mongoose để xóa sub-document
    cart.items.pull(cartItemId);

    const updatedCart = await cart.save();
    res.status(200).json(updatedCart);
  } catch (error) {
    console.error('Lỗi khi xóa sản phẩm:', error);
    res.status(500).json({ message: 'Lỗi server' });
  }
};