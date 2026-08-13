import 'package:flutter/material.dart';
import 'package:flutter_application_1/grammar.dart';
import 'package:flutter_application_1/formatted_text.dart'; // Ensure this is imported
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/text_page.dart';

class GrammarPage extends StatelessWidget {
  final int selectedId;

  const GrammarPage({required this.selectedId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final grammarData = grammarList[selectedId - 1];
    final title = grammarData['title'];
    final content = grammarData['content'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Soft background
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
        title: const Text('Grammatika'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              // Changed to stretch to ensure FormattedText fills available width
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  // Center the title for grammar content
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Removed the extra Center wrapper here.
                // FormattedText's internal Column (with crossAxisAlignment: CrossAxisAlignment.center)
                // and FractionallySizedBox for centered blocks will handle alignment.
                FormattedText(content, context: context),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage(selectedId: selectedId)),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => TextPage(selectedId: selectedId)),
              );
              break;
            case 2:
              // Already on this page
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Sozlar'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Hikoya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_button), label: 'Grammatika'),
        ],
      ),
    );
  }
}
