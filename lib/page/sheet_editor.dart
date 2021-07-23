import 'package:chord_everdu/custom_widget/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_class/chord.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/custom_widget/chord_cell.dart';
import 'package:chord_everdu/custom_widget/dynamic_tab.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<List<Widget>> sheet = [];

  ChordCell? currentCell;
  TextEditingController? cellTextController;

  bool isChordInput = false;

  @override
  void initState() {
    super.initState();
    context.read<Sheet>().allClear();
    songKey = widget.songKey;
    context.read<Sheet>().songKey = widget.songKey;

    print("init state of editor");
    if (widget.sheetID != null){
      getSheet();
    }
    else {
      context.read<Sheet>().pageList.add('전체');
      context.read<Sheet>().chords.add([Chord()]);
      context.read<Sheet>().lyrics.add(['가사']);
      sheet.add([ChordCell(key: UniqueKey(), pageIndex: 0,)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    songKey = context.watch<Sheet>().songKey;

    if (currentCell == null) context.read<Sheet>().selectedIndex = -1;
    else context.read<Sheet>().selectedIndex = sheet[context.read<Sheet>().nowPage].indexOf(currentCell!);

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
                  List<Widget> pageSheet = sheet[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SingleChildScrollView(
                      child: Wrap(
                        children: pageSheet,
                      ),
                    ),
                  );
                },
                onPositionChange: (index) {
                  print('current position: $index');
                  context.read<Sheet>().nowPage = index;
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
                    onPressed: (currentCell != null && context.read<Sheet>().selectedIndex > -1) ? () {
                      setState(() {
                        context.read<Sheet>().add(Chord());
                        sheet[context.read<Sheet>().nowPage].insert(context.read<Sheet>().selectedIndex+1, ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().nowPage,));
                      });
                    } : null,
                  ),
                  IconButton(
                    // TODO : 한칸 남았을 때 삭제 안되게, 한칸 만들고 -> 한칸 만들고 -> 두번째 칸 둘째 줄로 -> 첫번째 칸 지울 때 컨테이너가 맨 처음으로 오는 문제 해결해야 함.
                    icon: Icon(Icons.remove, size: 28),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (currentCell != null && context.read<Sheet>().selectedIndex > -1) ? () {
                      setState(() {
                        context.read<Sheet>().remove();
                        sheet[context.read<Sheet>().nowPage].removeAt(context.read<Sheet>().selectedIndex);
                      });
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward_outlined),
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().selectedIndex > 0) ? () {
                      setState(() {
                        context.read<Sheet>().newLine();
                        sheet[context.read<Sheet>().nowPage].insert(context.read<Sheet>().selectedIndex, Container(width: 1000, key: UniqueKey()));
                      });
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (currentCell != null && context.read<Sheet>().selectedIndex > 0) ? () {
                      setState(() {
                        context.read<Sheet>().removeBefore();
                        sheet[context.read<Sheet>().nowPage].removeAt(context.read<Sheet>().selectedIndex-1);
                      });
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.text_rotation_none),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    onPressed: (!isChordInput) ? () {
                      if (context.read<Sheet>().isLastSelection()) {
                        sheet[context.read<Sheet>().nowPage].add(ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().nowPage, readOnly: widget.readOnly));
                        context.read<Sheet>().add(Chord());
                      }
                      String text = cellTextController!.text;
                      int start = cellTextController!.selection.end;

                      context.read<Sheet>().setLyric(context.read<Sheet>().selectedIndex + 1, cellTextController!.selection.textAfter(text));
                      cellTextController!.text = text.replaceRange(start, null, "");
                      cellTextController!.selection = cellTextController!.selection.copyWith(baseOffset: cellTextController!.text.length, extentOffset: cellTextController!.text.length);
                      context.read<Sheet>().moveLyric();
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.format_textdirection_r_to_l_outlined),
                    color: Colors.black,
                    disabledColor: Colors.grey,
                    onPressed: (!isChordInput) ? () {
                      if (context.read<Sheet>().isLastSelection()) {
                        sheet[context.read<Sheet>().nowPage].add(ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().nowPage, readOnly: widget.readOnly));
                        context.read<Sheet>().add(Chord());
                      }
                      String text = cellTextController!.text;
                      int start = cellTextController!.selection.end;

                      context.read<Sheet>().setLyric(context.read<Sheet>().selectedIndex + 1, cellTextController!.selection.textAfter(text));
                      cellTextController!.text = text.replaceRange(start, null, "");
                      cellTextController!.selection = cellTextController!.selection.copyWith(baseOffset: cellTextController!.text.length, extentOffset: cellTextController!.text.length);
                      context.read<Sheet>().moveLyric();
                    } : null,
                  ),
                  Container(color: Colors.black, width: 2, height: 28), // DIVIDER
                  IconButton(
                    icon: Icon(Icons.note_add_outlined),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: () {
                      buildDialogForPage(dialogTitle: "새 페이지", afterGetTitle: (pageTitle) {
                        context.read<Sheet>().pageList.add(pageTitle);
                        context.read<Sheet>().chords.add([Chord()]);
                        context.read<Sheet>().lyrics.add(["가사"]);
                        List<ChordCell> list = [ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().pageList.length-1,)];
                        sheet.add(list);
                        //_initPosition = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
                      });
                    }
                  ),
                  IconButton(
                    icon: Icon(Icons.copy_outlined),
                    color: Colors.green,
                    disabledColor: Colors.grey,
                    onPressed: (currentCell != null) ? () {
                      // TODO : 현재 페이지 복사 기능 구현
                      buildDialogForPage(dialogTitle: "페이지 복사", afterGetTitle: (pageTitle) {
                        context.read<Sheet>().pageList.add(pageTitle);
                        context.read<Sheet>().chords.add([Chord()]);
                        context.read<Sheet>().lyrics.add(["가사"]);
                        List<ChordCell> list = [ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().pageList.length-1,)];
                        sheet.add(list);
                        //_initPosition = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
                      });
                    } : null,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_forever_outlined, size: 28),
                    color: Colors.red,
                    disabledColor: Colors.grey,
                    onPressed: (context.read<Sheet>().nowPage > 0) ? () { // 최소한 0번 페이지는 있어야 한다.
                      setState(() {
                        // TODO : 현재 페이지 삭제 기능 구현
                      });
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
            isChordInput ? ChordKeyboard(onButtonTap: () {
              setState(() {
                // TODO : 만약 일본어, 영어처럼 원문과 번역이 같이 들어가는 가사의 경우 여러줄을 어떻게 입력할지 고민.
                // TODO : - 새 악보 생성시 가사 라인수를 받아서, 각 셀마다 라인 수만큼 가사 TextField 생성.
                // TODO : - TextField에서 엔터 가능하게 & 최대 라인 3줄로 => 동적 width 갖는 텍스트 필드가 안나올 수도 있음.
                if (cellTextController != null)
                  cellTextController!.text = context.read<Sheet>().chords[context.read<Sheet>().nowPage][context.read<Sheet>().selectedIndex]!.toStringChord(
                    songKey: context.read<Sheet>().songKey);
                else
                  throw Exception("cellTextController 가 null 이기 때문에 코드 키보드를 불러오지 못했습니다.");
              });
            }) : SizedBox.shrink(),
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
          "chord" : Chord().toJson(),
          "lyric" : "<!br!>",
        });
        else _chordList.add({
          "chord" : context.read<Sheet>().chords[i][j]!.toJson(),
          "lyric" : context.read<Sheet>().lyrics[i][j]!,
        });
      }
      _page["chords"] = _chordList;
      _sheet.add(_page);
    }

    print(_sheet.toString());

    Map<String, dynamic> _body = {
      'sheet_id' : 2,
      'title': widget.title,
      'singer': widget.singer,
      'song_key': songKey,
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

        sheet.add([]);
        context.read<Sheet>().lyrics.add([]);
        context.read<Sheet>().chords.add([]);
        context.read<Sheet>().pageList.add(page["page"]);

        var cells = page["chords"];

        for (int j = 0; j < cells.length; j++) {
          if (cells[j]["lyric"] == "<!br!>") {
            sheet[_pageIndex].add(Container(width: 1000));
            context.read<Sheet>().lyrics[_pageIndex].add(null);
            context.read<Sheet>().chords[_pageIndex].add(null);
            continue;
          }

          context.read<Sheet>().lyrics[_pageIndex].add(cells[j]["lyric"]);
          context.read<Sheet>().chords[_pageIndex].add(Chord.fromMap(cells[j]["chord"]));
        }

        sheet[_pageIndex].add(ChordCell(
          key: UniqueKey(),
          pageIndex: _pageIndex,
          readOnly: widget.readOnly,
        ));
      }
      setState(() {});
    });
  }
}