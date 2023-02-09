import 'package:flight_deck/screens/stays_screen.dart';
import 'package:flight_deck/screens/timeline_screen.dart';
import 'package:flight_deck/widgets/make_stay_widget.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;

  List<String> screenNames = ["STAYS", "TIMELINE", "MAP", "ADD STAY"];
  List<Widget> screen = [
    const StaysScreen(),
    const TimelineScreen(),
    const Center(child: Text("ERROR 404: map not found")),
    const Center(child: Text("ERROR 404: add stay not found")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[selectedScreen],
      bottomNavigationBar: Row(
        children: [
          for (var i = 0; i < screenNames.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (i == screenNames.length - 1) {
                    showDialog(
                      context: context,
                      builder: (context) => const Material(
                        color: Colors.black38,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                          child: MakeStayWidget(),
                        ),
                      ),
                    );
                    return;
                  }
                  selectedScreen = i;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(color: Color(0xFFA60707), width: 2),
                      vertical: BorderSide(color: Color(0xFFA60707), width: 3),
                    ),
                  ),
                  child: Text(
                    screenNames[i],
                    style: TextStyle(fontWeight: selectedScreen == i ? FontWeight.bold : FontWeight.normal),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
