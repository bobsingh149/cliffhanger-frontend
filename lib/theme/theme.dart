import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Define your custom colors
  static const Color primaryColor = Color.fromARGB(255, 56, 118, 45); // Deep green
  static const Color secondaryColor = Color(0xFFFFC107); // Amber
  static const Color backgroundColorLight = Color(0xFFF3F4F6); // Light background
  static const Color backgroundColorDark = Color(0xFF1C1C1E); // Dark background
  static const Color cardColorLight = Colors.white; // Light card color
  static const Color cardColorDark = Color(0xFF2C2C2E); // Dark card color
  static const Color textColorLight = Color(0xFF212121); // Dark text for light theme
  static const Color textColorDark = Colors.white; // Light text for dark theme
  static const Color shadowColor = Colors.black26; // Shadow color

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
      useMaterial3: true,

    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.light),
    scaffoldBackgroundColor: backgroundColorLight,
    cardColor: cardColorLight,
    textTheme: _textThemeLight,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      buttonColor: primaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColorLight,
      shadowColor: shadowColor,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    iconTheme: IconThemeData(color: primaryColor),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
                  useMaterial3: true,

    colorScheme:ColorScheme.fromSeed(seedColor: primaryColor, brightness: Brightness.dark),
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundColorDark,
    cardColor: cardColorDark,
    textTheme: _textThemeDark,
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 2,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    buttonTheme: ButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      buttonColor: primaryColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
  
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: cardColorDark,
      shadowColor: shadowColor,
      elevation: 4,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[800],
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),
    iconTheme: IconThemeData(color: primaryColor),
  );

  // Text theme for light mode
  static  TextTheme _textThemeLight = TextTheme(
    displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: textColorLight),
    displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: textColorLight),
    bodyLarge: TextStyle(fontSize: 16.sp, color: textColorLight),
    bodyMedium: TextStyle(fontSize: 14.sp, color: textColorLight),
    bodySmall: TextStyle(fontSize: 12.sp, color: Colors.grey),
  );

  // Text theme for dark mode
   static  TextTheme _textThemeDark = TextTheme(
    displayLarge: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: textColorDark),
    displayMedium: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: textColorDark),
    bodyLarge: TextStyle(fontSize: 16.sp, color: textColorDark),
    bodyMedium: TextStyle(fontSize: 14.sp, color: textColorDark),
    bodySmall: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
  );
}
