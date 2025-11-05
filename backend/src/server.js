// Quan trọng: Nạp file .env trước
// Chúng ta cần chỉ đường dẫn vì server.js nằm trong 'src' còn .env nằm ở gốc
require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });

const app = require('./app');
const connectDB = require('./config/db');
const firebaseAdmin = require('./config/firebase');

// Khởi tạo kết nối DB
connectDB();

// Khởi tạo Firebase Admin (chỉ cần require là nó tự chạy)
require('./config/firebase');

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log(`Server đang chạy trên cổng ${PORT}`);
});