import 'package:flutter/material.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
class NewSheetDialog extends StatefulWidget {
  const NewSheetDialog({Key? key}) : super(key: key);

  @override
  _NewSheetDialogState createState() => _NewSheetDialogState();
}

class _NewSheetDialogState extends State<NewSheetDialog> {

  var _keyList = ["C", "C#/Db", "D", "Eb", "E", "F", "F#/Gb", "G", "Ab", "A", "Bb", "B"];
  var _selectedKey = 0;

  var _controllerForTitle = TextEditingController();
  var _controllerForSinger = TextEditingController();
  var _focusNodeForTitle = FocusNode();
  var _focusNodeForSinger = FocusNode();

  final _formKey = GlobalKey<FormState>();


  @override
  void dispose() {
    _controllerForSinger.dispose();
    _controllerForTitle.dispose();
    _focusNodeForSinger.dispose();
    _focusNodeForTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("새 악보"),
      content: SizedBox(
        width: 290,
        height: 230,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _controllerForTitle,
                    focusNode: _focusNodeForTitle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "곡 제목은 필수 입력값입니다.";
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "곡 제목",
                      labelStyle: TextStyle(fontSize: 20),
                      helperText: "* 필수 입력값입니다.",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                      isCollapsed: true,
                    ),
                    onEditingComplete: () {
                      _focusNodeForTitle.unfocus();
                    },

                  ),
                  SizedBox(height: 12),
                  TextField(
                    focusNode: _focusNodeForSinger,
                    controller: _controllerForSinger,
                    style: TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "가수",
                      labelStyle: TextStyle(fontSize: 20),
                      border: OutlineInputBorder(),
                      isCollapsed: true,
                      contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                    ),
                    onEditingComplete: () {
                      _focusNodeForSinger.unfocus();
                    },
                  ),
                  SizedBox(height: 24),
                  DropdownButtonFormField(
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "키",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      isCollapsed: true,
                    ),
                    value: _selectedKey,
                    items: _keyList.map((value) {
                      return DropdownMenuItem(
                        value: _keyList.indexOf(value),
                        child: Text(value),
                      );
                    }
                    ).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKey = int.parse(value.toString());
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: Text("OK"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SheetEditor(
                      title: _controllerForTitle.text,
                      singer: _controllerForSinger.text,
                      songKey: _selectedKey,
                    );
                  })
              );
            }
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}