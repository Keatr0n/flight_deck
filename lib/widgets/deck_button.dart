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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFA60707), width: borderWidth),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: child,
      ),
    );
  }
}
