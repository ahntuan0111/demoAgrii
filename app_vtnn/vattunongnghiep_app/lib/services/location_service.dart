// services/location_service.dart (BẢN NÂNG CẤP)
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

// Định nghĩa một lỗi riêng để Controller có thể bắt
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message; // Trả về thông báo lỗi
}

class LocationService {
  // Trả về Future<LatLng> (không có ?), vì nếu thất bại nó sẽ ném lỗi
  static Future<LatLng> getCurrentPosition() async {

    // --- Lỗi 1: Dịch vụ Vị trí (GPS) bị tắt ---
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Ném lỗi cụ thể
      throw LocationException('Vui lòng bật dịch vụ vị trí (GPS) của bạn.');
    }

    // --- Lỗi 2: Quyền (Permission) ---
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // ✅ ĐÂY LÀ DÒNG SẼ HIỂN THỊ HỘP THOẠI XIN QUYỀN
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        // Ném lỗi cụ thể
        throw LocationException('Bạn đã từ chối quyền truy cập vị trí.');
      }
    }

    // --- Lỗi 3: Từ chối vĩnh viễn ---
    if (permission == LocationPermission.deniedForever) {
      // Ném lỗi cụ thể.
      throw LocationException(
          'Quyền vị trí bị từ chối vĩnh viễn. Vui lòng vào Cài đặt ứng dụng để bật lại.');
    }

    // --- Thành công ---
    // (Nếu dùng máy ảo, nó sẽ trả về vị trí bạn set trong Emulator)
    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }
}