import 'package:flutter/material.dart';
import 'main.dart';

class PaymentToast {
  static SnackBar _whiteToast({
    required String text,
    required IconData icon,
    required Duration duration,
  }) {
    return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      elevation: 10,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      duration: duration,
      content: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepPurple.shade400, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void clear() {
    messengerKey.currentState?.clearSnackBars();
  }

  /// Show checking for EXACT seconds.
  static void checking({int seconds = 10}) {
    clear();
    messengerKey.currentState?.showSnackBar(
      _whiteToast(
        text: "To'lov tekshirilmoqda...",
        icon: Icons.hourglass_bottom,
        duration: Duration(seconds: seconds),
      ),
    );
  }

  static void noneProcessed() {
    clear();
    messengerKey.currentState?.showSnackBar(
      _whiteToast(
        text: "Hech qanday to'lov amalga oshirilmadi",
        icon: Icons.info_outline,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void success() {
    clear();
    messengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text("To'lov muvaffaqiyatli! Premium faollashtirildi!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
      ),
    );
  }
}
