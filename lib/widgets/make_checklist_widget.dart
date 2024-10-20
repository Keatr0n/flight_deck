import 'package:flight_deck/models/checklist.dart';
import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flutter/material.dart';

class MakeChecklistWidget extends StatefulWidget {
  const MakeChecklistWidget({super.key, this.checklist, required this.onComplete});

  final Checklist? checklist;
  final void Function(Checklist) onComplete;

  @override
  State<MakeChecklistWidget> createState() => _MakeChecklistWidgetState();
}

class _MakeChecklistWidgetState extends State<MakeChecklistWidget> {
  List<(TextEditingController, TextEditingController)> items = [];
  TextEditingController titleController = TextEditingController();
  TextEditingController currentTagController = TextEditingController();
  List<String> tags = [];

  @override
  void initState() {
    if (widget.checklist != null) {
      for (var i = 0; i < widget.checklist!.items.length; i++) {
        final item = widget.checklist!.items[i];
        items.add((TextEditingController()..text = item.title, TextEditingController()..text = item.description));
      }

      titleController.text = widget.checklist!.title;
      tags = widget.checklist!.tags;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DeckWindow(
      onClose: () => Navigator.of(context).pop(),
      tabs: [
        DeckWindowTab(
          title: titleController.text,
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 135,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(label: Text("TITLE"), labelStyle: TextStyle(color: Color(0xFFE90808)), fillColor: Colors.black26, filled: true),
                    onChanged: (value) {
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: [
                      const SizedBox(height: 45),
                      for (var i = 0; i < tags.length; i++)
                        GestureDetector(
                          onLongPress: () {
                            tags.removeAt(i);

                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFFA60707), width: 2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(tags[i]),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: currentTagController,
                    decoration: const InputDecoration(label: Text("TAGS"), labelStyle: TextStyle(color: Color(0xFFE90808)), fillColor: Colors.black26, filled: true),
                    onSubmitted: (value) {
                      if (!tags.contains(value.substring(0, value.length))) tags.add(value.substring(0, value.length));
                      setState(() {
                        currentTagController.text = "";
                      });
                    },
                    onChanged: (value) {
                      if (value.endsWith(",") || value.endsWith(" ") || value.endsWith(";") || value.endsWith(".") || value.endsWith("\n")) {
                        if (!tags.contains(value.substring(0, value.length - 1))) tags.add(value.substring(0, value.length - 1));
                        setState(() {
                          currentTagController.text = "";
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < items.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Checkbox(
                            value: items[i].$1.text.isNotEmpty && items[i].$2.text.isNotEmpty,
                            onChanged: null,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 100,
                            child: Column(
                              children: [
                                TextField(
                                  controller: items[i].$1,
                                  decoration: InputDecoration(label: Text("TASK $i TITLE"), labelStyle: const TextStyle(color: Color(0xFFE90808)), fillColor: Colors.black26, filled: true),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: items[i].$2,
                                  decoration: InputDecoration(label: Text("TASK $i DESCRIPTION"), labelStyle: const TextStyle(color: Color(0xFFE90808)), fillColor: Colors.black26, filled: true),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),
                  DeckButton(
                    onTap: () {
                      setState(() {
                        items.add((TextEditingController(), TextEditingController()));
                      });
                    },
                    child: const Text("NEW ITEM"),
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      DeckButton(
                        onTap: () async {
                          final shouldDelete = await showDialog(
                            context: context,
                            builder: (context) => Material(
                              color: Colors.black38,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                                child: DeckWindow.single(
                                  title: "DELETE CHECKLIST",
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      const Text("Are you sure you want to delete this checklist?\nThis action cannot be undone."),
                                      const SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          DeckButton(child: const Text("CANCEL"), onTap: () => Navigator.of(context).pop(false)),
                                          const SizedBox(width: 10),
                                          DeckButton(child: const Text("DELETE"), onTap: () => Navigator.of(context).pop(true)),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                          if (shouldDelete ?? false) {
                            if (widget.checklist != null) FlightDeckDB.instance.deleteChecklist(widget.checklist!);

                            if (context.mounted) Navigator.of(context).pop();
                          }
                        },
                        child: const Text("DELETE"),
                      ),
                      const SizedBox(width: 10),
                      DeckButton(
                        onTap: () {
                          items.removeWhere((element) => element.$1.text.isEmpty && element.$2.text.isEmpty);

                          widget.onComplete(Checklist(title: titleController.text, items: items.map((e) => ChecklistItem(title: e.$1.text, description: e.$2.text, isDone: false)).toList(), tags: tags));
                          Navigator.of(context).pop();
                        },
                        child: const Text("SAVE"),
                      ),
                      const SizedBox(width: 5),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
