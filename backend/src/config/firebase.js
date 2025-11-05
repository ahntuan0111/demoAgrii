const admin = require('firebase-admin');

// Đường dẫn này tính từ thư mục gốc của dự án
const serviceAccount = require('../../serviceAccountKey.json');

// Khởi tạo 1 lần duy nhất
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  console.log('Firebase Admin Initialized.');
}

// Export ra object 'admin' đã được khởi tạo
module.exports = admin;