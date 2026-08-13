import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception("Emailni ochib bo'lmadi: $email");
    }
  }

  @override
  Widget build(BuildContext context) {
    const email = "upliftuz100@gmail.com";

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text(
          "Biz bilan bog'lanish",
          style: TextStyle(
            fontFamily:
                "Georgia", // Fancy font (siz istasangiz o‘zgartirish mumkin)
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "📩 Agar sizning savol, taklif, shikoyat yoki boshqa turdagi murojaatlaringiz bo‘lsa, bizga quyidagi email orqali bog‘lanishingiz mumkin. To'lov qilganingizdan so'ng texnik sabablarga ko'ra ilova ochilmasa ilovadan chiqib ketib qayta kirishni amalga oshiring!",
              style: TextStyle(
                fontSize: 18,
                height: 1.6,
                fontFamily: "Georgia",
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => _launchEmail(email),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade300,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade100,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  email,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Georgia",
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
