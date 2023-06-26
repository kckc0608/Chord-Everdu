import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
import 'package:flutter/material.dart';

class SheetListItem extends StatelessWidget {
  final String sheetID, title, singer;
  const SheetListItem({
    Key? key,
    required this.sheetID,
    required this.title,
    required this.singer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return SheetViewer(sheetID: sheetID);
        }));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(singer, style: const TextStyle(color: Colors.black54),),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
