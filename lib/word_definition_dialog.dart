import 'package:flutter/material.dart';
import 'dictionary_service.dart';
import 'formatted_text.dart'; // sizning {r:...} ni ovoz chiqarib beradigan fayl

void showWordDefinitionDialog(
    BuildContext context, String word, DictionaryResult result) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: FormattedText(
          result.baseForm,
          context: context,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(result.meanings.length, (i) {
            return Text("${i + 1}. ${result.meanings[i]}");
          }),
        ),
        actions: [
          TextButton(
            child: const Text("Yopish"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}
