import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'payment_status.dart';
import 'payment_toast.dart';

class PaymentVerifier {
  static const String _pendingKey = 'pending_payment_v2';

  static bool _running = false;

  /// Call this whenever you want:
  /// - when app resumes
  /// - when user presses back
  /// - on cold start (AuthGate)
  ///
  /// It will NOT run twice at the same time.
  static Future<void> verifyIfPending({
    required String currentUserId,
    int maxSeconds = 10,
    int intervalSeconds = 2,
  }) async {
    if (_running) return;
    _running = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingKey);
      if (raw == null) return;

      Map<String, dynamic>? pending;
      try {
        pending = jsonDecode(raw) as Map<String, dynamic>;
      } catch (_) {
        await prefs.remove(_pendingKey);
        return;
      }

      final pendingUserId = pending['user_id'] as String?;
      if (pendingUserId == null || pendingUserId != currentUserId) {
        await prefs.remove(_pendingKey);
        return;
      }

      // ✅ Always show checking globally
      PaymentToast.checking(seconds: maxSeconds);

      final tries = (maxSeconds / intervalSeconds).ceil();
      bool success = false;

      for (int i = 0; i < tries; i++) {
        await PaymentStatus.checkPremiumStatus();
        if (PaymentStatus.isPaid) {
          success = true;
          break;
        }
        await Future.delayed(Duration(seconds: intervalSeconds));
      }

      // Clear pending so it never repeats
      await prefs.remove(_pendingKey);

      // ✅ Immediately show result globally (no mounted, no context)
      if (success) {
        PaymentToast.success();
      } else {
        PaymentToast.noneProcessed();
      }
    } finally {
      _running = false;
    }
  }
}
