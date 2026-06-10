import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// =================== PASTEL PALETTE ===================
// Coral #FF6B6B · Peach #FFA07A · Mint #4ECDC4 · Sky #45B7D1
// Background: #FFF5F5 (rose white) · Surface: #FFFFFF
// ======================================================
class AppColors {
  // Brand - Coral/Teal pastel nổi bật
  static const Color primary          = Color(0xFFFF6B6B); // Coral
  static const Color primaryContainer = Color(0xFFFFE4E4); // Coral nhạt
  static const Color onPrimary        = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF7A0000);

  static const Color secondary          = Color(0xFF4ECDC4); // Mint teal
  static const Color secondaryContainer = Color(0xFFD4F5F3); // Mint nhạt
  static const Color onSecondary        = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF003D3A);

  static const Color tertiary           = Color(0xFFFFB347); // Peach/amber
  static const Color tertiaryContainer  = Color(0xFFFFEDD4);
  static const Color onTertiary         = Color(0xFFFFFFFF);

  // Semantic
  static const Color success          = Color(0xFF2ECC71); // Emerald
  static const Color successContainer = Color(0xFFD4F5E0);
  static const Color warning          = Color(0xFFFFB347);
  static const Color warningContainer = Color(0xFFFFEDD4);
  static const Color danger           = Color(0xFFFF6B6B);
  static const Color dangerContainer  = Color(0xFFFFE4E4);
  static const Color info             = Color(0xFF45B7D1); // Sky blue
  static const Color infoContainer    = Color(0xFFD4EFFA);
  static const Color error            = Color(0xFFE53935);
  static const Color errorContainer   = Color(0xFFFFCDD2);
  static const Color onError          = Color(0xFFFFFFFF);

  // Compatibility aliases
  static const Color primaryDark  = Color(0xFFE55555);
  static const Color primaryLight = Color(0xFFFFE4E4);

  // Context-aware surfaces
  static Color background(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surfaceVariant(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;
  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2020)
          : const Color(0xFFFFF0F0);
  static Color surfaceContainerHigh(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF332828)
          : const Color(0xFFFFE8E8);

  // Text
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color textTertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9E8585)
          : const Color(0xFFB08080);

  // Border
  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
  static Color outline(BuildContext context) =>
      Theme.of(context).colorScheme.outline;
}

