import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/screens/checklist_screen.dart';
import 'package:flight_deck/screens/map_screen.dart';
import 'package:flight_deck/screens/stays_screen.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedScreen = 0;

  List<String> screenNames = ["STAYS", "MAP", "CHECKLISTS"];
  List<Widget> screen = [
    const StaysScreen(),
    const MapScreen(),
    const ChecklistScreen(),
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
                onLongPress: () {
                  HapticFeedback.lightImpact();
                  showDialog(
                    context: context,
                    builder: (context) => Material(
                      color: Colors.black38,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                        child: DeckWindow.single(
                          title: "DATA RECOVERY",
                          child: Column(
                            children: [
                              const SizedBox(height: 10),
                              const Text("Import or export your data?"),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  DeckButton(
                                    child: const Text("IMPORT"),
                                    onTap: () {
                                      FlightDeckDB.instance.import().then((err) {
                                        if (err != null) {
                                          showDialog(
                                            // it's fine, don't worry about it
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            builder: (context) => Material(
                                              color: Colors.black38,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                                                child: DeckWindow.single(
                                                  title: "IMPORT ERROR",
                                                  child: Text(err),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      });
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  DeckButton(
                                    child: const Text("EXPORT"),
                                    onTap: () {
                                      FlightDeckDB.instance.export();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                onTap: () {
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
