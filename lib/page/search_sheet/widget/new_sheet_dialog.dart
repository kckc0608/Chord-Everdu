import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/data_class/tag_content.dart';
import 'package:chord_everdu/page/common_widget/tag.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
import 'package:provider/provider.dart';

class NewSheetDialog extends StatefulWidget {
  const NewSheetDialog({Key? key}) : super(key: key);

  @override
  _NewSheetDialogState createState() => _NewSheetDialogState();
}

class _NewSheetDialogState extends State<NewSheetDialog> {
  final _minorKeyList = []; // TODO : Minor Key List Set
  final _majorKeyList = [
    "C",
    "C#/Db",
    "D",
    "Eb",
    "E",
    "F",
    "F#/Gb",
    "G",
    "Ab",
    "A",
    "Bb",
    "B"
  ];

  final _controllerForTitle = TextEditingController();
  final _controllerForSinger = TextEditingController();
  final _focusNodeForTitle = FocusNode();
  final _focusNodeForSinger = FocusNode();

  final _formKey = GlobalKey<FormState>();

  int _selectedKey = 0;
  TagContent selectedSongLevel = TagContent.level1;
  TagContent selectedSongGenre = TagContent.kpop;

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
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// Song Title
                TextFormField(
                  controller: _controllerForTitle,
                  focusNode: _focusNodeForTitle,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "곡 제목은 필수 입력값입니다.";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "곡 제목",
                    helperText: "* 필수 입력값입니다.",
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    isCollapsed: true,
                  ),
                  onEditingComplete: () {
                    _focusNodeForTitle.unfocus();
                  },
                  autofocus: true,
                ),

                /// Singer
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: TextField(
                    focusNode: _focusNodeForSinger,
                    controller: _controllerForSinger,
                    decoration: const InputDecoration(
                      labelText: "가수",
                      border: OutlineInputBorder(),
                      isCollapsed: true,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                    ),
                    onEditingComplete: () {
                      _focusNodeForSinger.unfocus();
                    },
                  ),
                ),

                ///  Song Key
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: DropdownButtonFormField2(
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: "키",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                      isCollapsed: true,
                    ),
                    dropdownStyleData: const DropdownStyleData(
                        maxHeight: 200, offset: Offset(0, -2)),
                    value: _selectedKey,
                    items: _majorKeyList.map((value) {
                      return DropdownMenuItem(
                        value: _majorKeyList.indexOf(value),
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedKey = int.parse(value.toString());
                      });
                    },
                  ),
                ),

                /// Song Level
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        decoration: BoxDecoration(
                          border: const Border.fromBorderSide(BorderSide(
                            color: Colors.black26,
                            style: BorderStyle.solid,
                            width: 0.8,
                          )),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Tag(
                              tagContent: TagContent.level1,
                              isSelected:
                                  selectedSongLevel == TagContent.level1,
                              onTap: () {
                                setState(() {
                                  selectedSongLevel = TagContent.level1;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.level2,
                              isSelected:
                                  selectedSongLevel == TagContent.level2,
                              onTap: () {
                                setState(() {
                                  selectedSongLevel = TagContent.level2;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.level3,
                              isSelected:
                                  selectedSongLevel == TagContent.level3,
                              onTap: () {
                                setState(() {
                                  selectedSongLevel = TagContent.level3;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        color: Theme.of(context).dialogBackgroundColor,
                        child: Text(
                          "난이도",
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .fontSize),
                        ),
                      ),
                    ),
                  ],
                ),

                /// Song Genre
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        decoration: BoxDecoration(
                          border: const Border.fromBorderSide(BorderSide(
                            color: Colors.black26,
                            style: BorderStyle.solid,
                            width: 0.8,
                          )),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.center,
                          children: [
                            Tag(
                              tagContent: TagContent.kpop,
                              isSelected: selectedSongGenre == TagContent.kpop,
                              onTap: () {
                                setState(() {
                                  selectedSongGenre = TagContent.kpop;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.jpop,
                              isSelected: selectedSongGenre == TagContent.jpop,
                              onTap: () {
                                setState(() {
                                  selectedSongGenre = TagContent.jpop;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.pop,
                              isSelected: selectedSongGenre == TagContent.pop,
                              onTap: () {
                                setState(() {
                                  selectedSongGenre = TagContent.pop;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.ccm,
                              isSelected: selectedSongGenre == TagContent.ccm,
                              onTap: () {
                                setState(() {
                                  selectedSongGenre = TagContent.ccm;
                                });
                              },
                            ),
                            Tag(
                              tagContent: TagContent.hiphop,
                              isSelected:
                                  selectedSongGenre == TagContent.hiphop,
                              onTap: () {
                                setState(() {
                                  selectedSongGenre = TagContent.hiphop;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4.0,
                      left: 8.0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        color: Theme.of(context).dialogBackgroundColor,
                        child: Text(
                          "장르",
                          style: TextStyle(
                              color: Theme.of(context).hintColor,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .fontSize),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
        ElevatedButton(
          child: const Text("확인"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<Sheet>().updateSheetInfo(
                    SheetInfo(
                      title: _controllerForTitle.text,
                      singer: _controllerForSinger.text,
                      songKey: _selectedKey,
                      genre: selectedSongGenre,
                      level: selectedSongLevel,
                    ),
                  );
              context.read<Sheet>().isReadOnly = false;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (_) => const SheetViewer(
                        sheetID: "",
                      )));
            }
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
