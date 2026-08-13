import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'clickable_text_span.dart';
import 'dart:math' as math;

class FormattedText extends StatelessWidget {
  final String text;
  final BuildContext context;

  static final FlutterTts _tts = FlutterTts();
  static bool _isConfigured = false;
  static bool _isSpeaking = false;

  static String? _currentlySpeakingWord;
  static final ValueNotifier<String?> speakingNotifier = ValueNotifier<String?>(
    null,
  );

  static bool get isSpeaking => _isSpeaking;

  static Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    _isSpeaking = false;
    _currentlySpeakingWord = null;
    speakingNotifier.value = null;
  }

  static Future<void> speak(String text) async {
    try {
      await stop();

      _currentlySpeakingWord = text;
      speakingNotifier.value = text;

      await _configureTtsOnce();

      _isSpeaking = true;

      try {
        await _tts.awaitSpeakCompletion(true);
      } catch (_) {}

      await _tts.speak(text);
    } catch (_) {
      _isSpeaking = false;
      _currentlySpeakingWord = null;
      speakingNotifier.value = null;
    }
  }

  FormattedText(this.text, {super.key, required this.context}) {
    _configureTtsOnce();
  }

  static Future<void> _configureTtsOnce() async {
    if (_isConfigured) return;

    try {
      await _tts.setLanguage('en-US');

      if (Platform.isAndroid) {
        await _tts.setSpeechRate(0.5);
      } else if (Platform.isIOS) {
        await _tts.setSpeechRate(0.8);
      } else {
        await _tts.setSpeechRate(0.7);
      }

      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        _isSpeaking = true;
      });

      _tts.setCompletionHandler(() {
        stop();
      });

      _tts.setCancelHandler(() {
        stop();
      });

      _tts.setErrorHandler((_) {
        stop();
      });

      _isConfigured = true;
    } catch (_) {
      _isConfigured = true;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (FormattedText.isSpeaking) FormattedText.stop();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: _parseFormattedTextToWidgets(text, ctx),
      ),
    );
  }

  List<Widget> _parseFormattedTextToWidgets(String text, BuildContext context) {
    final List<Widget> widgets = [];
    final centerExp = RegExp(r'\[center](.+?)\[/center]', dotAll: true);

    int lastIndex = 0;

    for (final match in centerExp.allMatches(text)) {
      if (match.start > lastIndex) {
        widgets.add(
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 16, color: Colors.black),
              children: _parseLineSpans(
                text.substring(lastIndex, match.start),
                context,
              ),
            ),
          ),
        );
      }

      widgets.add(
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Text.rich(
              TextSpan(
                children: _parseLineSpans(match.group(1)!, context),
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      widgets.add(
        RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 16, color: Colors.black),
            children: _parseLineSpans(text.substring(lastIndex), context),
          ),
        ),
      );
    }

    return widgets;
  }

  List<InlineSpan> _parseLineSpans(String text, BuildContext context) {
    List<InlineSpan> handleCurlyBraces(String input, TextStyle baseStyle) {
      final List<InlineSpan> spans = [];
      int currentIndex = 0;
      final RegExp pattern = RegExp(
        r'(\{h:(.+?)\})|(\{p:(.+?)\})|(\{r:(.+?)\})',
      );

      for (final match in pattern.allMatches(input)) {
        if (currentIndex < match.start) {
          spans.addAll(
            _buildClickableSpansForSegment(
              input.substring(currentIndex, match.start),
              baseStyle,
              context,
            ),
          );
        }

        if (match.group(1) != null) {
          final text = match.group(2)!;
          spans.addAll(
            _buildClickableSpansForSegment(
              text,
              baseStyle.copyWith(backgroundColor: const Color(0xFFFFF59D)),
              context,
            ),
          );
        } else if (match.group(3) != null) {
          final text = match.group(4)!;
          spans.addAll(
            _buildClickableSpansForSegment(
              text,
              baseStyle.copyWith(backgroundColor: const Color(0xFFFFCDD2)),
              context,
            ),
          );
        } else if (match.group(5) != null) {
          final word = match.group(6)!;

          spans.addAll(
            _buildClickableSpansForSegment(word, baseStyle, context),
          );

          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: () async {
                  await FormattedText.speak(word);
                },
                child: _SpeakingIndicator(word: word),
              ),
            ),
          );
        }

        currentIndex = match.end;
      }

      if (currentIndex < input.length) {
        spans.addAll(
          _buildClickableSpansForSegment(
            input.substring(currentIndex),
            baseStyle,
            context,
          ),
        );
      }

      return spans;
    }

    final RegExp tagExp = RegExp(r'\[(/?)(b|i|color=([a-z]+))\]');
    final RegExp urlExp = RegExp(r'(https?:\/\/[^\s]+)');
    final RegExp linkExp = RegExp(r'\[link=(.+?)\](.+?)\[/link\]');

    final List<InlineSpan> spans = [];
    final List<TextStyle> styleStack = [
      const TextStyle(fontSize: 16, color: Colors.black),
    ];

    int lastProcessedCharIndex = 0;

    void addStyledText(String segment) {
      final matches = linkExp.allMatches(segment);
      int segmentIndex = 0;

      for (final match in matches) {
        if (match.start > segmentIndex) {
          spans.addAll(
            handleCurlyBraces(
              segment.substring(segmentIndex, match.start),
              styleStack.last,
            ),
          );
        }

        final url = match.group(1)!;
        final linkText = match.group(2)!;

        spans.add(
          TextSpan(
            text: linkText,
            style: styleStack.last.merge(
              const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );

        segmentIndex = match.end;
      }

      final rest = segment.substring(segmentIndex);
      final urlMatches = urlExp.allMatches(rest);
      int restIndex = 0;

      for (final urlMatch in urlMatches) {
        if (urlMatch.start > restIndex) {
          spans.addAll(
            handleCurlyBraces(
              rest.substring(restIndex, urlMatch.start),
              styleStack.last,
            ),
          );
        }

        final url = urlMatch.group(0)!;
        spans.add(
          TextSpan(
            text: url,
            style: styleStack.last.merge(
              const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
          ),
        );
        restIndex = urlMatch.end;
      }

      if (restIndex < rest.length) {
        spans.addAll(
          handleCurlyBraces(rest.substring(restIndex), styleStack.last),
        );
      }
    }

    for (final match in tagExp.allMatches(text)) {
      if (match.start > lastProcessedCharIndex) {
        final segment = text.substring(lastProcessedCharIndex, match.start);
        addStyledText(segment);
      }

      final isClosing = match.group(1) == '/';
      final tag = match.group(2);
      final colorName = match.group(3);

      if (!isClosing) {
        final current = styleStack.last;
        if (tag == 'b') {
          styleStack.add(
            current.merge(const TextStyle(fontWeight: FontWeight.bold)),
          );
        } else if (tag == 'i') {
          styleStack.add(
            current.merge(const TextStyle(fontStyle: FontStyle.italic)),
          );
        } else if (tag != null && tag.startsWith('color=')) {
          Color color = Colors.black;
          if (colorName == 'red')
            color = Colors.red;
          else if (colorName == 'green')
            color = Colors.green;
          else if (colorName == 'blue')
            color = Colors.blue;
          else if (colorName == 'orange') color = Colors.orange;
          styleStack.add(current.merge(TextStyle(color: color)));
        }
      } else {
        if (styleStack.length > 1) {
          styleStack.removeLast();
        }
      }

      lastProcessedCharIndex = match.end;
    }

    if (lastProcessedCharIndex < text.length) {
      final segment = text.substring(lastProcessedCharIndex);
      addStyledText(segment);
    }

    return spans;
  }

  List<InlineSpan> _buildClickableSpansForSegment(
    String segment,
    TextStyle baseStyle,
    BuildContext context,
  ) {
    final List<InlineSpan> wordSpans = [];
    final RegExp wordPattern = RegExp(r'\b(\w+)\b|[^\w\s]+|\s+');

    for (final match in wordPattern.allMatches(segment)) {
      final text = match.group(0)!;

      if (RegExp(r'^\w+$').hasMatch(text)) {
        wordSpans.add(
          ClickableTextSpan(text: text, context: context, style: baseStyle),
        );
      } else {
        wordSpans.add(TextSpan(text: text, style: baseStyle));
      }
    }

    return wordSpans;
  }
}

class _SpeakingIndicator extends StatefulWidget {
  final String word;

  const _SpeakingIndicator({required this.word});

  @override
  State<_SpeakingIndicator> createState() => _SpeakingIndicatorState();
}

class _SpeakingIndicatorState extends State<_SpeakingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAnimation(bool active) {
    if (active) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    } else {
      if (_controller.isAnimating) {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: FormattedText.speakingNotifier,
      builder: (context, currentWord, _) {
        final bool active = currentWord == widget.word;

        _updateAnimation(active);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    Icons.volume_up,
                    size: 20,
                    color: active ? Colors.blue : Colors.black54,
                  ),
                ),
                if (active) ...[
                  _WaveBar(value: _wave(0)),
                  _WaveBar(value: _wave(2)),
                  _WaveBar(value: _wave(4)),
                ],
              ],
            );
          },
        );
      },
    );
  }

  double _wave(double shift) {
    return (math.sin((_controller.value * math.pi * 2) + shift) + 1) / 2;
  }
}

class _WaveBar extends StatelessWidget {
  final double value;

  const _WaveBar({required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.5),
      width: 3,
      height: 8 + (10 * value),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
