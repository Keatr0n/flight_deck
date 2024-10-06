import 'dart:async';

import 'package:flight_deck/models/checklist.dart';
import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/widgets/checklist_display.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flight_deck/widgets/make_checklist_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<Checklist> get checklists => FlightDeckDB.instance.checklists;
  late List<Checklist> filteredChecklists = checklists;

  List<Checklist> filterChecklists(String search) {
    if (search.isEmpty) return checklists;
    return checklists
        .where(
          (element) => element.title.toLowerCase().contains(search.toLowerCase()) || element.tags.any((e) => e.toLowerCase().contains(search.toLowerCase())),
        )
        .toList();
  }

  late final StreamSubscription updateDbStream;

  @override
  void dispose() {
    updateDbStream.cancel();
    super.dispose();
  }

  @override
  void initState() {
    updateDbStream = FlightDeckDB.instance.updateDbStream.listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DeckWindow(
          hasWindowBar: false,
          backgroundOpacity: 0.1,
          tabs: [
            DeckWindowTab(
              title: "CHECKLISTS",
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 50,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        label: Text("SEARCH"),
                        labelStyle: TextStyle(color: Color(0xFFE90808)),
                        fillColor: Colors.black26,
                        filled: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredChecklists = filterChecklists(value);
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 195,
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        itemCount: filteredChecklists.length,
                        itemBuilder: (context, i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: DeckButton(
                              key: Key("$i:${filteredChecklists[i].title}"),
                              onLongPress: () async {
                                HapticFeedback.mediumImpact();

                                await showDialog(
                                  context: context,
                                  builder: (context) => Material(
                                    color: Colors.black38,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                                      child: MakeChecklistWidget(
                                        checklist: filteredChecklists[i],
                                        onComplete: (el) {
                                          FlightDeckDB.instance.updateChecklist(filteredChecklists.indexOf(filteredChecklists[i]), el);
                                        },
                                      ),
                                    ),
                                  ),
                                );

                                if (mounted) {
                                  setState(() {});
                                }
                              },
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Material(
                                    color: Colors.black38,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                                      child: CheckListDisplay(
                                        checklist: filteredChecklists[i],
                                        onChange: (el) {
                                          FlightDeckDB.instance.updateChecklist(filteredChecklists.indexOf(filteredChecklists[i]), el);
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(filteredChecklists[i].title),
                            ),
                          );
                        },
                      ),
                    ),
                    DeckButton(
                      onTap: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => Material(
                            color: Colors.black38,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                              child: MakeChecklistWidget(onComplete: (el) {
                                FlightDeckDB.instance.addChecklist(el);
                              }),
                            ),
                          ),
                        );
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      child: const Text("ADD NEW"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
