import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DictionaryResult {
  final String baseForm;
  final List<String> meanings;

  DictionaryResult(this.baseForm, this.meanings);
}

class DictionaryService {
  static Map<String, List<String>> _dictionary = {};
  static Map<String, String> _irregularForms = {};

  /// Bir marta (main.dart ichida) chaqiriladi
  static Future<void> initialize() async {
    final dictString = await rootBundle.loadString('assets/dictionary.json');
    final irregularString =
        await rootBundle.loadString('assets/irregular_forms.json');

    final dictJson = json.decode(dictString) as Map<String, dynamic>;
    final irregularJson = json.decode(irregularString) as Map<String, dynamic>;

    _dictionary =
        dictJson.map((k, v) => MapEntry(k.toLowerCase(), List<String>.from(v)));
    _irregularForms =
        irregularJson.map((k, v) => MapEntry(k.toLowerCase(), v.toString()));
  }

  /// Lookup (asosiy funksiya)
  static DictionaryResult? lookupWord(String word) {
    final lowerWord = word.toLowerCase();
    final base = getBaseWord(lowerWord);

    if (_dictionary.containsKey(base)) {
      return DictionaryResult("{r:$base}", _dictionary[base]!);
    }
    return null;
  }

  /// Base formni aniqlash (irregular + suffix normalizatsiya)
  static String getBaseWord(String word) {
    final lower = word.toLowerCase();

    // ✅ 1. If exact word exists — no need to modify
    if (_dictionary.containsKey(lower)) {
      return lower;
    }

    // ✅ 2. Check irregular forms
    if (_irregularForms.containsKey(lower)) {
      return _irregularForms[lower]!;
    }

    String stem;

    // ✅ 3. Possessives
    if (lower.endsWith("'s")) {
      stem = lower.substring(0, lower.length - 2);
      if (_dictionary.containsKey(stem)) return stem;
    }
    if (lower.endsWith("s'")) {
      stem = lower.substring(0, lower.length - 2);
      if (_dictionary.containsKey(stem)) return stem;
    }

    // ✅ 4. Continuous (-ing) with two-step logic
    if (lower.endsWith("ing") && lower.length > 4) {
      String stem1 = lower.substring(0, lower.length - 3); // remove -ing
      String stem2 = stem1;

      // Double consonant fix (running → run)
      if (stem2.length > 1 &&
          stem2[stem2.length - 1] == stem2[stem2.length - 2]) {
        stem2 = stem2.substring(0, stem2.length - 1);
      }

      // Step 1: Try without change
      if (_dictionary.containsKey(stem1)) return stem1;
      if (_dictionary.containsKey("${stem1}e")) return "${stem1}e";

      // Step 2: Try double consonant trimmed version
      if (_dictionary.containsKey(stem2)) return stem2;
      if (_dictionary.containsKey("${stem2}e")) return "${stem2}e";

      // Shin + ing → shine
      if (stem1.endsWith("in") && _dictionary.containsKey("${stem1}e")) {
        return "${stem1}e";
      }

      return stem1;
    }

    // ✅ 5. Past tense (-ed) with two-step logic
    if (lower.endsWith("ed") && lower.length > 3) {
      String stem1 = lower.substring(0, lower.length - 2); // remove -ed
      String stem2 = stem1;

      // Convert -ied → -y
      if (stem1.endsWith("i")) {
        stem1 = "${stem1.substring(0, stem1.length - 1)}y";
        stem2 = stem1;
      }

      // Step 1: Try normal
      if (_dictionary.containsKey(stem1)) return stem1;
      if (_dictionary.containsKey("${stem1}e")) return "${stem1}e";

      // Step 2: Try double consonant removal (stopped → stop)
      if (stem2.length > 1 &&
          stem2[stem2.length - 1] == stem2[stem2.length - 2]) {
        stem2 = stem2.substring(0, stem2.length - 1);
        if (_dictionary.containsKey(stem2)) return stem2;
        if (_dictionary.containsKey("${stem2}e")) return "${stem2}e";
      }

      return stem1;
    }

    // ✅ 6. Third person singular (-es)
    if (lower.endsWith("es") && lower.length > 3) {
      stem = lower.substring(0, lower.length - 2);
      if (_dictionary.containsKey(stem)) return stem;
      if (_dictionary.containsKey("${stem}e")) return "${stem}e";
      return stem;
    }

    // ✅ 7. Plurals / singular (-s)
    if (lower.endsWith("s") && lower.length > 2) {
      stem = lower.substring(0, lower.length - 1);
      if (_dictionary.containsKey(stem)) return stem;
      return stem;
    }

    // ✅ 8. Comparatives (-er)
    if (lower.endsWith("er") && lower.length > 3) {
      stem = lower.substring(0, lower.length - 2);
      if (stem.endsWith("i")) stem = "${stem.substring(0, stem.length - 1)}y";
      if (stem.endsWith("g")) stem = "${stem}e";
      if (_dictionary.containsKey(stem)) return stem;
      if (_dictionary.containsKey("${stem}e")) return "${stem}e";
    }

    // ✅ 9. Superlatives (-est)
    if (lower.endsWith("est") && lower.length > 4) {
      stem = lower.substring(0, lower.length - 3);
      if (stem.endsWith("i")) stem = "${stem.substring(0, stem.length - 1)}y";
      if (stem.endsWith("g")) stem = "${stem}e";
      if (_dictionary.containsKey(stem)) return stem;
      if (_dictionary.containsKey("${stem}e")) return "${stem}e";
    }

    // ✅ 10. Default fallback
    return lower;
  }
}
