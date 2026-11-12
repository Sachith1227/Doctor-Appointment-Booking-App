import 'package:flutter/foundation.dart';

import 'l10n_si.dart';

enum AppLang { en, si }

/// The app language. Changing it rebuilds the whole app (see main.dart).
final appLang = ValueNotifier<AppLang>(AppLang.en);

bool get isSi => appLang.value == AppLang.si;

/// Translates UI text. The English text is the key; `{0}`, `{1}` … are
/// replaced with [args]. Text without a Sinhala entry stays in English.
String t(String en, [List<Object?> args = const []]) {
  var text = isSi ? (sinhala[en] ?? en) : en;
  for (var i = 0; i < args.length; i++) {
    text = text.replaceAll('{$i}', '${args[i]}');
  }
  return text;
}

/// Picks between an English value and its optional Sinhala version.
String pick(String en, String? si) =>
    isSi && si != null && si.isNotEmpty ? si : en;
