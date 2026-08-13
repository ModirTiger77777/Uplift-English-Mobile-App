import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'payment_verifier.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  String get _currentUserId =>
      Supabase.instance.client.auth.currentUser?.id ?? "";

  bool _isLoading = false;
  String? _loadingProvider; // 'payme' | 'click'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ✅ Global verifier runs regardless of which page user goes to next
      PaymentVerifier.verifyIfPending(currentUserId: _currentUserId);
    }
  }

  /// URL-safe base64 that is safe to put inside a URL path.
  /// - uses base64UrlEncode (no '+' or '/')
  /// - strips '=' padding (helps on some devices/ROMs)
  String _encodeParamsForPath(String params) {
    final Uint8List bytes = Uint8List.fromList(utf8.encode(params));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  Future<void> _launchPayme() async {
    if (_currentUserId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingProvider = 'payme';
    });

    try {
      await _PaymentFlow.markStarted(userId: _currentUserId, provider: 'payme');

      // ✅ Merchant ID (production)
      const String merchantId = "69721f4363dde97b8cb8cace";

      // NOTE: Amount must be in tiyin.
      // Keep your real amount here (example is 10 000 tiyin = 100 so'm)
      const int amountInTiyn = 19000000;

      // Optional but useful: language + timeout.
      // You can also add c=<return_url> if you have a callback/deeplink.
      final String params =
          "m=$merchantId;ac.user_id=$_currentUserId;a=$amountInTiyn;l=ru;ct=15000";

      final String encodedParams = _encodeParamsForPath(params);

      // ✅ Correct checkout domain and safe construction
      final Uri url = Uri.https("checkout.paycom.uz", "/$encodedParams");

      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        // If opening fails, clear pending so it doesn't keep checking
        await _PaymentFlow.clear();
      }
      // no snackbar here (no jank)
    } catch (_) {
      // If opening fails, clear pending so it doesn't keep checking
      await _PaymentFlow.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Future<void> _launchClick() async {
    if (_currentUserId.isEmpty) return;

    setState(() {
      _isLoading = true;
      _loadingProvider = 'click';
    });

    try {
      await _PaymentFlow.markStarted(userId: _currentUserId, provider: 'click');

      const String serviceId = "93572";
      const String merchantId = "75762";
      const double amount = 190000.0;

      final String clickUrl =
          "https://my.click.uz/services/pay?service_id=$serviceId&merchant_id=$merchantId&amount=$amount&transaction_param=$_currentUserId";
      final Uri url = Uri.parse(clickUrl);

      final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!ok) {
        await _PaymentFlow.clear();
      }
    } catch (_) {
      await _PaymentFlow.clear();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // User leaves this page -> still verify globally
        PaymentVerifier.verifyIfPending(currentUserId: _currentUserId);
        Navigator.pop(context, false);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          elevation: 0,
          title: const Text(
            "To‘lov usullari",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple.shade300,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPremiumCard(),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      "Qulay usulni tanlang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  _paymentCard(
                    title: "Payme",
                    subtitle: "Bank kartalari orqali",
                    imagePath: "assets/icons/payme_logo.jpg",
                    onTap: _isLoading ? null : _launchPayme,
                    isBusy: _isLoading && _loadingProvider == 'payme',
                  ),
                  const SizedBox(height: 16),
                  _paymentCard(
                    title: "Click",
                    subtitle: "Tez va oson to‘lov",
                    imagePath: "assets/icons/click_logo.jpg",
                    onTap: _isLoading ? null : _launchClick,
                    isBusy: _isLoading && _loadingProvider == 'click',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: const Column(
        children: [
          Text(
            "PREMIUM PLAN",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "190 000 so‘m",
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Barcha kurslarga umrbod kirish",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback? onTap,
    required bool isBusy,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 52,
                width: 52,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isBusy)
                SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.deepPurple.shade300,
                  ),
                )
              else
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.black26,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentFlow {
  static const String _key = 'pending_payment_v2';

  static Future<void> markStarted({
    required String userId,
    required String provider,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'user_id': userId,
      'provider': provider,
      'started_at': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_key, jsonEncode(payload));
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
