import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DeckWindow extends StatefulWidget {
  const DeckWindow({
    super.key,
    this.onClose,
    this.child,
    this.onMove,
    this.title,
    this.hasWindowBar = true,
    this.backgroundOpacity = 0.496,
  });

  final Widget? child;
  final String? title;
  final void Function()? onClose;
  final void Function(double x, double y)? onMove;
  final bool hasWindowBar;
  final double backgroundOpacity;

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
          gradient: LinearGradient(
            colors: [
              const Color(0xFF810505).withOpacity(widget.backgroundOpacity),
              const Color(0x7F400202).withOpacity(widget.backgroundOpacity),
              const Color(0x7F400202).withOpacity(widget.backgroundOpacity),
            ],
            stops: const [0.5, 0.501, 1],
            begin: const Alignment(0.5, 0),
            end: const Alignment(0.5, 0.015),
            tileMode: TileMode.repeated,
          ),
        ),
        child: widget.child,
      );
    }

    return IntrinsicWidth(
      child: Column(
        children: [
          GestureDetector(
            onLongPressStart: (details) {
              if (widget.onMove != null) HapticFeedback.lightImpact();
            },
            onLongPressMoveUpdate: (details) => widget.onMove?.call(details.localPosition.dx, details.localPosition.dy),
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xAFA60707), width: 2),
                color: const Color(0x7FA60707),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(widget.title ?? "", style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
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
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF810505).withOpacity(widget.backgroundOpacity),
                        const Color(0x7F400202).withOpacity(widget.backgroundOpacity),
                        const Color(0x7F400202).withOpacity(widget.backgroundOpacity),
                      ],
                      stops: const [0.5, 0.501, 1],
                      begin: const Alignment(0.5, 0),
                      end: const Alignment(0.5, 0.015),
                      tileMode: TileMode.repeated,
                    ),
                  ),
                  width: double.infinity,
                  child: widget.child,
                ),
        ],
      ),
    );
  }
}