// =================== THEME ===================
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.light(
      primary:              Color(0xFFFF6B6B),
      onPrimary:            Color(0xFFFFFFFF),
      primaryContainer:     Color(0xFFFFE4E4),
      onPrimaryContainer:   Color(0xFF7A0000),
      secondary:            Color(0xFF4ECDC4),
      onSecondary:          Color(0xFFFFFFFF),
      secondaryContainer:   Color(0xFFD4F5F3),
      onSecondaryContainer: Color(0xFF003D3A),
      tertiary:             Color(0xFFFFB347),
      onTertiary:           Color(0xFFFFFFFF),
      tertiaryContainer:    Color(0xFFFFEDD4),
      onTertiaryContainer:  Color(0xFF4A2800),
      error:                Color(0xFFE53935),
      onError:              Color(0xFFFFFFFF),
      errorContainer:       Color(0xFFFFCDD2),
      onErrorContainer:     Color(0xFF7A0000),
      surface:              Color(0xFFFFFFFF),
      onSurface:            Color(0xFF2D1515),
      surfaceContainerHighest: Color(0xFFFFEEEE),
      onSurfaceVariant:     Color(0xFF7A5C5C),
      outline:              Color(0xFFBFA0A0),
      outlineVariant:       Color(0xFFEDD8D8),
    ),

    scaffoldBackgroundColor: const Color(0xFFFFF5F5),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF5F5),
      foregroundColor: Color(0xFF2D1515),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D1515),
        letterSpacing: -0.3,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFFEDD8D8), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Color(0xFFFF6B6B),
        foregroundColor: Color(0xFFFFFFFF),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF6B6B),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),

    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFFFEEEE),
      selectedColor: const Color(0xFFFFD4D4),
      labelStyle: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF7A0000)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      side: BorderSide.none,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFF5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEDD8D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEDD8D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFFBFA0A0)),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFFFFF),
      indicatorColor: const Color(0xFFFFE4E4),
      elevation: 4,
      shadowColor: const Color(0xFFFF6B6B),
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF6B6B));
        }
        return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A5C5C));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFFFF6B6B), size: 24);
        }
        return const IconThemeData(color: Color(0xFF7A5C5C), size: 22);
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? const Color(0xFFFF6B6B)
              : Colors.white),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? const Color(0xFFFFD4D4)
              : const Color(0xFFEDD8D8)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFFF6B6B),
      linearTrackColor: Color(0xFFFFEEEE),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFFEDD8D8),
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2D1515),
      contentTextStyle:
          const TextStyle(color: Colors.white, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      shadowColor: const Color(0xFFFF6B6B).withValues(alpha: 0.15),
    ),
  );

  // --- DARK ---
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',

    colorScheme: const ColorScheme.dark(
      primary:              Color(0xFFFF8E8E),
      onPrimary:            Color(0xFF5C0000),
      primaryContainer:     Color(0xFF8A2020),
      onPrimaryContainer:   Color(0xFFFFD4D4),
      secondary:            Color(0xFF72E8E0),
      onSecondary:          Color(0xFF003330),
      secondaryContainer:   Color(0xFF1A5550),
      onSecondaryContainer: Color(0xFFD4F5F3),
      tertiary:             Color(0xFFFFCC80),
      onTertiary:           Color(0xFF4A2800),
      tertiaryContainer:    Color(0xFF6A3C00),
      onTertiaryContainer:  Color(0xFFFFEDD4),
      error:                Color(0xFFFF8A80),
      onError:              Color(0xFF5C0000),
      errorContainer:       Color(0xFF8A2020),
      onErrorContainer:     Color(0xFFFFD4D4),
      surface:              Color(0xFF1A0F0F),
      onSurface:            Color(0xFFF5EAEA),
      surfaceContainerHighest: Color(0xFF2A1818),
      onSurfaceVariant:     Color(0xFFCCAFAF),
      outline:              Color(0xFF8A6060),
      outlineVariant:       Color(0xFF4A2828),
    ),

    scaffoldBackgroundColor: const Color(0xFF1A0F0F),

    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1A0F0F),
      foregroundColor: Color(0xFFF5EAEA),
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: Color(0xFFF5EAEA),
        letterSpacing: -0.3,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFF261414),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: Color(0xFF4A2828), width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF6B6B),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF261414),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A2828)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF4A2828)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color(0xFFFF8E8E), width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF8A6060)),
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF261414),
      indicatorColor: const Color(0xFF8A2020),
      elevation: 4,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF8E8E));
        }
        return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFFCCAFAF));
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFFFF8E8E), size: 24);
        }
        return const IconThemeData(color: Color(0xFFCCAFAF), size: 22);
      }),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? const Color(0xFFFF8E8E)
              : const Color(0xFF8A6060)),
      trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected)
              ? const Color(0xFF8A2020)
              : const Color(0xFF4A2828)),
    ),

    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFFF8E8E),
      linearTrackColor: Color(0xFF4A2828),
    ),

    dividerTheme: const DividerThemeData(
      color: Color(0xFF4A2828),
      thickness: 1,
      space: 1,
    ),

    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF261414),
      contentTextStyle:
          const TextStyle(color: Color(0xFFF5EAEA), fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF261414),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24)),
      elevation: 8,
    ),
  );
}

// =================== DATE UTILS ===================
class AppDateUtils {
  static String formatFriendly(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = dateOnly.difference(today).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == 1) return 'Ngày mai';
    if (difference == -1) return 'Hôm qua';
    if (difference > 1 && difference < 7) return 'Sau $difference ngày';
    if (difference < -1 && difference > -7)
      return 'Quá hạn ${-difference} ngày';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatFull(DateTime date) =>
      DateFormat('dd/MM/yyyy HH:mm').format(date);
  static String formatTime(DateTime date) => DateFormat('HH:mm').format(date);
  static String formatFriendlyWithTime(DateTime date) =>
      '${formatFriendly(date)}, ${formatTime(date)}';
  static String formatDayMonth(DateTime date) =>
      DateFormat('dd/MM').format(date);
  static String formatDayMonthYear(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);
  static String formatWeekday(DateTime date) =>
      DateFormat('EEEE', 'vi_VN').format(date);
}
