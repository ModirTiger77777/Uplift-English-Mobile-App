import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_application_1/clickable_text_span.dart'; // Import the ClickableTextSpan

// Helper function to split a text segment into words and apply clickable spans.
List<InlineSpan> _buildClickableSpansForSegment(
    String segment, TextStyle baseStyle, BuildContext context) {
  final List<InlineSpan> wordSpans = [];
  // This regex matches words (alphanumeric characters), or non-word/non-space characters (punctuation), or spaces.
  final RegExp wordPattern = RegExp(r'\b(\w+)\b|[^\w\s]+|\s+');

  int lastMatchEnd = 0;
  for (final Match match in wordPattern.allMatches(segment)) {
    if (match.start > lastMatchEnd) {
      wordSpans.add(TextSpan(
          text: segment.substring(lastMatchEnd, match.start),
          style: baseStyle));
    }

    final String? matchedText = match.group(0);
    if (matchedText != null) {
      if (RegExp(r'^\w+$').hasMatch(matchedText)) {
        // If it's a word, wrap it in ClickableTextSpan, passing the baseStyle
        wordSpans.add(ClickableTextSpan(
          text: matchedText,
          context: context,
          style: baseStyle, // Pass the current base style to ClickableTextSpan
        ));
      } else {
        // If it's not a word (e.g., punctuation, space), add as a regular TextSpan
        wordSpans.add(TextSpan(text: matchedText, style: baseStyle));
      }
    }
    lastMatchEnd = match.end;
  }
  if (lastMatchEnd < segment.length) {
    wordSpans
        .add(TextSpan(text: segment.substring(lastMatchEnd), style: baseStyle));
  }
  return wordSpans;
}

// The main parsing function, now requiring BuildContext
List<InlineSpan> parseFormattedText(String input, BuildContext context) {
  final List<InlineSpan> spans = [];
  int currentIndex = 0;

  final RegExp pattern = RegExp(r'(\{h:(.+?)\})|(\{p:(.+?)\})|(\{r:(.+?)\})');
  const defaultStyle = TextStyle(color: Colors.black, fontSize: 16);

  final matches = pattern.allMatches(input);

  for (final match in matches) {
    final matchStart = match.start;
    final matchEnd = match.end;

    // Add plain text before the matched tag, making individual words clickable
    if (currentIndex < matchStart) {
      spans.addAll(_buildClickableSpansForSegment(
          input.substring(currentIndex, matchStart), defaultStyle, context));
    }

    // Handle different tag types
    if (match.group(1) != null) {
      // Yellow highlight {h:text}
      final text = match.group(2)!;
      spans.addAll(_buildClickableSpansForSegment(
        text,
        defaultStyle.copyWith(
          backgroundColor: const Color(0xFFFFF59D), // Light yellow background
        ),
        context,
      ));
    } else if (match.group(3) != null) {
      // Pink highlight {p:text}
      final text = match.group(4)!;
      spans.addAll(_buildClickableSpansForSegment(
        text,
        defaultStyle.copyWith(
          backgroundColor: const Color(0xFFFFCDD2), // Light pink background
        ),
        context,
      ));
    } else if (match.group(5) != null) {
      // Speaker span {r:text} - using default style (black)
      final word = match.group(6)!; // This is the word to speak

      // Use _buildClickableSpansForSegment for the word, applying default (black) style.
      // This makes the word clickable for dictionary lookup while maintaining its black color.
      spans.addAll(_buildClickableSpansForSegment(
        word,
        defaultStyle, // No color change here, remains black as per original
        context,
      ));

      // Add the speaker icon as a separate WidgetSpan right after the word
      spans.add(WidgetSpan(
        alignment:
            PlaceholderAlignment.middle, // Aligns icon vertically with text
        baseline: TextBaseline.alphabetic, // Ensures icon sits on text baseline
        child: GestureDetector(
          onTap: () async {
            final FlutterTts tts = FlutterTts();
            await tts.setLanguage('en-US');
            await tts.setSpeechRate(0.8);
            await tts.speak(word);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Icon(
              Icons.volume_up, // Speaker icon
              size: 20,
              color: Colors.black54,
            ),
          ),
        ),
      ));
    }

    currentIndex = matchEnd;
  }

  // Add any remaining plain text after the last matched tag, making individual words clickable
  if (currentIndex < input.length) {
    spans.addAll(_buildClickableSpansForSegment(
        input.substring(currentIndex), defaultStyle, context));
  }

  return spans;
}
