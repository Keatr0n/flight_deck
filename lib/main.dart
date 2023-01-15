import 'package:flight_deck/screens/timeline_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FlightDeckApp());
}

class FlightDeckApp extends StatelessWidget {
  const FlightDeckApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Deck',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFFDF2727),
        fontFamily: "FiraCode",
      ),
      home: const Scaffold(body: TimelineScreen()),
    );
  }
}
