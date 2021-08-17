import 'package:flutter/material.dart';

class SearchSheetDialog extends StatefulWidget {
  const SearchSheetDialog({Key? key}) : super(key: key);

  @override
  _SearchSheetDialogState createState() => _SearchSheetDialogState();
}

class _SearchSheetDialogState extends State<SearchSheetDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("악보 검색"),
    );
  }
}
