import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n.dart';
import 'screens/shared/launch_screen.dart';
import 'theme.dart';

void main() {
  runApp(const MyDoctorApp());
}

class MyDoctorApp extends StatefulWidget {
  const MyDoctorApp({super.key});

  @override
  State<MyDoctorApp> createState() => _MyDoctorAppState();
}

class _MyDoctorAppState extends State<MyDoctorApp> {
  @override
  void initState() {
    super.initState();
    appLang.addListener(_languageChanged);
  }

  @override
  void dispose() {
    appLang.removeListener(_languageChanged);
    super.dispose();
  }

  /// Text is looked up with `t()` while building, so a language change has
  /// to rebuild every widget on every open screen, not just this one.
  void _languageChanged() {
    setState(() {});
    void rebuild(Element e) {
      e.markNeedsBuild();
      e.visitChildren(rebuild);
    }

    WidgetsBinding.instance.rootElement?.visitChildren(rebuild);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDoctor',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      // Also switches Flutter's own texts (date picker, tooltips).
      locale: Locale(isSi ? 'si' : 'en'),
      supportedLocales: const [Locale('en'), Locale('si')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const LaunchScreen(),
    );
  }
}
