import 'package:flutter/material.dart';

/// Дизайн-система «Варшавский Модерн».
/// Благородная польская карминовая палитра, чистый белый цвет поверхностей
/// и спокойный фон цвета теплого молока / слоновой кости.
class AppTheme {
  AppTheme._();

  // Основная благородная палитра
  static const Color primaryCarmine = Color(0xFFB81428); // Глубокий кармин
  static const Color primaryPastel = Color(0xFFFBEBED);  // Нежный пастельный кармин
  static const Color bgWarmMilk = Color(0xFFF8F9FA);     // Теплое молоко / слоновая кость
  static const Color surfaceWhite = Color(0xFFFFFFFF);   // Чистый белый
  static const Color textGraphite = Color(0xFF1E1E24);   // Премиальный графит
  static const Color textSecondary = Color(0xFF6C757D);  // Вторичный серый
  static const Color borderSubtle = Color(0xFFE9ECEF);   // Деликатная граница

  // Мягкая микро-тень для карточек и диалогов
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x0A000000), // Colors.black.withOpacity(0.04)
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primaryCarmine,
      onPrimary: Colors.white,
      primaryContainer: primaryPastel,
      onPrimaryContainer: primaryCarmine,
      secondary: Color(0xFF8C1D2F),
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFF5E6E8),
      onSecondaryContainer: Color(0xFF5A121E),
      tertiary: Color(0xFF6E5659),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF8EDEE),
      onTertiaryContainer: Color(0xFF271518),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: surfaceWhite,
      onSurface: textGraphite,
      onSurfaceVariant: textSecondary,
      outline: borderSubtle,
      outlineVariant: Color(0xFFDEE2E6),
      surfaceContainerLowest: surfaceWhite,
      surfaceContainerLow: Color(0xFFF8F9FA),
      surfaceContainer: surfaceWhite,
      surfaceContainerHigh: Color(0xFFF1F3F5),
      surfaceContainerHighest: Color(0xFFE9ECEF),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bgWarmMilk,
      canvasColor: bgWarmMilk,
      
      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: bgWarmMilk,
        foregroundColor: textGraphite,
        elevation: 0,
        scrolledUnderElevation: 1.5,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textGraphite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: textGraphite),
      ),

      // Card
      cardTheme: CardThemeData(
        color: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: textGraphite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: textGraphite,
          fontSize: 14,
          height: 1.4,
        ),
      ),

      // BottomSheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // NavigationBar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        height: 68,
        indicatorColor: primaryPastel,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryCarmine, size: 24);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: primaryCarmine,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          );
        }),
      ),

      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryCarmine,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCarmine,
          side: const BorderSide(color: primaryCarmine, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryCarmine,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCarmine, width: 1.8),
        ),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textGraphite, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: textGraphite, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: textGraphite, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textGraphite, height: 1.4),
        bodyMedium: TextStyle(color: textGraphite, height: 1.4),
        bodySmall: TextStyle(color: textSecondary, height: 1.3),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryCarmine,
        linearTrackColor: primaryPastel,
        circularTrackColor: primaryPastel,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
