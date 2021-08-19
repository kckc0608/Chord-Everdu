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

  int lyricLine = 1;

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
      titlePadding: EdgeInsets.fromLTRB(20, 20, 0, 0),
      contentPadding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
      content: SizedBox(
        width: 300,
        height: 300,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                      decoration: const InputDecoration(
                        labelText: "키",
                        labelStyle: TextStyle(fontSize: 20),
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
                    SizedBox(height: 12),
                    Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.fromBorderSide(BorderSide(color: Colors.grey[300]!,)),
                                borderRadius: BorderRadius.circular(4.0)
                            ),
                            child: Row(
                              //mainAxisSize: MainAxisSize.min,
                              children: [
                                Radio<int>(
                                  value: 1,
                                  groupValue: lyricLine,
                                  onChanged: (line) {
                                    setState(() {
                                      lyricLine = line!;
                                    });
                                  },
                                ),
                                Text("1줄"),
                                Radio<int>(
                                  value: 2,
                                  groupValue: lyricLine,
                                  onChanged: (line) {
                                    setState(() {
                                      lyricLine = line!;
                                    });
                                  },
                                ),
                                Text("2줄"),
                                Radio<int>(
                                  value: 3,
                                  groupValue: lyricLine,
                                  onChanged: (line) {
                                    setState(() {
                                      lyricLine = line!;
                                    });
                                  },
                                ),
                                Text("3줄"),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          top: 2,
                          child: Container(
                            color: Theme.of(context).dialogBackgroundColor,
                            padding: EdgeInsets.symmetric(horizontal: 3),
                            child: Text("가사 줄 수", style: TextStyle(fontSize: 15, color: Colors.black54))),
                        ),
                      ]
                    ),
                  ],
                ),
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
              Navigator.of(context).pushReplacement(
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