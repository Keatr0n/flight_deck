import 'package:flight_deck/models/flight_deck_db.dart';
import 'package:flight_deck/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class DeckButton extends StatelessWidget {
  const DeckButton({
    super.key,
    this.onTap,
    this.child,
    this.width,
    this.height,
    this.borderWidth = 1,
  });

  final void Function()? onTap;
  final Widget? child;
  final double? width;
  final double? height;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    if (FlightDeckDB.instance.userSettings.theme == FlightDeckTheme.modern) {
      return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(onPressed: onTap, child: child),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor, width: borderWidth),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: child,
      ),
    );
  }
}
