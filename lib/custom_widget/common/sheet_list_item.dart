import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class SheetListItem extends StatelessWidget {
  final String title, singer, sheetID;
  final bool isEditable, isDeletable;
  final int songKey;

  const SheetListItem({
    Key? key,
    required this.sheetID,
    required this.title,
    required this.singer,
    required this.songKey,
    this.isEditable = false,
    this.isDeletable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _DB = FirebaseFirestore.instance;
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return SheetEditor(
                sheetID: sheetID,
                title:   title,
                singer:  singer,
                songKey: songKey,
                readOnly: true,
              );
            })
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text(singer, style: TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            isEditable
                ? IconButton(icon: Icon(Icons.edit_outlined), onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return SheetEditor(
                          sheetID: sheetID,
                          title:   title,
                          singer:  singer,
                          songKey: songKey,
                        );
                      })
                  );
                })
                : SizedBox.shrink(),
            isDeletable
                ? IconButton(icon: Icon(Icons.delete_forever_outlined), onPressed: () {
                    showDialog(context: context, builder: (context) {
                      return AlertDialog(
                        title: Text("?????? ??????"),
                        content: Text("?????? ????????? ????????????????"),
                        actions: [
                          TextButton(onPressed: () {Navigator.of(context).pop(true);}, child: Text("???")),
                          TextButton(onPressed: () {Navigator.of(context).pop(false);}, child: Text("?????????")),
                        ],
                      );
                    }).then((isDelete) {
                      if (isDelete) {
                        /// ?????? ??????
                        _DB.collection('sheet_list').doc(sheetID).delete().then((value) {
                          showDialog(context: context, builder: (context) => AlertDialog(
                            content: Text("????????? ?????????????????????."),
                            actions: [TextButton(child: Text("??????"), onPressed: () {Navigator.of(context).pop();},)],
                          ));
                        }).catchError((error) {
                          print(error.toString());
                        });
                      }
                    });
                  })
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}