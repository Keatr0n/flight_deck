import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/screens/home_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlightDeckDB.instance.init();

  runApp(const FlightDeckApp());
}

class DeckScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class FlightDeckApp extends StatelessWidget {
  const FlightDeckApp({super.key});

  MaterialColor createMaterialColor(Color color) {
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

  final defaultTextStyle = const TextStyle(fontWeight: FontWeight.w400, fontSize: 14, color: Color(0xFFEF2727));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Deck',
      scrollBehavior: DeckScrollBehavior(),
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFFDF2727)),
        primaryColor: const Color(0xFFDF2727),
        colorScheme: const ColorScheme.dark(background: Color(0xFF171717), primary: Color(0xFFDF2727)),
        scaffoldBackgroundColor: const Color(0xFF171717),
        fontFamily: "FiraCode",
        useMaterial3: true,
        textTheme: TextTheme(
          bodyLarge: defaultTextStyle,
          bodyMedium: defaultTextStyle,
          bodySmall: defaultTextStyle,
        ),
      ),
      home: const Scaffold(body: HomeScreen()),
    );
  }
}
