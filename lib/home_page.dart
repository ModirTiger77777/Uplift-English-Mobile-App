import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePag extends StatefulWidget {
  const HomePag({super.key});

  @override
  State<HomePag> createState() => _HomePagState();
}

class _HomePagState extends State<HomePag> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: signIn,
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 20),
            Text(message),
          ],
        ),
      ),
    );
  }

  // Sign up using try/catch
  Future<void> signUp() async {
    final supabase = Supabase.instance.client;
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        setState(() {
          message = 'Sign up successful! User ID: ${user.id}';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Sign up error: $e';
      });
    }
  }

  // Sign in using try/catch
  Future<void> signIn() async {
    final supabase = Supabase.instance.client;
    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = res.user;
      if (user != null) {
        setState(() {
          message = 'Sign in successful! User ID: ${user.id}';
        });

        // Fetch profile row
        final profileRes = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileRes != null) {
          setState(() {
            message += '\nProfile found: $profileRes';
          });
        } else {
          setState(() {
            message += '\nProfile not found';
          });
        }
      }
    } catch (e) {
      setState(() {
        message = 'Sign in error: $e';
      });
    }
  }
}
