import 'package:flutter/material.dart';

class SheetEditor extends StatefulWidget {
  final String sheetID;
  final String title;


  const SheetEditor({
    Key? key,
    required this.sheetID,
    required this.title,
  }) : super(key: key);

  @override
  State<SheetEditor> createState() => _SheetEditorState();
}

class _SheetEditorState extends State<SheetEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [],
        ),
        body: const SafeArea(
            child: Column(
          children: [],
        )));
  }
}
