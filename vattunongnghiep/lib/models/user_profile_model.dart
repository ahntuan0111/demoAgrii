import 'address_model.dart';

class UserProfile {
  String fullName;
  String phoneNumber;
  String email;
  Address address;

  UserProfile({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

}