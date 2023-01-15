import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeckWindow extends StatefulWidget {
  const DeckWindow({super.key, this.onClose, this.child, this.onMove, this.title, this.hasWindowBar = true});

  final Widget? child;
  final String? title;
  final void Function()? onClose;
  final void Function(double x, double y)? onMove;
  final bool hasWindowBar;

  @override
  State<DeckWindow> createState() => _DeckWindowState();
}

class _DeckWindowState extends State<DeckWindow> {
  bool isMinimized = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasWindowBar) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0x7FA60707), width: 2),
          gradient: const LinearGradient(
            colors: [Color(0x7FA60707), Color(0x7F500404), Color(0x7F500404)],
            stops: [0.5, 0.501, 1],
            begin: Alignment(0.5, 0),
            end: Alignment(0.5, 0.015),
            tileMode: TileMode.repeated,
          ),
        ),
        child: widget.child,
      );
    }

    return Column(
      children: [
        GestureDetector(
          onLongPressStart: (details) {
            if (widget.onMove != null) HapticFeedback.lightImpact();
          },
          onLongPressMoveUpdate: (details) => widget.onMove?.call(details.localPosition.dx, details.localPosition.dy),
          child: Container(
            height: 30,
            width: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xAFA60707), width: 2),
              color: const Color(0x7FA60707),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: const Color(0x7FA60707), width: 2)),
                      child: IconButton(
                        iconSize: 25,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isMinimized ? Icons.fullscreen_sharp : Icons.minimize,
                          color: const Color(0xFFDF2727),
                        ),
                        alignment: Alignment.center,
                        onPressed: () {
                          setState(() {
                            isMinimized = !isMinimized;
                          });
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: const Color(0x7FA60707), width: 2)),
                      child: IconButton(
                        iconSize: 25,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFFDF2727),
                        ),
                        alignment: Alignment.center,
                        onPressed: () {
                          widget.onClose?.call();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        isMinimized
            ? const SizedBox.shrink()
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x7FA60707), width: 2),
                  gradient: const LinearGradient(
                    colors: [Color(0x7FA60707), Color(0x7F500404), Color(0x7F500404)],
                    stops: [0.5, 0.501, 1],
                    begin: Alignment(0.5, 0),
                    end: Alignment(0.5, 0.015),
                    tileMode: TileMode.repeated,
                  ),
                ),
                child: widget.child,
              ),
      ],
    );
  }
}
