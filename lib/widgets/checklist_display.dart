import 'package:flight_deck/models/checklist.dart';
import 'package:flight_deck/widgets/deck_button.dart';
import 'package:flight_deck/widgets/deck_window.dart';
import 'package:flutter/material.dart';

class CheckListDisplay extends StatefulWidget {
  const CheckListDisplay({super.key, required this.checklist, this.onChange});

  final Checklist checklist;
  final void Function(Checklist)? onChange;

  @override
  State<CheckListDisplay> createState() => _CheckListDisplayState();
}

class _CheckListDisplayState extends State<CheckListDisplay> {
  late Checklist _checklist = widget.checklist;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: SafeArea(
        child: DeckWindow(
          onClose: () => Navigator.of(context).pop(),
          tabs: [
            DeckWindowTab(
              title: _checklist.title,
              child: SizedBox(
                height: MediaQuery.of(context).size.height - 130,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Text(_checklist.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 10),
                        for (var i = 0; i < _checklist.items.length; i++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Checkbox(
                                    value: _checklist.items[i].isDone,
                                    onChanged: (val) {
                                      if (widget.onChange != null) {
                                        final newChecklistItems = _checklist.items;
                                        newChecklistItems[i] = newChecklistItems[i].copyWith(isDone: val);

                                        _checklist = _checklist.copyWith(items: newChecklistItems);

                                        widget.onChange?.call(_checklist);

                                        if (mounted) setState(() {});
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width - 100,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_checklist.items[i].title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 5),
                                      Text(
                                        _checklist.items[i].description,
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DeckButton(
                              onTap: () {
                                _checklist = _checklist.asReset();
                                widget.onChange?.call(_checklist);

                                if (mounted) setState(() {});
                              },
                              child: const Text("RESET"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
