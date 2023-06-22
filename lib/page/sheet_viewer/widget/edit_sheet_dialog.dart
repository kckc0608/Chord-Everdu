import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditSheetDialog extends StatefulWidget {
  final int songKey;
  final String title;
  final String singer;
  const EditSheetDialog({
    Key? key,
    required this.songKey,
    required this.title,
    required this.singer,
  }) : super(key: key);

  @override
  State<EditSheetDialog> createState() => _EditSheetDialogState();
}

class _EditSheetDialogState extends State<EditSheetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _majorKeyList = [
    "C", "C#/Db", "D", "Eb", "E", "F", "F#/Gb", "G", "Ab", "A", "Bb", "B"
  ];
  int _selectedKey = 0;
  final _titleController = TextEditingController();
  final _singerController = TextEditingController();


  @override
  void dispose() {
    _titleController.dispose();
    _singerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.title;
    return AlertDialog(
      title: const Text("악보 정보 수정"),
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
                      controller: _titleController,
                      //focusNode: _focusNodeForTitle,
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
                        //_focusNodeForTitle.unfocus();
                      },

                    ),
                    const SizedBox(height: 12),
                    TextField(
                      //focusNode: _focusNodeForSinger,
                      controller: _singerController,
                      style: const TextStyle(fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: "가수",
                        labelStyle: TextStyle(fontSize: 20),
                        border: OutlineInputBorder(),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 8),
                      ),
                      onEditingComplete: () {
                        //_focusNodeForSinger.unfocus();
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
                          _selectedKey = value ?? 0; //int.parse(value.toString());
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    // Stack(
                    //     children: [
                    //       Padding(
                    //         padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    //         child: Container(
                    //           decoration: BoxDecoration(
                    //               border: Border.fromBorderSide(BorderSide(color: Colors.grey[300]!,)),
                    //               borderRadius: BorderRadius.circular(4.0)
                    //           ),
                    //           child: Row(
                    //             //mainAxisSize: MainAxisSize.min,
                    //             children: [
                    //               Radio<int>(
                    //                 value: 1,
                    //                 groupValue: lyricLine,
                    //                 onChanged: (line) {
                    //                   setState(() {
                    //                     lyricLine = line!;
                    //                   });
                    //                 },
                    //               ),
                    //               const Text("1줄"),
                    //               Radio<int>(
                    //                 value: 2,
                    //                 groupValue: lyricLine,
                    //                 onChanged: (line) {
                    //                   setState(() {
                    //                     lyricLine = line!;
                    //                   });
                    //                 },
                    //               ),
                    //               const Text("2줄"),
                    //               Radio<int>(
                    //                 value: 3,
                    //                 groupValue: lyricLine,
                    //                 onChanged: (line) {
                    //                   setState(() {
                    //                     lyricLine = line!;
                    //                   });
                    //                 },
                    //               ),
                    //               const Text("3줄"),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //       Positioned(
                    //         left: 8,
                    //         top: 2,
                    //         child: Container(
                    //             color: Theme.of(context).dialogBackgroundColor,
                    //             padding: EdgeInsets.symmetric(horizontal: 3),
                    //             child: Text("가사 줄 수", style: TextStyle(fontSize: 15, color: Colors.black54))),
                    //       ),
                    //     ]
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("확인"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              SheetInfo newInfo = SheetInfo(
                title: _titleController.text,
                singer: _singerController.text,
                songKey: _selectedKey,
              );
              context.read<Sheet>().updateSheetInfo(newInfo);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );;
  }
}
