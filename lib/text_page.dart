import 'package:flutter/material.dart';
import 'package:flutter_application_1/story_list.dart';
import 'package:flutter_application_1/home.dart';
import 'package:flutter_application_1/grammarPage.dart';
import 'package:flutter_application_1/formatted_text.dart';

// TextPage now catches pop events using PopScope
class TextPage extends StatefulWidget {
  final int selectedId;

  const TextPage({required this.selectedId, Key? key}) : super(key: key);

  @override
  State<TextPage> createState() => _TextPageState();
}

class _TextPageState extends State<TextPage> {
  // Always stop TTS if this widget is disposed
  @override
  void dispose() {
    FormattedText.stop();
    super.dispose();
  }

  void _stopAudio() async {
    await FormattedText.stop();
  }

  @override
  Widget build(BuildContext context) {
    final text1 = storyList[widget.selectedId - 1]['text1'];
    final text2 = storyList[widget.selectedId - 1]['text2'];
    final text3 = storyList[widget.selectedId - 1]['text3'];
    final text4 = storyList[widget.selectedId - 1]['text4'];
    final text5 = storyList[widget.selectedId - 1]['text5'];

    final stories = [text1, text2, text3, text4, text5];

    return PopScope(
      // `true` allows pop/back behavior
      canPop: true,

      // Called AFTER a pop happens — good place to stop audio
      onPopInvokedWithResult: (didPop, result) async {
        // If the route did pop successfully, stop audio immediately
        if (didPop) {
          await FormattedText.stop();
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.teal.shade400,
          foregroundColor: Colors.white,
          title: const Text('Matnlar'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              // STOP audio when back is pressed from app bar
              await FormattedText.stop();
              Navigator.pop(context);
            },
          ),
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _stopAudio,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: stories
                  .where(
                      (element) => element != null && element.trim().isNotEmpty)
                  .map((value) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _stopAudio,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: FormattedText(
                        value,
                        context: context,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 1,
          selectedItemColor: Colors.teal,
          unselectedItemColor: Colors.grey,
          onTap: (int index) async {
            await FormattedText.stop();

            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        HomePage(selectedId: widget.selectedId),
                  ),
                );
                break;

              case 1:
                break;

              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GrammarPage(selectedId: widget.selectedId),
                  ),
                );
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'Sozlar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event),
              label: 'Hikoya',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_button),
              label: 'Grammatika',
            ),
          ],
        ),
      ),
    );
  }
}
