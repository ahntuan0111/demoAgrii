import 'package:flutter/material.dart';

class SituateConfirmButton extends StatelessWidget {
  final VoidCallback onConfirm;
  const SituateConfirmButton({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: onConfirm,
        child: const Text(
          'Xác nhận vị trí',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
