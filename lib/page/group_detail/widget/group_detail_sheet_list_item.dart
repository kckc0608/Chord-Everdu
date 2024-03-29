import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GroupDetailSheetList extends StatelessWidget {
  final String sheetID, title, singer;
  VoidCallback? onDelete;

  GroupDetailSheetList({
    Key? key,
    required this.sheetID,
    required this.title,
    required this.singer,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.read<Sheet>().isReadOnly = true;
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
                Text(
                  singer,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            )),
            if (onDelete == null) const SizedBox.shrink() else IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.redAccent,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("악보 삭제"),
                          content: const Text("선택한 악보를 현재 일정에서 삭제하시겠습니까?"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("취소")),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: onDelete,
                              child: const Text("삭제"),
                            ),
                          ],
                        ),
                      );
                    }),
          ],
        ),
      ),
    );
  }
}
