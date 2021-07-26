import 'package:chord_everdu/custom_widget/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_class/chord.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/custom_widget/chord_cell.dart';
import 'package:chord_everdu/custom_widget/dynamic_tab.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class SheetEditor extends StatefulWidget {
  final String? sheetID;
  final String title;
  final String singer;
  final int songKey;
  final bool readOnly;

  const SheetEditor({
    Key? key,
    required this.title,
    required this.singer,
    required this.songKey,
    this.sheetID,
    this.readOnly = false
  }) : super(key: key);

  @override
  SheetEditorState createState() => SheetEditorState();
}

class SheetEditorState extends State<SheetEditor> {

  late int songKey;
  var _formKey = GlobalKey<FormState>(); // 새 탭 추가시 띄우는 다이어로그의 폼 키

  TextEditingController? cellTextController;

  bool isChordInput = false;

  @override
  void initState() {
    super.initState();
    context.read<Sheet>().allClear();
    songKey = widget.songKey;
    context.read<Sheet>().songKey = widget.songKey;

    if (widget.sheetID != null) getSheet();
    else context.read<Sheet>().addPage('전체');
  }

  @override
  Widget build(BuildContext context) {
    songKey = context.watch<Sheet>().songKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(( (widget.sheetID == null) ? "새 악보 - " : "" ) + widget.title),
        actions: (!widget.readOnly) ?
        [
          IconButton(
            onPressed: () {
              // TODO : help 구현
            },
            icon: Icon(Icons.help_outline),
          ),
          IconButton(
            onPressed: () {
              // TODO : Setting 구현
            },
            icon: Icon(Icons.settings),
          ),
          IconButton(
            onPressed: () {
              _addSheet();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.check),
          ),
        ] :
        // READ MODE APP BAR ACTIONS
        [
          // TODO : READ MODE 상단 버튼 구현
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomTabView(
                initPosition: context.read<Sheet>().nowPage,
                itemCount: context.read<Sheet>().pageList.length,
                tabBuilder: (context, index) => Tab(text: context.read<Sheet>().pageList[index]),
                pageBuilder: (context, index) {
                  print("tab view page builder called $index");
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: context.read<Sheet>().pages[index],
                      ),
                    ),
                  );
                },
                onPositionChange: (index) {
                  print('current position: $index');
                  context.read<Sheet>().nowPage = index;
                  // TODO : 페이지가 바뀌면 이전 페이지의 포커스 해제하기
                },
                onScroll: (position) => print('$position'),
              ),
            ),
            (!widget.readOnly) ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.add, size: 28),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().selectedIndex > -1) ? () {
                      context.read<Sheet>().addCell();
                    } : null,
                  ),
                  IconButton(
                    // TODO : 한칸 남았을 때 삭제 안되게, 한칸 만들고 -> 한칸 만들고 -> 두번째 칸 둘째 줄로 -> 첫번째 칸 지울 때 컨테이너가 맨 처음으로 오는 문제 해결해야 함.
                    icon: Icon(Icons.remove, size: 28),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().selectedIndex > -1) ? () {
                      context.read<Sheet>().remove();
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward_outlined),
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().selectedIndex > 0) ? () {
                      context.read<Sheet>().newLine();
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().selectedIndex > 0) ? () {
                      context.read<Sheet>().removeBefore();
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.text_rotation_none),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    onPressed: (!isChordInput) ? () {
                      int _nowPage = context.read<Sheet>().nowPage;
                      int _maxSize = context.read<Sheet>().lyrics[_nowPage].length;
                      int _index = context.read<Sheet>().selectedIndex;

                      int cutPos = cellTextController!.selection.end;

                      String text = cellTextController!.text;

                      String beforeLyric = cellTextController!.selection.textBefore(text);
                      String afterLyric = cellTextController!.selection.textAfter(text);

                      // 옆의 빈칸이 비어있다면 (null이 아닌 것도 포함됨)
                      if (_index < _maxSize - 1 && context.read<Sheet>().getLyric(index: _index + 1) == "") {
                        //빈칸인 가사에 옮겨붙인 가사를 넣기
                        context.read<Sheet>().setLyric(_index+1, afterLyric);
                      }
                      else {
                        //칸을 새로 추가해서 가사를 넣기
                        context.read<Sheet>().addCell(index: _index + 1, lyric: afterLyric);
                      }

                      context.read<Sheet>().setLyric(_index, beforeLyric);
                      cellTextController!.text = beforeLyric;
                      context.read<Sheet>().setStateOfSheet();
                      cellTextController!.selection = TextSelection.fromPosition(TextPosition(offset: cutPos));
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_textdirection_r_to_l_outlined),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    onPressed: (!isChordInput) ? () {
                      int _nowPage = context.read<Sheet>().nowPage;
                      int _index = context.read<Sheet>().selectedIndex;

                      int cutPos = cellTextController!.selection.end;

                      String text = cellTextController!.text;

                      String beforeLyric = cellTextController!.selection.textBefore(text);
                      String afterLyric = cellTextController!.selection.textAfter(text);

                      // 왼쪽 셀이 있고, null이 아니라면 (줄넘김이 아니라면)
                      if (_index > 0 && context.read<Sheet>().lyrics[_nowPage][_index-1] != null) {
                        //빈칸인 가사에 옮겨붙인 가사를 넣기
                        context.read<Sheet>().setLyric(_index-1, context.read<Sheet>().getLyric(index: _index - 1)! + beforeLyric);
                        context.read<Sheet>().setLyric(_index, afterLyric);
                      }
                      else {
                        //칸을 새로 추가해서 가사를 넣기
                        context.read<Sheet>().addCell(index: _index, lyric: beforeLyric);
                        context.read<Sheet>().setLyric(_index + 1, afterLyric);
                      }

                      cellTextController!.text = afterLyric;
                      context.read<Sheet>().setStateOfSheet();
                      cellTextController!.selection = TextSelection.fromPosition(TextPosition(offset: cutPos));
                    } : null,
                  ),
                  Container(color: Colors.black, width: 2, height: 28), // DIVIDER
                  IconButton(
                    icon: Icon(Icons.note_add_outlined),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: () {
                      buildDialogForPage(dialogTitle: "새 페이지", afterGetTitle: (pageTitle) {
                        context.read<Sheet>().addPage(pageTitle);
                      });
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_outlined),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: () {
                      buildDialogForPage(dialogTitle: "페이지 복사", afterGetTitle: (pageTitle) {
                        // TODO : 현재 페이지 복사 기능 구현
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever_outlined, size: 28),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().nowPage > 0) ? () { // 최소한 0번 페이지는 있어야 한다.
                      // TODO : 현재 페이지 삭제 기능 구현
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit_outlined),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    onPressed: () {
                      buildDialogForPage(dialogTitle: "현재 페이지 이름 변경", afterGetTitle: (pageTitle) {
                        context.read<Sheet>().changePageName(pageTitle);
                      });
                    },
                  ),
                ],
              ),
            ) : SizedBox.shrink(),
            isChordInput ? ChordKeyboard() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  void buildDialogForPage({required Function(String) afterGetTitle, required String dialogTitle, }) {
    var controller = TextEditingController();
    showDialog (
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dialogTitle),
        content: Form(
          key: _formKey,
          child: TextFormField(
            style: TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: "페이지 이름",
              isCollapsed: true,
              contentPadding: EdgeInsets.fromLTRB(4, 12, 4, 4),
            ),
            controller: controller,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "페이지 이름을 입력하세요.";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate())
                Navigator.of(context).pop(controller.text);
            },
            child: Text("확인"),
          ),
        ],
      ),
    ).then((pageTitle) {
      setState(afterGetTitle(pageTitle));
    });
  }

  void _addSheet() {
    List<dynamic> _sheet = [];
    for (int i = 0; i < context.read<Sheet>().pageList.length; i++) {
      Map<String, dynamic> _page = {};
      _page["page"] = context.read<Sheet>().pageList[i];
      List<dynamic> _chordList = [];
      for (int j = 0; j < context.read<Sheet>().chords[i].length; j++) {
        if (context.read<Sheet>().chords[i][j] == null) _chordList.add({
          "chord" : Chord().toMap(),
          "lyric" : "<!br!>",
        });
        else _chordList.add({
          "chord" : context.read<Sheet>().chords[i][j]!.toMap(),
          "lyric" : context.read<Sheet>().lyrics[i][j]!,
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
      'editor_email' : FirebaseAuth.instance.currentUser!.email,
      'editor' : FirebaseAuth.instance.currentUser!.displayName,
      'sheet' : _sheet,
    };

    FirebaseFirestore.instance.collection('sheet_list').add(_body);
  }

  void getSheet() {
    // initialize Sheet
    context.read<Sheet>().allClear();

    FirebaseFirestore.instance.collection('sheet_list').doc(widget.sheetID).get().
    then((snapshot) {
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
          context.read<Sheet>().chords[_pageIndex].add(Chord.fromMap(cells[j]["chord"]));

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