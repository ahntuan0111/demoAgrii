const express = require('express');
const router = express.Router();

const authRoutes = require('./auth/auth.route');
const productRoutes = require('./products/product.route'); // <-- 1. IMPORT
const cartRoutes = require('./cart/cart.route')
const orderRoutes = require('./orders/order.route');
const userRoutes = require('./users/user.route');
const reportRoutes = require('./reports/report.route'); // <-- 1. IMPORT
const purchaseOrderRoutes = require('./purchaseOrders/purchaseOrder.route');
const inventoryRoutes = require('./inventory/inventory.route');

// ... (Có thể có các route khác như user, order...)

// Gắn các route
router.use('/auth', authRoutes);
router.use('/products', productRoutes); // <-- 2. SỬ DỤNG
router.use('/cart', cartRoutes);
router.use('/orders', orderRoutes);
router.use('/users', userRoutes);
router.use('/reports', reportRoutes); // <-- 2. SỬ DỤNG
router.use('/purchase-orders', purchaseOrderRoutes);
router.use('/inventory', inventoryRoutes); // (API Tồn kho của VTNN)

module.exports = router;