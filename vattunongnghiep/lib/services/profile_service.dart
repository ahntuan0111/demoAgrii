// services/profile_service.dart
import '../models/address_model.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  // --- MOCK DATA ---
  UserProfile _mockProfile = UserProfile(
    fullName: "Nguyễn Văn A",
    phoneNumber: "0987654321",
    email: "nguyenvana@email.com",
    address: Address(
      street: "123 Đường ABC",
      ward: "Phường X",
      district: "Quận Y",
      province: "TP. Hồ Chí Minh",
    ),
  );

  // --- MOCK API CALLS ---
  Future<UserProfile> fetchUserProfile() async {
    print("Fetching user profile from server...");
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    print("Profile fetched.");
    return _mockProfile;
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    print("Updating user profile on server...");
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    _mockProfile = profile; // Update mock data
    print("Profile updated successfully.");
    return true; // Simulate success
  }
}