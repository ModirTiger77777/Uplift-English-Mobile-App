import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/darslar.dart';
import 'package:flutter_application_1/text_page.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/dictionary_service.dart';
import 'package:flutter_application_1/instructions.dart';
import 'package:flutter_application_1/irregular_verbs.dart';
import 'package:flutter_application_1/contact.dart';
import 'package:flutter_application_1/auth_gate.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🔑 Global keys
final GlobalKey<ScaffoldMessengerState> messengerKey =
    GlobalKey<ScaffoldMessengerState>();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://xxcdxduzronoxojxsnfp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4Y2R4ZHV6cm9ub3hvanhzbmZwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc5NzI1MjIsImV4cCI6MjA4MzU0ODUyMn0.gK9iDgO8JLLub1uRRDJjtT4y90wtQnkEDOvfEBSFsxw',
  );

  try {
    await GoogleSignIn.instance.initialize(
      serverClientId:
          '462952192340-0pb0pkm5uhdrkii58s9hm1feceogln4a.apps.googleusercontent.com',
    );
  } catch (e) {
    debugPrint('Google Sign-In init error: $e');
  }

  await DictionaryService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: messengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Home Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.deepPurple.shade200,
        cardColor: Colors.white,
      ),
      home: const AuthGate(),
      routes: {
        '/darslar': (context) => const Darslar(),
        '/home': (context) => const HomePage(selectedId: 1),
        '/text': (context) => const TextPage(selectedId: 2),
        '/instructions': (context) => const InstructionsPage(),
        '/irregular_verbs': (context) => const IrregularVerbsPage(),
        '/contact': (context) => const ContactPage(),
      },
    );
  }
}

class HomePeyj extends StatefulWidget {
  const HomePeyj({super.key});

  @override
  State<HomePeyj> createState() => _HomePeyjState();
}

class _HomePeyjState extends State<HomePeyj>
    with SingleTickerProviderStateMixin {
  double _offset = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    )..addListener(() {
        setState(() {
          _offset = _animation.value;
        });
      });

    // 🔥 SHOW SNACKBAR AFTER LOGIN/SIGNUP (ONLY ONCE)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowStartupMessage();
    });
  }

  Future<void> _checkAndShowStartupMessage() async {
    final prefs = await SharedPreferences.getInstance();
    bool shown = prefs.getBool('startup_message_shown') ?? false;

    if (!shown) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Darslarni boshlashdan oldin 'Ilovadan qanday foydalanish' bo'limini o'qib chiqing",
          ),
          duration: const Duration(seconds: 8),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),

          // 🔥 BUTTON ADDED
          action: SnackBarAction(
            label: "Ochish",
            textColor: Colors.yellow,
            onPressed: () {
              Navigator.pushNamed(context, '/instructions');
            },
          ),
        ),
      );

      await prefs.setBool('startup_message_shown', true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _offset += details.delta.dy;
      if (_offset > 15) _offset = 30;
      if (_offset < -15) _offset = -30;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _animation = Tween<double>(begin: _offset, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform.translate(
          offset: Offset(0, _offset),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          const Text(
                            'Uplift English',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/darslar');
                            },
                            child: const InfoCard(
                              title: 'Asosiy darslar',
                              subtitle:
                                  'This section contains the core lessons of the application.',
                              tagText: 'Lessons',
                              tagColor: Color(0xFFE0E7FF),
                              tagTextColor: Color(0xFF4338CA),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/irregular_verbs');
                            },
                            child: const InfoCard(
                              title: 'Noto\'g\'ri fe\'llar ro\'yxati',
                              subtitle:
                                  'A comprehensive list of irregular verbs.',
                              tagText: 'Verbs',
                              tagColor: Color(0xFFFCE7F3),
                              tagTextColor: Color(0xFFBE185D),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/instructions');
                            },
                            child: const InfoCard(
                              title: 'Ilovadan qanday foydalanish',
                              subtitle:
                                  'A guide on how to use the application effectively.',
                              tagText: 'Guide',
                              tagColor: Color(0xFFD1FAE5),
                              tagTextColor: Color(0xFF047857),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/contact');
                            },
                            child: const InfoCard(
                              title: "Biz bilan bog'lanish",
                              subtitle:
                                  'Reach out to us for any questions or feedback.',
                              tagText: 'Contact',
                              tagColor: Color(0xFFFFFBEB),
                              tagTextColor: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tagText;
  final Color tagColor;
  final Color tagTextColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tagText,
    required this.tagColor,
    required this.tagTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tagText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: tagTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
