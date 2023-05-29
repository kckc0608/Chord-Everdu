import 'package:flutter/material.dart';
import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
class NewSheetDialog extends StatefulWidget {
  const NewSheetDialog({Key? key}) : super(key: key);

  @override
  _NewSheetDialogState createState() => _NewSheetDialogState();
}

class _NewSheetDialogState extends State<NewSheetDialog> {
  final _minorKeyList = []; // TODO : Minor Key List Set
  final _majorKeyList = ["C", "C#/Db", "D", "Eb", "E", "F", "F#/Gb", "G", "Ab", "A", "Bb", "B"];
  var _selectedKey = 0;

  final _controllerForTitle = TextEditingController();
  final _controllerForSinger = TextEditingController();
  final _focusNodeForTitle = FocusNode();
  final _focusNodeForSinger = FocusNode();

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
      title: const Text("새 악보"),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
      contentPadding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
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
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _controllerForTitle,
                      focusNode: _focusNodeForTitle,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "곡 제목은 필수 입력값입니다.";
                        }
                        return null;
                      },
                      style: const TextStyle(fontSize: 20),
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
                    const SizedBox(height: 12),
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
                    const SizedBox(height: 24),
                    DropdownButtonFormField(
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      decoration: const InputDecoration(
                        labelText: "키",
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                        isCollapsed: true,
                      ),
                      value: _selectedKey,
                      items: _majorKeyList.map((value) {
                        return DropdownMenuItem(
                          value: _majorKeyList.indexOf(value),
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
                    const SizedBox(height: 12),
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
                                  const Text("1줄"),
                                  Radio<int>(
                                    value: 2,
                                    groupValue: lyricLine,
                                    onChanged: (line) {
                                      setState(() {
                                        lyricLine = line!;
                                      });
                                    },
                                  ),
                                  const Text("2줄"),
                                  Radio<int>(
                                    value: 3,
                                    groupValue: lyricLine,
                                    onChanged: (line) {
                                      setState(() {
                                        lyricLine = line!;
                                      });
                                    },
                                  ),
                                  const Text("3줄"),
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
          child: const Text("확인"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => SheetViewer(
                      title: _controllerForTitle.text,
                      sheetID: "",
                  ))
              );
            }
          },
        ),
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<TextEditingController>('_controllerForSinger', _controllerForSinger));
  // }
}