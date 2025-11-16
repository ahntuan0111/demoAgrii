import 'package:flutter/material.dart';
import '../themes/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final IconData? icon;
  final Function(String)? onChanged;
  final int? maxLength;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;

  // --- Thuộc tính mới thêm vào ---
  final FocusNode? focusNode;
  final TextAlign textAlign;
  final TextInputAction? textInputAction;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.onChanged,
    this.maxLength,
    this.validator,
    this.suffixIcon,

    // --- Thêm vào constructor ---
    this.focusNode,
    this.textAlign = TextAlign.start, // Mặc định là căn trái
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      // 1. ⚠️ Đổi từ TextField sang TextFormField để dùng 'validator'
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        onChanged: onChanged,
        maxLength: maxLength,
        style: const TextStyle(fontSize: 16),

        // 2. Thêm các thuộc tính còn thiếu
        validator: validator,
        focusNode: focusNode,
        textAlign: textAlign,
        textInputAction: textInputAction,

        // 3. Tự động validate khi người dùng gõ
        autovalidateMode: AutovalidateMode.onUserInteraction,

        decoration: InputDecoration(
          prefixIcon: icon != null ? Icon(icon, color: AppColors.green) : null,

          // 4. Gán suffixIcon vào
          suffixIcon: suffixIcon,

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