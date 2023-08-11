import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/page/common_widget/common_alert_dialog.dart';
import 'package:chord_everdu/page/common_widget/tag.dart';
import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class SheetListItem extends StatefulWidget {
  final SheetInfo sheetInfo;
  final String sheetID;
  final bool isFavorite;
  VoidCallback? onTap;

  SheetListItem({
    Key? key,
    required this.sheetID,
    required this.sheetInfo,
    required this.isFavorite,
    this.onTap,
  }) : super(key: key);

  @override
  State<SheetListItem> createState() => _SheetListItemState();
}

class _SheetListItemState extends State<SheetListItem> {
  late bool isFavorite;
  final _db = FirebaseFirestore.instance;


  @override
  void initState() {
    isFavorite = widget.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap ??
              () {
            context.read<Sheet>().isReadOnly = true;

            /// 이전 악보 정보가 뜨는 문제가 있어 먼저 업데이트
            context.read<Sheet>().updateSheetInfo(widget.sheetInfo);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              /// TODO : sheet info 에 sheet ID를 통합하는 것 고민
              return SheetViewer(sheetID: widget.sheetID);
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
                  Text(widget.sheetInfo.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    widget.sheetInfo.singer,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Tag(tagContent: widget.sheetInfo.genre),
            Tag(tagContent: widget.sheetInfo.level),
            IconButton(
              color: Colors.redAccent,
              icon: isFavorite ? const Icon(Icons.favorite) : const Icon(Icons.favorite_border),
              onPressed: () {
                User? currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  showDialog(
                      context: context,
                      builder: (context) =>
                      const CommonAlertDialog(content: "로그인이 필요합니다."));
                } else {
                  setState(() {
                    isFavorite = !isFavorite;
                    if (isFavorite) {
                      _db.collection('user_list')
                          .doc(currentUser.email)
                          .update({
                            "favorite_sheet": FieldValue.arrayUnion([{
                              "sheet_id": widget.sheetID,
                              "singer": widget.sheetInfo.singer,
                              "title": widget.sheetInfo.title,
                            }])
                          })
                          .then(
                            (value) => Logger().i("즐겨찾기에 추가되었습니다."),
                            onError: (e) => Logger().e(e)
                      );
                    } else {
                      _db.collection('user_list')
                          .doc(currentUser.email)
                          .update({
                            "favorite_sheet": FieldValue.arrayRemove([{
                              "sheet_id": widget.sheetID,
                              "singer": widget.sheetInfo.singer,
                              "title": widget.sheetInfo.title,
                            }])
                          })
                          .then(
                              (value) => Logger().i("즐겨찾기에서 삭제되었습니다."),
                          onError: (e) => Logger().e(e)
                      );
                    }
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
