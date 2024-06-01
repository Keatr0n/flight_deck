import 'package:flutter/material.dart';

enum FlightDeckTheme {
  original,
  modern;

  String toDbCompatibleString() {
    switch (this) {
      case original:
        return "original";

      case modern:
        return "modern";
    }
  }

  static FlightDeckTheme fromDbCompatibleString(String string) {
    switch (string) {
      case "original":
        return original;

      case "modern":
        return modern;

      default:
        return original;
    }
  }
}

class ThemeUtils {
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  static ThemeData getTheme(FlightDeckTheme theme) {
    const originalTextStyle = TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFFEF2727));

    switch (theme) {
      case FlightDeckTheme.original:
        return ThemeData(
          primarySwatch: createMaterialColor(const Color(0xFFDF2727)),
          primaryColor: const Color(0xFFDF2727),
          colorScheme: const ColorScheme.dark(surface: Color(0xFF171717), primary: Color(0xFFDF2727)),
          scaffoldBackgroundColor: const Color(0xFF171717),
          fontFamily: "FiraCode",
          useMaterial3: true,
          textTheme: const TextTheme(
            bodyLarge: originalTextStyle,
            bodyMedium: originalTextStyle,
            bodySmall: originalTextStyle,
          ),
        );
      case FlightDeckTheme.modern:
        return ThemeData(
          primarySwatch: createMaterialColor(const Color(0xFF521010)),
          primaryColor: const Color(0xFF521010),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF621717),
            onPrimary: Colors.white,
            primaryContainer: Color(0xFFA74646),
            onPrimaryContainer: Color(0xFF451010),
          ),
          scaffoldBackgroundColor: const Color(0xFF171717),
          fontFamily: "roboto",
          useMaterial3: true,
        );
    }
  }
}
