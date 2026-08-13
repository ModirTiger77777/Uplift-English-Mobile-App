import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentStatus {
  static bool isPaid = false;

  // Bazadan foydalanuvchining is_premium holatini tekshirish
  static Future<void> checkPremiumStatus() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('is_premium')
            .eq('id', user.id)
            .single();

        isPaid = data['is_premium'] ?? false;
      }
    } catch (e) {
      print("Xato yuz berdi: $e");
      isPaid = false;
    }
  }
}
