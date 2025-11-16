// server.js (File này nằm trong /src)

// QUAN TRỌNG: Nạp file .env ở thư mục gốc (../) NGAY LẬP TỨC
// Phải ở dòng đầu tiên trước khi 'app' được import
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const app = require('./app'); // Import ứng dụng Express từ app.js
const connectDB = require('./config/db');

// Khởi tạo kết nối MongoDB
connectDB();

// Khởi tạo Firebase Admin (file config/firebase.js sẽ tự chạy khi được require)
require('./config/firebase');

// Lấy cổng từ file .env, nếu không có thì dùng 5000
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});