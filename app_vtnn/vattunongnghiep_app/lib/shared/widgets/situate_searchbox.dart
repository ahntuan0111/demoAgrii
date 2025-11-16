import 'package:flutter/material.dart';
import '../../shared/themes/app_colors.dart';

class SituateSearchBox extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const SituateSearchBox({
    super.key,
    this.hint = 'Tìm kiếm một vị trí',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(8),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.green, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.green,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.green.withOpacity(0.8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppColors.lightGreen, width: 2),
          ),
          filled: true,
          fillColor: AppColors.lightGreen.withOpacity(0.3),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
