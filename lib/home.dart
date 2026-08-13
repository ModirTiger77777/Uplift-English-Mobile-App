import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_1/text_page.dart';
import 'package:flutter_application_1/grammarPage.dart';
import 'package:flutter_application_1/formatted_text.dart';

class HomePage extends StatefulWidget {
  final int selectedId;

  const HomePage({required this.selectedId, Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 0;
  List<dynamic> dataList = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  // ⭐ IMPORTANT: Stop TTS when page is destroyed
  @override
  void dispose() {
    FormattedText.stop();
    super.dispose();
  }

  Future<void> loadJsonData() async {
    final String response = await rootBundle.loadString('assets/list.json');
    final data = json.decode(response);
    setState(() {
      dataList = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredDataList =
        dataList.where((data) => data['id'] == widget.selectedId).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text('${widget.selectedId} - dars'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade400,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: filteredDataList.length,
        itemBuilder: (BuildContext context, int index) {
          final item = filteredDataList[index];
          final String imageUrl = item['imageUrl'];
          final String text = item['text'];
          final List<String> examples = List<String>.from(item['examples']);

          return Card(
            margin: const EdgeInsets.all(16.0),
            elevation: 4,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  FormattedText(text, context: context),
                  const SizedBox(height: 16.0),
                  const Center(
                    child: Text(
                      'Misollar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: examples.map((example) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: FormattedText(example, context: context),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: (int index) async {
          // ⭐ Stop speaking before switching pages
          await FormattedText.stop();

          setState(() {
            currentPage = index;
          });

          switch (index) {
            case 0:
              break;

            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TextPage(selectedId: widget.selectedId),
                ),
              );
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
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'So\'zlar'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Hikoya'),
          BottomNavigationBarItem(
              icon: Icon(Icons.smart_button), label: 'Grammatika'),
        ],
      ),
    );
  }
}
