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

  Widget buildCheckboxChecklistItem(int i) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8, right: 10, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Transform.scale(
              scale: 2,
              child: Checkbox(
                value: _checklist.items[i].isDone,
                onChanged: (val) {
                  if (widget.onChange != null) {
                    final newChecklistItems = _checklist.items;
                    newChecklistItems[i] = newChecklistItems[i].copyWith(value: (val ?? false) ? "1" : "0");

                    _checklist = _checklist.copyWith(items: newChecklistItems);

                    widget.onChange?.call(_checklist);

                    if (mounted) setState(() {});
                  }
                },
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 120,
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
    );
  }

  Widget buildNoteChecklistItem(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(
                label: Text(_checklist.items[i].title),
                labelStyle: const TextStyle(color: Color(0xFFE90808)),
                fillColor: Colors.black26,
                filled: true,
              ),
              initialValue: _checklist.items[i].value,
              onChanged: (value) {
                if (widget.onChange != null) {
                  final newChecklistItems = _checklist.items;
                  newChecklistItems[i] = newChecklistItems[i].copyWith(value: value);

                  _checklist = _checklist.copyWith(items: newChecklistItems);

                  widget.onChange!(_checklist);

                  if (mounted) setState(() {});
                }
              },
            ),
            Text(
              _checklist.items[i].description,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget buildCalculatedChecklistItem(int i) {
    if (_checklist.items[i].value != (_checklist.items[i].operation?.runCalculation(_checklist) ?? "")) {
      final newChecklistItems = _checklist.items;
      newChecklistItems[i] =
          newChecklistItems[i].copyWith(value: _checklist.items[i].operation?.runCalculation(_checklist) ?? "");

      _checklist = _checklist.copyWith(items: newChecklistItems);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                label: Text(_checklist.items[i].title),
                labelStyle: const TextStyle(color: Color(0xFFE90808)),
                fillColor: Colors.black26,
                filled: true,
              ),
              readOnly: true,
              controller: TextEditingController(text: _checklist.items[i].value),
            ),
            Text(
              _checklist.items[i].description,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

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
                height: MediaQuery.of(context).size.height - 140,
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
                          switch (_checklist.items[i].type) {
                            ChecklistItemType.note => buildNoteChecklistItem(i),
                            ChecklistItemType.task => buildCheckboxChecklistItem(i),
                            ChecklistItemType.calculated => buildCalculatedChecklistItem(i),
                          },
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            DeckButton(
                              onTap: () {
                                _checklist = _checklist.asReset();
                                widget.onChange?.call(_checklist);

                                Navigator.of(context).pop();
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
