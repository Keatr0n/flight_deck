import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/screens/home_screen.dart';
import 'package:flight_deck/utils/theme_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlightDeckDB.instance.init();

  // FOR TESTING ONLY, THIS WILL NUKE YOUR DB
  // FlightDeckDB.instance.wipeDB();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Deck',
      scrollBehavior: DeckScrollBehavior(),
      theme: ThemeUtils.getTheme(FlightDeckDB.instance.userSettings.theme),
      home: const Scaffold(body: HomeScreen()),
    );
  }
}
