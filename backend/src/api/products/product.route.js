const express = require('express');
const router = express.Router();
const productController = require('./product.controller');
const { protect, authorize } = require('../../middleware/auth.middleware');

// --- Routes cho Người dùng (User) ---

// GET /api/v1/products
// Lấy danh sách sản phẩm (có filter)
// VD: /api/v1/products?category=seeds&brand=Bayer&minPrice=50000
// GET /api/v1/products
router.get('/', protect, productController.getProducts);

// --- ✅ THÊM ROUTE MỚI NÀY Ở ĐÂY ---
// GET /api/v1/products/brands?category=tools
router.get('/brands', protect, productController.getBrandsByCategory);
// ----------------------------------

// GET /api/v1/products/:id
// (Route này PHẢI nằm SAU route '/brands')
router.get('/:id', protect, productController.getProductById);

// POST /api/v1/products
router.post(
  '/', 
  protect, 
  authorize('admin', 'employee'), 
  productController.createProduct
);

module.exports = router;