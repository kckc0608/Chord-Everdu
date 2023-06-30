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
      color: Colors.grey,
      child: Center(child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.exposure_minus_1),
              onPressed: () {
                context.read<Sheet>().decreaseSheetKey();
              },
            ),
            Text(
              songKey.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.plus_one),
              onPressed: () {
                context.read<Sheet>().increaseSheetKey();
              },
            ),
          ],
        ),
      )),
    );
  }
}
