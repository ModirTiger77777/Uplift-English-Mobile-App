import 'dart:io';
import 'dart:convert';
import 'payment_verifier.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_page.dart';
import 'payment_status.dart';
import 'main.dart'; // HomePeyj + navigatorKey
import 'payment_toast.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const String _pendingKey = 'pending_payment_v2';

  Future<bool> _checkDeviceLock(String userId) async {
    try {
      var deviceInfo = DeviceInfoPlugin();
      String? currentId;

      if (Platform.isAndroid) {
        currentId = (await deviceInfo.androidInfo).id;
      } else if (Platform.isIOS) {
        currentId = (await deviceInfo.iosInfo).identifierForVendor;
      }

      final res = await Supabase.instance.client
          .from('profiles')
          .select('locked_device_id')
          .eq('id', userId)
          .maybeSingle();

      if (res == null || res['locked_device_id'] == null) return true;
      return res['locked_device_id'] == currentId;
    } catch (_) {
      return true;
    }
  }

  Future<Map<String, dynamic>?> _readPendingPayment() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> _clearPendingPayment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingKey);
  }

  Future<bool> _pollPremiumStatus({
    required int maxTries,
    required int delaySeconds,
  }) async {
    for (int i = 0; i < maxTries; i++) {
      await PaymentStatus.checkPremiumStatus();
      if (PaymentStatus.isPaid) return true;
      await Future.delayed(Duration(seconds: delaySeconds));
    }
    return false;
  }

  Future<void> _handlePendingPaymentAfterColdStart(String userId) async {
    final pending = await _readPendingPayment();
    if (pending == null) return;

    final pendingUserId = pending['user_id'] as String?;
    if (pendingUserId != userId) {
      await _clearPendingPayment();
      return;
    }

    PaymentToast.checking();

    final success = await _pollPremiumStatus(maxTries: 5, delaySeconds: 2);

    await _clearPendingPayment();

    if (success) {
      PaymentToast.success();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState
            ?.pushNamedAndRemoveUntil('/darslar', (r) => false);
      });
    } else {
      PaymentToast.noneProcessed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return FutureBuilder(
            future: Future.wait([
              PaymentVerifier.verifyIfPending(currentUserId: session.user.id),
              PaymentStatus.checkPremiumStatus(),
              _checkDeviceLock(session.user.id),
              _handlePendingPaymentAfterColdStart(session.user.id),
            ]).timeout(
              const Duration(seconds: 12),
              // ✅ 4 ta natijaga mos bo‘lishi kerak
              // [0]=verifyIfPending, [1]=checkPremiumStatus, [2]=deviceLock, [3]=handlePending
              onTimeout: () => [null, null, true, null],
            ),
            builder: (context, AsyncSnapshot<List<dynamic>> snapshots) {
              if (snapshots.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: Color(0xFF6A5AE0),
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }

              // ✅ DEVICE LOCK natijasi [2] da!
              final bool isDeviceValid = snapshots.data?[2] ?? true;

              if (!isDeviceValid) {
                Supabase.instance.client.auth.signOut();
                return const AuthPage(
                  errorMessage:
                      "Xatolik: Ushbu akkaunt boshqa qurilmaga bog'langan!",
                );
              }

              return const HomePeyj();
            },
          );
        }

        return const AuthPage();
      },
    );
  }
}
