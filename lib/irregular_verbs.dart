import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';

class IrregularVerbsPage extends StatefulWidget {
  const IrregularVerbsPage({super.key});

  @override
  State<IrregularVerbsPage> createState() => _IrregularVerbsPageState();
}

class _IrregularVerbsPageState extends State<IrregularVerbsPage> {
  List<dynamic> verbs = [];

  @override
  void initState() {
    super.initState();
    loadVerbs();
  }

  Future<void> loadVerbs() async {
    final String response =
        await rootBundle.loadString('assets/irregular_verbs.json');
    final data = json.decode(response);
    setState(() {
      verbs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          "Noto'g'ri fe'llar ro'yxati",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade200,
      ),
      body: verbs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: verbs.length,
              itemBuilder: (context, index) {
                final verb = verbs[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  child: ListTile(
                    title: Text(
                      "${verb['v1']} – ${verb['v2']} – ${verb['v3']}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(verb['uz']),
                  ),
                );
              },
            ),
    );
  }
}
