import 'package:chord_everdu/data_class/sheet.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetViewerControlBar extends StatefulWidget {
  const SheetViewerControlBar({super.key});

  @override
  State<SheetViewerControlBar> createState() => _SheetViewerControlBarState();
}

class _SheetViewerControlBarState extends State<SheetViewerControlBar> {
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
                      onPressed: () {
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
                      onPressed: () {
                        context.read<Sheet>().increaseSheetKey();
                      },
                    ),
                  ],
                ),
                const Text("노래 키"),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              iconSize: 36,
              onPressed: () {
                // TODO 자동 스크롤 구현
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
                      onPressed: () {
                        context.read<Sheet>().decreaseSheetKey();
                      },
                    ),
                    const Text(
                      "스크롤 속도",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.exposure_plus_1),
                      iconSize: 24,
                      onPressed: () {
                        context.read<Sheet>().increaseSheetKey();
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
