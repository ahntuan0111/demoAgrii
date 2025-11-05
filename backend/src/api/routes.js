const express = require('express');
const router = express.Router();

// Tải route xác thực
const authRoutes = require('./auth/auth.route');

// Gắn route xác thực vào đường dẫn /auth
// Kết quả cuối cùng sẽ là: /api/v1/auth
router.use('/auth', authRoutes);

// (Sau này khi bạn thêm sản phẩm, đơn hàng, bạn sẽ thêm chúng ở đây)
// const productRoutes = require('./products/product.route');
// router.use('/products', productRoutes);

module.exports = router;