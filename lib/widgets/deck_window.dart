import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// If [hasWindowBar] is false, there must only be one child
class DeckWindow extends StatefulWidget {
  DeckWindow({
    super.key,
    this.onClose,
    this.tabs,
    this.onMove,
    this.hasWindowBar = true,
    this.backgroundOpacity = 0.15,
  }) {
    assert(hasWindowBar || tabs == null || tabs!.length < 2);
  }

  factory DeckWindow.single({
    key,
    void Function()? onClose,
    void Function(double x, double y)? onMove,
    bool hasWindowBar = true,
    double backgroundOpacity = 0.15,
    Widget? child,
    String title = "",
  }) {
    return DeckWindow(
      key: key,
      onClose: onClose,
      onMove: onMove,
      hasWindowBar: hasWindowBar,
      backgroundOpacity: backgroundOpacity,
      tabs: child != null ? [DeckWindowTab(title: title, child: child)] : null,
    );
  }

  final List<DeckWindowTab>? tabs;
  final void Function()? onClose;
  final void Function(double x, double y)? onMove;
  final bool hasWindowBar;
  final double backgroundOpacity;

  @override
  State<DeckWindow> createState() => _DeckWindowState();
}

class _DeckWindowState extends State<DeckWindow> {
  bool isMinimized = false;
  int tabSelected = 0;

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
        child: widget.tabs?.first.child,
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
              height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xAFA60707), width: 2),
                color: const Color(0x7FA60707),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < (widget.tabs?.length ?? 0); i++)
                        Container(
                          decoration: BoxDecoration(border: Border.all(color: const Color(0x7FA60707), width: 2)),
                          child: TextButton(
                            child: Text(
                              widget.tabs?[i].title ?? "",
                              style: TextStyle(
                                fontWeight: tabSelected == i ? FontWeight.bold : FontWeight.normal,
                                color: const Color(0xFFDF2727),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                tabSelected = i;
                              });
                            },
                          ),
                        ),
                    ],
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
                            if (widget.onClose != null) {
                              widget.onClose!();
                            } else {
                              if (Navigator.of(context).canPop()) Navigator.of(context).pop();
                            }
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
                  child: widget.tabs?[tabSelected].child,
                ),
        ],
      ),
    );
  }
}

class DeckWindowTab {
  String title;
  Widget child;

  DeckWindowTab({required this.title, required this.child});
}
