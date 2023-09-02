import 'package:chord_everdu/data_class/sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chord_everdu/environment/global.dart' as global;

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
  Widget build(BuildContext context) {
    int songKey = context.read<Sheet>().sheetInfo.songKey;
    int sheetKey = context.watch<Sheet>().sheetKey;//context.select((Sheet sheet) => sheet.songKey);
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
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        iconSize: 20,
                        onPressed: isAutoScroll ? null : () {
                          context.read<Sheet>().decreaseSheetKey();
                        },
                      ),
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          textBaseline: TextBaseline.ideographic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              "${global.sheetKeyList[(songKey+sheetKey)%12]}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              "(+${sheetKey.toString()})",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                        onPressed: isAutoScroll ? null : () {
                          context.read<Sheet>().increaseSheetKey();
                        },
                      ),
                    ],
                  ),
                  const Text("노래 키"),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isAutoScroll ? Icons.pause : Icons.play_arrow),
              iconSize: 34,
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
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
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
                      ),
                      Expanded(
                        child: Text(
                          scrollSpeed.toInt().toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: IconButton(
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
                      ),
                    ],
                  ),
                  const Text("스크롤 속도"),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
