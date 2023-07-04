import 'package:chord_everdu/data_class/sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetViewerControlBar extends StatefulWidget {
  final ScrollController scrollController;
  const SheetViewerControlBar({super.key, required this.scrollController});

  @override
  State<SheetViewerControlBar> createState() => _SheetViewerControlBarState();
}

class _SheetViewerControlBarState extends State<SheetViewerControlBar> {
  bool isAutoScroll = false;
  double scrollSpeed = 1;

  @override
  void dispose() {
    widget.scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int songKey = context.watch<Sheet>().sheetKey;//context.select((Sheet sheet) => sheet.songKey);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          offset: const Offset(0, 3),
          blurRadius: 7,
          spreadRadius: 5,
        )],
      ),
      child: Center(child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.exposure_minus_1),
                      iconSize: 24,
                      onPressed: isAutoScroll ? null : () {
                        context.read<Sheet>().decreaseSheetKey();
                      },
                    ),
                    Text(
                      songKey.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.exposure_plus_1),
                      iconSize: 24,
                      onPressed: isAutoScroll ? null : () {
                        context.read<Sheet>().increaseSheetKey();
                      },
                    ),
                  ],
                ),
                const Text("노래 키"),
              ],
            ),
            IconButton(
              icon: Icon(isAutoScroll ? Icons.pause : Icons.play_arrow),
              iconSize: 36,
              onPressed: () {
                setState(() {
                  isAutoScroll = !isAutoScroll;
                });
                if (isAutoScroll) {
                  /// TODO : auto 스크롤 중에 화면 터치해서 스크롤 바꾸면 그 뒤로는 auto scoll이 안됨.
                  double maxExtent = widget.scrollController.position.maxScrollExtent;
                  double distanceDifference = maxExtent - widget.scrollController.offset;
                  double durationDouble = distanceDifference / (scrollSpeed*2);

                  widget.scrollController.animateTo(
                    maxExtent,
                    duration: Duration(seconds: durationDouble.toInt()),
                    curve: Curves.linear,
                  );
                } else {
                  widget.scrollController.animateTo(
                    widget.scrollController.offset,
                    duration: const Duration(seconds: 1),
                    curve: Curves.linear,
                  );
                }
              },
            ),
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.exposure_minus_1),
                      iconSize: 24,
                      onPressed: isAutoScroll ? null : () {
                        setState(() {
                          if (scrollSpeed > 1) {
                            scrollSpeed -= 1;
                          }
                        });
                      },
                    ),
                    Text(
                      scrollSpeed.toInt().toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.exposure_plus_1),
                      iconSize: 24,
                      onPressed: isAutoScroll ? null : () {
                        setState(() {
                          if (scrollSpeed < 10) {
                            scrollSpeed += 1;
                          }
                        });
                      },
                    ),
                  ],
                ),
                const Text("스크롤 속도"),
              ],
            ),
          ],
        ),
      )),
    );
  }
}
