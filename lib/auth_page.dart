// auth_page.dart (updated with improved error logging - no initialize call here, as it's in main.dart)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AuthPage extends StatefulWidget {
  final String? errorMessage;
  const AuthPage({super.key, this.errorMessage});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  bool isLogin = false;
  bool isLoading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    if (widget.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showError(widget.errorMessage!);
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  // 1. UZBEK ERROR TRANSLATION LOGIC
  String _getUzbekErrorMessage(Object e) {
    if (e is AuthException) {
      final message = e.message.toLowerCase();
      if (message.contains('invalid login credentials')) {
        return 'Email yoki parol noto‘g‘ri.';
      } else if (message.contains('user already registered')) {
        return 'Bu email bilan allaqachon ro‘yxatdan o‘tilgan.';
      } else if (message.contains('unable to validate email address')) {
        return 'Email manzili noto‘g‘ri kiritildi.';
      } else if (message.contains('signup requires a valid password')) {
        return 'Ro‘yxatdan o‘tish uchun to‘g‘ri formatda parol kiritilsin';
      } else if (message.contains('network')) {
        return 'Internet aloqasi mavjud emas.';
      } else if (message.contains('password is too short')) {
        return 'Parol juda qisqa (kamida 6 ta belgi).';
      }
      return e.message;
    }
    return 'Kutilmagan xatolik yuz berdi.';
  }

  // 2. MODERN SNACKBAR DESIGN
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.redAccent.shade400,
        behavior: SnackBarBehavior.floating,
        elevation: 6,
        margin: const EdgeInsets.all(15),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  // --- DEVICE LOCK LOGIC (restored from your working version) ---
  Future<bool> _verifyAndLockDevice(String userId) async {
    try {
      var deviceInfo = DeviceInfoPlugin();
      String? currentDeviceId;

      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        currentDeviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        currentDeviceId = iosInfo.identifierForVendor;
      }

      // Fetch the profile to see if a device is already locked
      final data = await Supabase.instance.client
          .from('profiles')
          .select('locked_device_id')
          .eq('id', userId)
          .maybeSingle();

      String? existingLockedId = data?['locked_device_id'];

      if (existingLockedId == null || existingLockedId.isEmpty) {
        // No device locked yet → lock it to this phone
        await Supabase.instance.client.from('profiles').update({
          'locked_device_id': currentDeviceId,
        }).eq('id', userId);
        return true;
      } else if (existingLockedId != currentDeviceId) {
        // Device mismatch → block
        return false;
      }

      return true; // Same device → allow
    } catch (e) {
      debugPrint("Device verify error: $e");
      return true; // Fail open - don't lock user out if DB error
    }
  }

  Future<void> _handleGoogleAuth() async {
    try {
      setState(() => isLoading = true);

      final googleSignIn = GoogleSignIn.instance;

      // No initialize here - it's done in main.dart

      // Use authenticate() — this is the v7+ way
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) {
        // User canceled — just exit
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw 'Google ID Token topilmadi';
      }

      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.user != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': response.user!.id,
          'email': response.user!.email,
        });

        // Your device lock check (unchanged)
        bool isAllowed = await _verifyAndLockDevice(response.user!.id);
        if (!isAllowed) {
          await Supabase.instance.client.auth.signOut();
          _showError('Xatolik: Ushbu akkaunt boshqa qurilmaga bog\'langan!');
          return;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Google auth FULL error: $e'); // for console
      debugPrint('Stack trace: $stackTrace'); // for detailed debugging
      _showError(_getUzbekErrorMessage(e)); // your custom Uzbek translator
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleAuth() async {
    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;

    try {
      AuthResponse res;
      if (isLogin) {
        res = await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );
      } else {
        res = await supabase.auth.signUp(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (res.user != null) {
          await supabase.from('profiles').upsert({
            'id': res.user!.id,
            'email': res.user!.email,
          });
        }
      }

      if (res.user != null) {
        bool isAllowed = await _verifyAndLockDevice(res.user!.id);
        if (!isAllowed) {
          await supabase.auth.signOut();
          _showError('Xatolik: Ushbu akkaunt boshqa qurilmaga bog\'langan!');
          return;
        }
      }
    } catch (e) {
      _showError(_getUzbekErrorMessage(e));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A5AE0), Color(0xFF8F7AFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 18,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                    child: Padding(
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 40, color: Color(0xFF6A5AE0)),
                          const SizedBox(height: 12),
                          const Text('Uplift English',
                              style: TextStyle(
                                  fontSize: 26, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                              isLogin
                                  ? 'Akkauntingizga kiring'
                                  : 'Ro‘yxatdan o‘ting',
                              style: const TextStyle(color: Colors.black54)),
                          const SizedBox(height: 24),
                          _inputField(
                              controller: emailController,
                              label: 'Email',
                              icon: Icons.email_outlined),
                          const SizedBox(height: 14),
                          _inputField(
                              controller: passwordController,
                              label: 'Parol',
                              icon: Icons.lock_outline,
                              obscure: true),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleAuth,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6A5AE0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16))),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      isLogin ? 'Kirish' : 'Ro‘yxatdan o‘tish',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          if (isLogin) ...[
                            const SizedBox(height: 16),
                            const AutoSizeText(
                                'Parolingizni eslay olmasangiz, Google orqali kirishni tanlang',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontStyle: FontStyle.italic)),
                          ],
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: isLoading ? null : _handleGoogleAuth,
                            icon: Image.asset('assets/icons/google_icon.png',
                                height: 20),
                            label: const AutoSizeText(
                                'Google bilan davom etish',
                                maxLines: 1,
                                minFontSize: 10,
                                style: TextStyle(fontSize: 14)),
                            style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16))),
                          ),
                          const SizedBox(height: 14),
                          FittedBox(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(isLogin
                                    ? 'Akkauntingiz yo‘qmi?'
                                    : 'Allaqachon akkauntingiz bormi?'),
                                TextButton(
                                  onPressed: () {
                                    setState(() => isLogin = !isLogin);
                                    _controller.forward(from: 0);
                                  },
                                  child: Text(
                                      isLogin ? 'Ro‘yxatdan o‘tish' : 'Kirish'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
