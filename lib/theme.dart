import 'package:flutter/material.dart';

import 'models.dart';

const kPrimary = Color(0xFF2347D9); // royal blue
const kAccent = Color(0xFF12B5A6); // fresh turquoise
const kWarm = Color(0xFFFF8A3D); // warm orange highlight
const kBackground = Color(0xFFF4F6FC);
const kInk = Color(0xFF131A2E);

/// Used on headers and the main call-to-action surfaces.
const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF2347D9), Color(0xFF12A8C4)],
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: kPrimary).copyWith(
    primary: kPrimary,
    secondary: kAccent,
    tertiary: kWarm,
    surface: Colors.white,
    onSurface: kInk,
    primaryContainer: const Color(0xFFE1E8FF),
    onPrimaryContainer: const Color(0xFF0E2A8A),
  );
  final buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );
  const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kBackground,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: kBackground,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: kInk,
        fontSize: 21,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE3E8F4)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 54),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 54),
        shape: buttonShape,
        textStyle: buttonText,
        side: const BorderSide(color: Color(0xFFB9C4E4), width: 1.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDCE2F2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      indicatorColor: scheme.primaryContainer,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? kPrimary : null,
        ),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontSize: 15),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Color(0xFFE3E8F4),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      selectedColor: scheme.primaryContainer,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
  );
}

typedef PillStyle = ({Color fg, Color bg, IconData icon});

/// One look per appointment status, always shown together with its label.
PillStyle statusStyle(ApptStatus s) => switch (s) {
  ApptStatus.pending => (
    fg: const Color(0xFF8A4B00),
    bg: const Color(0xFFFFEDCC),
    icon: Icons.hourglass_top,
  ),
  ApptStatus.confirmed => (
    fg: const Color(0xFF046C4E),
    bg: const Color(0xFFD3F5E6),
    icon: Icons.check_circle,
  ),
  ApptStatus.rejected => (
    fg: const Color(0xFFA51D2D),
    bg: const Color(0xFFFFDDE1),
    icon: Icons.cancel,
  ),
  ApptStatus.cancelled => (
    fg: const Color(0xFF475069),
    bg: const Color(0xFFE4E8F2),
    icon: Icons.block,
  ),
  ApptStatus.completed => (
    fg: const Color(0xFF1B3FB8),
    bg: const Color(0xFFDDE5FF),
    icon: Icons.task_alt,
  ),
};

PillStyle slotStyle(SlotState s) => switch (s) {
  SlotState.available => (
    fg: const Color(0xFF046C4E),
    bg: const Color(0xFFD3F5E6),
    icon: Icons.event_available,
  ),
  SlotState.reserved => (
    fg: const Color(0xFF8A4B00),
    bg: const Color(0xFFFFEDCC),
    icon: Icons.hourglass_top,
  ),
  SlotState.booked => (
    fg: const Color(0xFF1B3FB8),
    bg: const Color(0xFFDDE5FF),
    icon: Icons.lock,
  ),
};

/// A stable, friendly colour for a person's avatar.
Color avatarColor(String name) {
  const palette = [
    Color(0xFF2347D9),
    Color(0xFF12A594),
    Color(0xFFE5484D),
    Color(0xFF8E4EC6),
    Color(0xFFF76808),
    Color(0xFFD6409F),
    Color(0xFF0091FF),
    Color(0xFF30A46C),
  ];
  var hash = 0;
  for (final c in name.codeUnits) {
    hash = (hash * 31 + c) & 0x7fffffff;
  }
  return palette[hash % palette.length];
}
