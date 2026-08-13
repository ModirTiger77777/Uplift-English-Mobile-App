import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/payment_status.dart';
import 'package:flutter_application_1/payment_methods_page.dart';
import 'package:flutter_application_1/formatted_text.dart'; // ⭐ Added

class Darslar extends StatefulWidget {
  const Darslar({Key? key}) : super(key: key);

  @override
  State<Darslar> createState() => _DarslarState();
}

class _DarslarState extends State<Darslar> {
  List<dynamic> dataList = [];
  final int maxLessons = 150;

  int? tappedIndex;

  final List<Color> cardColors = [
    const Color(0xFFDDEBFF),
    const Color(0xFFDFFFEA),
    const Color(0xFFFFE0E0),
    const Color(0xFFFFF4CC),
    const Color(0xFFEADFFF),
    const Color(0xFFFFE9F5),
  ];

  @override
  void initState() {
    super.initState();

    // ⭐ Stop any speaking audio when this page opens
    FormattedText.stop();

    loadJsonData();
    // Optional: check premium status once at start
    // PaymentStatus.checkPremiumStatus();
  }

  Future<void> loadJsonData() async {
    final response = await rootBundle.loadString('assets/list.json');
    final data = json.decode(response);
    setState(() {
      dataList = data.take(maxLessons).toList();
    });
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.06,
            vertical: MediaQuery.of(context).size.height * 0.04,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
              maxWidth: 500,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(
                  MediaQuery.of(context).size.width * 0.05,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 48,
                      color: Colors.deepPurple,
                    ),
                    const SizedBox(height: 16),
                    const AutoSizeText(
                      "To‘lov qiling!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    const AutoSizeText(
                      "1 martalik to‘lov bilan ilovadan cheklanmagan muddatda foydalaning",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    const AutoSizeText(
                      "190 000 UZS • Umrbod foydalanish",
                      maxLines: 1,
                      minFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                          child: const Text("Keyinroq"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            Navigator.pop(context);

                            final success = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute<bool>(
                                builder: (context) =>
                                    const PaymentMethodsPage(),
                              ),
                            );

                            if (success == true && mounted) {
                              await PaymentStatus.checkPremiumStatus();
                              setState(() {});

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "To'lov muvaffaqiyatli! Premium faollashtirildi!"),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 4),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "To‘lov qilish",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Darslar"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: dataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                  itemCount: dataList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                  ),
                  itemBuilder: (context, index) {
                    final bool isFreeLesson = index < 4;
                    final bool isUnlocked =
                        PaymentStatus.isPaid || isFreeLesson;

                    return GestureDetector(
                      onTapDown: (_) => setState(() => tappedIndex = index),
                      onTapCancel: () => setState(() => tappedIndex = null),
                      onTapUp: (_) {
                        setState(() => tappedIndex = null);

                        if (!isUnlocked) {
                          _showPaymentDialog();
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomePage(selectedId: index + 1),
                          ),
                        );
                      },
                      child: AnimatedScale(
                        scale: tappedIndex == index ? 0.95 : 1,
                        duration: const Duration(milliseconds: 150),
                        child: Stack(
                          children: [
                            // 🎨 NORMAL CARD (UNCHANGED)
                            Card(
                              color: cardColors[index % cardColors.length],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              child: Center(
                                child: Text(
                                  "${index + 1} - dars",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // 🔒 SMALL LOCK ICON (TOP RIGHT)
                            if (!isUnlocked)
                              const Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
    );
  }
}
