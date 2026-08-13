import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dictionary_service.dart';
import 'word_definition_dialog.dart';
import 'formatted_text.dart'; // for TTS control

class ClickableTextSpan extends TextSpan {
  ClickableTextSpan({
    required String text,
    required BuildContext context,
    TextStyle? style,
  }) : super(
          text: text,
          style: style,
          recognizer: _buildRecognizer(text, context),
        );

  static TapGestureRecognizer? _buildRecognizer(
      String word, BuildContext context) {
    final result = DictionaryService.lookupWord(word);
    if (result == null) return null;

    return TapGestureRecognizer()
      ..onTap = () async {
        // 🔇 If TTS is speaking, stop it and skip dialog
        if (FormattedText.isSpeaking) {
          await FormattedText.stop();
          return;
        }

        // 📘 Otherwise show the real dictionary dialog
        showWordDefinitionDialog(context, word, result);
      };
  }
}
