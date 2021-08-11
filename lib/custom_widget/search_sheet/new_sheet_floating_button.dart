import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/custom_widget/search_sheet/new_sheet_dialog.dart';
class SearchSheetFloatingButton extends StatelessWidget {
  const SearchSheetFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            if (FirebaseAuth.instance.currentUser == null)
              return AlertDialog(
                title: Text("알림"),
                content: Text("새 악보를 추가하려면 로그인을 해야합니다."),
                actions: [TextButton(child: Text("확인"), onPressed: () {Navigator.of(context).pop();})],
              );
            return NewSheetDialog();
          },
        );
      },
    );
  }
}