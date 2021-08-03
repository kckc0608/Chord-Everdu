import 'package:chord_everdu/custom_widget/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_class/chord.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/custom_widget/chord_cell.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:chord_everdu/custom_widget/DottedButton.dart';

class SheetEditor extends StatefulWidget {
  final String? sheetID;
  final String title;
  final String singer;
  final int songKey;
  final bool readOnly;

  const SheetEditor(
      {
        Key? key,
        required this.title,
        required this.singer,
        required this.songKey,
        this.sheetID,
        this.readOnly = false,
      }) : super(key: key);

  @override
  SheetEditorState createState() => SheetEditorState();
}

class SheetEditorState extends State<SheetEditor> {
  late int songKey;
  late String title, singer;
  var _formKey = GlobalKey<FormState>(); // 새 탭 추가시 띄우는 다이어로그의 폼 키

  TextEditingController? cellTextController;

  bool isChordInput = false;

  @override
  void initState() {
    super.initState();
    context.read<Sheet>().allClear();
    songKey = widget.songKey;
    context.read<Sheet>().songKey = widget.songKey;
    title = widget.title;
    singer = widget.singer;

    if (widget.sheetID != null)
      getSheet(isInitialize: false);
    else
      context.read<Sheet>().addPage('전체');
  }

  @override
  Widget build(BuildContext context) {
    songKey = context.select((Sheet s) => s.songKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(((widget.sheetID == null) ? "새 악보 - " : "") + title),
        actions: (!widget.readOnly) ?
        [
          IconButton(
            onPressed: () {
              // TODO : help 구현
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("도움말"),
                  content: Container(
                    width: 320,
                    height: 400,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("기본적으로 하나의 칸에 하나의 코드와 가사를 작성하는 방법으로 악보를 작성합니다.\n"),
                          Row(
                            children: [
                              Icon(Icons.add, color: Colors.green),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text("현재 선택한 칸의 오른쪽에 새로운 칸을 하나 추가합니다.")
                              )
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.remove, color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(child: Text("현재 선택한 칸을 삭제합니다.")),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.arrow_downward_outlined,
                                  color: Colors.black),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text("현재 선택한 칸과 이후의 칸들을 다음 줄로 내립니다.\n""연속으로 쓸 수 없습니다. 전체 악보를 볼 때 중간에 빈줄을 만드려면 페이지를 나누어야 합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.arrow_back,
                                  color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(
                                  child: Text("현재 선택한 셀의 왼쪽의 칸을 지웁니다. 만약 줄이 바뀌어있다면 줄바꿈을 취소합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.text_rotation_none, color: Colors.black),
                              SizedBox(width: 10),
                              Expanded(child: Text(
                                  "현재 커서를 기준으로 오른쪽 가사를 오른쪽 칸으로 이동합니다.""오른쪽 칸에 가사가 이미 있거나 오른쪽에 칸이 없다면 새로운 칸을 추가하여 가사를 이동합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                  Icons.format_textdirection_r_to_l_outlined,
                                  color: Colors.black,
                              ),
                              SizedBox(width: 10),
                              Expanded(child: Text(
                                  "현재 커서를 기준으로 왼쪽 가사를 왼쪽 칸의 가사 뒤에 붙입니다.""왼쪽에 칸이 없다면 칸을 새로 추가하여 가사를 이동합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.note_add_outlined, color: Colors.green),
                              SizedBox(width: 10),
                              Expanded(child: Text("새 페이지를 추가합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.copy, color: Colors.green),
                              SizedBox(width: 10),
                              Expanded(child: Text("현재 페이지를 복사합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.delete_forever_outlined, color: Colors.red),
                              SizedBox(width: 10),
                              Expanded(child: Text("현재 페이지를 삭제합니다. 첫 페이지는 삭제할 수 없습니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.black),
                              SizedBox(width: 10),
                              Expanded(child: Text("현재 페이지의 이름을 수정합니다."))
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            icon: Icon(Icons.help_outline),
          ),
          IconButton(
            onPressed: () {
              // TODO : Setting 구현
              var _keyList = ["C", "C#/Db", "D", "Eb", "E", "F", "F#/Gb", "G", "Ab", "A", "Bb", "B"];
              var _controllerForTitle = TextEditingController();
              _controllerForTitle.text = title;
              var _controllerForSinger = TextEditingController();
              _controllerForSinger.text = singer;
              var _focusNodeForTitle = FocusNode();
              var _focusNodeForSinger = FocusNode();
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                              title: Text("악보 정보 수정"),
                              content: SizedBox(
                                width: 290,
                                height: 230,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: SingleChildScrollView(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 20),
                                          TextFormField(
                                            controller: _controllerForTitle,
                                            focusNode: _focusNodeForTitle,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "곡 제목은 필수 입력값입니다.";
                                              }
                                              return null;
                                            },
                                            style: TextStyle(fontSize: 20),
                                            decoration: const InputDecoration(
                                              labelText: "곡 제목",
                                              labelStyle:
                                                  TextStyle(fontSize: 20),
                                              helperText: "* 필수 입력값입니다.",
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      12, 16, 12, 8),
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
                                              labelStyle:
                                                  TextStyle(fontSize: 20),
                                              border: OutlineInputBorder(),
                                              isCollapsed: true,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      12, 16, 12, 8),
                                            ),
                                            onEditingComplete: () {
                                              _focusNodeForSinger.unfocus();
                                            },
                                          ),
                                          SizedBox(height: 24),
                                          DropdownButtonFormField(
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                            decoration: InputDecoration(
                                              labelText: "키",
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      12, 12, 12, 8),
                                              isCollapsed: true,
                                            ),
                                            value: songKey,
                                            items: _keyList.map((value) {
                                              return DropdownMenuItem(
                                                value: _keyList.indexOf(value),
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                songKey =
                                                    int.parse(value.toString());
                                                context.read<Sheet>().songKey =
                                                    songKey;
                                                context
                                                    .read<Sheet>()
                                                    .setStateOfSheet();
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
                                      setState(() {
                                        title = _controllerForTitle.text;
                                        singer = _controllerForSinger.text;
                                      });
                                      Navigator.of(context).pop();
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
                            ),
              );
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              if (widget.sheetID == null)
                _addSheet();
              else
                _updateSheet(widget.sheetID!);

              Navigator.of(context).pop();},
            icon: Icon(Icons.check),
          ),
        ] :
        [
          // TODO : READ MODE 상단 버튼 구현
        ],
        bottom: PreferredSize(
          child: Container(
            height: 32.0,
            color: Colors.orange,
            child: Row(),
          ),
          preferredSize: Size.fromHeight(32.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0),
                      color: Colors.amber.shade100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(4, 0, 0, 8.0),
                            child: Row(
                              children: [
                                Text(
                                  context.read<Sheet>().pageList[0],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                InkWell(
                                  onTap: () {
                                    print("Edit Touched");
                                  },
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 22,
                                  ),
                                ),
                                SizedBox(
                                  width: 4.0,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Icon(
                                    Icons.delete_forever_outlined,
                                    size: 22,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Wrap(
                            children: context.read<Sheet>().pages[0],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DottedButton(
                        padding: EdgeInsets.all(8.0),
                        onTap: () {},
                        child: Center(
                          child: Icon(Icons.add_circle_outline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 편집용 아이콘 버튼들
            (!widget.readOnly)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, size: 28),
                        color: Colors.green,
                        disabledColor: Colors.grey,
                        onPressed: (context.read<Sheet>().selectedIndex > -1)
                            ? () {
                                setState(() {
                                  context.read<Sheet>().addCell();
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        // TODO : 한칸 남았을 때 삭제 안되게, 한칸 만들고 -> 한칸 만들고 -> 두번째 칸 둘째 줄로 -> 첫번째 칸 지울 때 컨테이너가 맨 처음으로 오는 문제 해결해야 함.
                        icon: Icon(Icons.remove, size: 28),
                        color: Colors.red,
                        disabledColor: Colors.grey,
                        onPressed: (context.read<Sheet>().selectedIndex > -1)
                            ? () {
                                setState(() {
                                  context.read<Sheet>().remove();
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_downward_outlined),
                        disabledColor: Colors.grey,
                        onPressed: (context.read<Sheet>().selectedIndex > 0)
                            ? () {
                                setState(() {
                                  context.read<Sheet>().newLine();
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        color: Colors.red,
                        disabledColor: Colors.grey,
                        onPressed: (context.read<Sheet>().selectedIndex > 0)
                            ? () {
                                setState(() {
                                  context.read<Sheet>().removeBefore();
                                });
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.text_rotation_none),
                        color: Colors.black,
                        disabledColor: Colors.grey,
                        onPressed: (!isChordInput)
                            ? () {
                                int _nowPage = context.read<Sheet>().nowPage;
                                int _maxSize = context
                                    .read<Sheet>()
                                    .lyrics[_nowPage]
                                    .length;
                                int _index =
                                    context.read<Sheet>().selectedIndex;

                                int cutPos = cellTextController!.selection.end;

                                String text = cellTextController!.text;

                                String beforeLyric = cellTextController!
                                    .selection
                                    .textBefore(text);
                                String afterLyric = cellTextController!
                                    .selection
                                    .textAfter(text);

                                // 옆의 빈칸이 비어있다면 (null이 아닌 것도 포함됨)
                                if (_index < _maxSize - 1 &&
                                    context
                                            .read<Sheet>()
                                            .getLyric(index: _index + 1) ==
                                        "") {
                                  //빈칸인 가사에 옮겨붙인 가사를 넣기
                                  context
                                      .read<Sheet>()
                                      .setLyric(_index + 1, afterLyric);
                                } else {
                                  //칸을 새로 추가해서 가사를 넣기
                                  context.read<Sheet>().addCell(
                                      index: _index + 1, lyric: afterLyric);
                                }

                                context
                                    .read<Sheet>()
                                    .setLyric(_index, beforeLyric);
                                cellTextController!.text = beforeLyric;
                                context.read<Sheet>().setStateOfSheet();
                                cellTextController!.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cutPos));
                              }
                            : null,
                      ),
                      IconButton(
                        icon: Icon(Icons.format_textdirection_r_to_l_outlined),
                        color: Colors.black,
                        disabledColor: Colors.grey,
                        onPressed: (!isChordInput)
                            ? () {
                                int _nowPage = context.read<Sheet>().nowPage;
                                int _index =
                                    context.read<Sheet>().selectedIndex;

                                int cutPos = cellTextController!.selection.end;

                                String text = cellTextController!.text;

                                String beforeLyric = cellTextController!
                                    .selection
                                    .textBefore(text);
                                String afterLyric = cellTextController!
                                    .selection
                                    .textAfter(text);

                                // 왼쪽 셀이 있고, null이 아니라면 (줄넘김이 아니라면)
                                if (_index > 0 &&
                                    context.read<Sheet>().lyrics[_nowPage]
                                            [_index - 1] !=
                                        null) {
                                  //빈칸인 가사에 옮겨붙인 가사를 넣기
                                  context.read<Sheet>().setLyric(
                                      _index - 1,
                                      context
                                              .read<Sheet>()
                                              .getLyric(index: _index - 1)! +
                                          beforeLyric);
                                  context
                                      .read<Sheet>()
                                      .setLyric(_index, afterLyric);
                                } else {
                                  //칸을 새로 추가해서 가사를 넣기
                                  context.read<Sheet>().addCell(
                                      index: _index, lyric: beforeLyric);
                                  context
                                      .read<Sheet>()
                                      .setLyric(_index + 1, afterLyric);
                                }

                                cellTextController!.text = afterLyric;
                                context.read<Sheet>().setStateOfSheet();
                                cellTextController!.selection =
                                    TextSelection.fromPosition(
                                        TextPosition(offset: cutPos));
                              }
                            : null,
                      ),
                    ],
                  )
                : SizedBox.shrink(),
            isChordInput
                ? ChordKeyboard(insertAllFunction: () {
                    setState(() {
                      int _select = context.read<Sheet>().selectedIndex + 1;
                      for (int i = 0; i < global.recentChord.length; i++) {
                        context.read<Sheet>().addCell(
                            index: _select + i,
                            chord:
                                Chord.fromMap(global.recentChord[i].toMap()));
                      }
                    });
                  })
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void _addSheet() {
    List<dynamic> _sheet = [];
    for (int i = 0; i < context.read<Sheet>().pageList.length; i++) {
      Map<String, dynamic> _page = {};
      _page["page"] = context.read<Sheet>().pageList[i];
      List<dynamic> _chordList = [];
      for (int j = 0; j < context.read<Sheet>().chords[i].length; j++) {
        if (context.read<Sheet>().chords[i][j] == null)
          _chordList.add({
            "chord": Chord().toMap(),
            "lyric": "<!br!>",
          });
        else
          _chordList.add({
            "chord": context.read<Sheet>().chords[i][j]!.toMap(),
            "lyric": context.read<Sheet>().lyrics[i][j]!,
          });
      }
      _page["chords"] = _chordList;
      _sheet.add(_page);
    }

    print(_sheet.toString());

    Map<String, dynamic> _body = {
      'title': widget.title,
      'singer': widget.singer,
      'song_key': songKey,
      'editor_email': FirebaseAuth.instance.currentUser!.email,
      'editor': FirebaseAuth.instance.currentUser!.displayName,
      'sheet': _sheet,
    };

    FirebaseFirestore.instance.collection('sheet_list').add(_body);
  }

  void _updateSheet(String sheetID) {
    List<dynamic> _sheet = [];
    for (int i = 0; i < context.read<Sheet>().pageList.length; i++) {
      Map<String, dynamic> _page = {};
      _page["page"] = context.read<Sheet>().pageList[i];
      List<dynamic> _chordList = [];
      for (int j = 0; j < context.read<Sheet>().chords[i].length; j++) {
        if (context.read<Sheet>().chords[i][j] == null)
          _chordList.add({
            "chord": Chord().toMap(),
            "lyric": "<!br!>",
          });
        else
          _chordList.add({
            "chord": context.read<Sheet>().chords[i][j]!.toMap(),
            "lyric": context.read<Sheet>().lyrics[i][j]!,
          });
      }
      _page["chords"] = _chordList;
      _sheet.add(_page);
    }

    print(_sheet.toString());

    Map<String, dynamic> _body = {
      'title': title,
      'singer': singer,
      'song_key': songKey,
      'editor_email': FirebaseAuth.instance.currentUser!.email,
      'editor': FirebaseAuth.instance.currentUser!.displayName,
      'sheet': _sheet,
    };

    FirebaseFirestore.instance
        .collection('sheet_list')
        .doc(sheetID)
        .update(_body);
  }

  void getSheet({bool isInitialize = true}) {
    if (isInitialize) {
      // initialize Sheet
      context.read<Sheet>().allClear();
    }

    FirebaseFirestore.instance
        .collection('sheet_list')
        .doc(widget.sheetID)
        .get()
        .then((snapshot) {
      var data = snapshot.data();
      print(data.toString());
      var _sheet = data!['sheet'];
      for (int _pageIndex = 0; _pageIndex < _sheet.length; _pageIndex++) {
        var page = _sheet[_pageIndex];

        context.read<Sheet>().pages.add([]);
        context.read<Sheet>().lyrics.add([]);
        context.read<Sheet>().chords.add([]);
        context.read<Sheet>().pageList.add(page["page"]);

        var cells = page["chords"];

        for (int j = 0; j < cells.length; j++) {
          if (cells[j]["lyric"] == "<!br!>") {
            context.read<Sheet>().pages[_pageIndex].add(Container(width: 1000));
            context.read<Sheet>().lyrics[_pageIndex].add(null);
            context.read<Sheet>().chords[_pageIndex].add(null);
            continue;
          }

          context.read<Sheet>().lyrics[_pageIndex].add(cells[j]["lyric"]);
          context
              .read<Sheet>()
              .chords[_pageIndex]
              .add(Chord.fromMap(cells[j]["chord"]));

          context.read<Sheet>().pages[_pageIndex].add(ChordCell(
                key: UniqueKey(),
                pageIndex: _pageIndex,
                readOnly: widget.readOnly,
              ));
        }
      }
      setState(() {});
    });
  }
}
