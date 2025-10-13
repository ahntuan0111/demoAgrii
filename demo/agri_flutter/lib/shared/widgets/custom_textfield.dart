import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final IconData? icon;
  final Function(String)? onChanged;
  final int? maxLength; // chỉ để dùng khi cần, mặc định null


  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.onChanged,
    this.maxLength, // optional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: AppColors.green) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.green),
          border: InputBorder.none,
          counterText: '', // ẩn hiển thị maxLength nếu cần
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
