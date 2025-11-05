const express = require('express');
const cors = require('cors');
const mainApiRoutes = require('./api/routes');

const app = express();

// Kích hoạt CORS (cho phép Flutter gọi API)
app.use(cors());

// Cho phép server đọc JSON từ body
app.use(express.json());

// Gắn tất cả các API vào đường dẫn /api/v1
// VD: /api/v1/auth/phone
app.use('/api/v1', mainApiRoutes);

// Middleware xử lý lỗi cơ bản (đặt cuối cùng)
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Đã có lỗi xảy ra trên server!' });
});

module.exports = app;