import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // STEP 4: Get current user
  User? get currentUser => _client.auth.currentUser;

  // STEP 5: Get profile
  Future<Map<String, dynamic>> getProfile() async {
    final user = currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    return await _client.from('profiles').select().eq('id', user.id).single();
  }
}
