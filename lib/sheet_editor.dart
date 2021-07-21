import 'package:chord_everdu/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_data_structure.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/sheet.dart';
import 'package:http/http.dart' as http;
import 'package:chord_everdu/chord_cell.dart';
import 'package:provider/provider.dart';
import 'global.dart' as global;
import 'dart:convert';

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
    context.read<Sheet>().allClear();
    songKey = widget.songKey;
    context.read<Sheet>().songKey = widget.songKey;

    print("init state of editor" + context.read<Sheet>().songKey.toString());
    if (widget.sheetID != null){
      getSheet();
    }
    else {
      context.read<Sheet>().pageList.add('전체');
      context.read<Sheet>().chords.add([Chord()]);
      context.read<Sheet>().lyrics.add(['가사']);
      sheet.add([ChordCell(key: UniqueKey(), pageIndex: 0,)]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    songKey = context.watch<Sheet>().songKey;

    if (currentCell == null) context.read<Sheet>().selectedIndex = -1;
    else context.read<Sheet>().selectedIndex = sheet[context.read<Sheet>().nowPage].indexOf(currentCell!);

    return Scaffold(
      appBar: AppBar(
        title: Text(( (widget.sheetID == null) ? "새 악보 - " : "" ) + widget.title),
        actions: (!widget.readOnly) ? [
          IconButton(
            onPressed: () {
              createSheet();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.check),
          )
        ] : null,
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: global.CustomTabView(
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
            (!widget.readOnly) ? Row(
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
                    if (currentCell != null) {
                      setState(() {
                        context.read<Sheet>().newLine();
                        sheet[context.read<Sheet>().nowPage].insert(context.read<Sheet>().selectedIndex, Container(width: 1000, key: UniqueKey()));
                      });
                    }
                    else {throw Exception("currentCell is null");}
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
                    context.read<Sheet>().moveLyric();
                    //setState(() {
                      // TODO : 가사만 옆의 셀 또는 새로운 셀을 생성하여 옮기는 기능 구현.
                      if (context.read<Sheet>().isLastSelection()) {
                        sheet[context.read<Sheet>().nowPage].add(ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().nowPage, readOnly: widget.readOnly));
                        context.read<Sheet>().add(Chord());
                      }
                      String text = cellTextController!.text;
                      int start = cellTextController!.selection.end;

                      context.read<Sheet>().setLyric(context.read<Sheet>().selectedIndex + 1, cellTextController!.selection.textAfter(text));
                      cellTextController!.text = text.replaceRange(start, null, "");
                      cellTextController!.selection = cellTextController!.selection.copyWith(baseOffset: cellTextController!.text.length, extentOffset: cellTextController!.text.length);
                    //});
                  } : null,
                ),
              ],
            ) : Container(),
            isChordInput ? ChordKeyboard(onButtonTap: () {
              setState(() {
                if (cellTextController != null)
                  cellTextController!.text = context.read<Sheet>().chords[context.read<Sheet>().nowPage][context.read<Sheet>().selectedIndex]!.toStringChord(
                    songKey: context.read<Sheet>().songKey);
                else
                  throw Exception("cellTextController 가 null 이기 때문에 코드 키보드를 불러오지 못했습니다.");
              });
            }) : Container(),
          ],
        ),
      ),
      // TODO : 플로팅 버튼이 커스텀 키보드 가리는 문제 해결해야 함.
      floatingActionButton: (!widget.readOnly) ? FloatingActionButton(
        onPressed: () {
          var controller = TextEditingController();
          showDialog (
            context: context,
            builder: (context) => AlertDialog(
              title: Text("페이지 이름"),
              content: Form(
                key: _formKey,
                child: TextFormField(
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: "새 페이지 이름",
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
                  child: Text("OK"),
                ),
              ],
            ),
          ).then((pageTitle) {
            setState(() {
              context.read<Sheet>().pageList.add(pageTitle);
              context.read<Sheet>().chords.add([Chord()]);
              context.read<Sheet>().lyrics.add(["가사"]);
              List<ChordCell> list = [ChordCell(key: UniqueKey(), pageIndex: context.read<Sheet>().pageList.length-1,)];
              sheet.add(list);
              //_initPosition = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
            });
          });

        },
        child: Icon(Icons.add),
      ) : null,
    );
  }

  /*Chord getChordOf(ChordCell? cell) {
    if (cell == null) throw Exception("[f][getChordOf] 인자로 null 이 들어왔습니다.");
    int _index = sheet[nowPage].indexOf(currentCell!);
    if (_index == -1) throw Exception("[f][getChordOf] sheet 에서 cell 을 찾지 못했습니다.");
    if (chord[nowPage][_index] == null) throw Exception("[f][getChordOf] chord 가 없습니다.");
    return chord[nowPage][_index]!;
  }*/

  Future<http.Response> createSheet() async {
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
      'song_name': widget.title,
      'singer': widget.singer,
      'song_key': songKey,
      'sheet' : _sheet,
    };

    final response = await http.post(
        Uri.parse('http://193.122.123.213/sheet_insert.php'),
        headers: <String, String>{
          'Content-type': 'application/x-www-form-urlencoded',
        },
        body: <String, String>{
          "data" : jsonEncode(_body),
        });

    if (response.statusCode == 200) {
      // TODO : 악보 저장 성공시 기능 있으면 구현.
    }
    else {
      throw Exception("failed to save data");
    }

    print(response.body);

    return response;
  }

  Future<http.Response> getSheet() async {
    final response = await http.post(
        Uri.parse('http://193.122.123.213/chordEverdu/get_sheet.php'),
        headers: <String, String>{
          'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: <String, String>{
          'sheet_id': widget.sheetID!,
        });

    if (response.statusCode == 200) {
      final result = utf8.decode(response.bodyBytes);
      List<dynamic> json = jsonDecode(result)["qry_result"];
      String _nowPage = "";
      int _pageIndex = -1;
      for (int i = 0; i < json.length; i++) {
        String page = json[i]["page"];
        if (page != _nowPage) {
          sheet.add([]);
          context.read<Sheet>().lyrics.add([]);
          context.read<Sheet>().chords.add([]);
          context.read<Sheet>().pageList.add(page);
          _nowPage = page;
          _pageIndex += 1;
        }

        if (json[i]["lyric"] == "<!br!>") {
          sheet[_pageIndex].add(Container(width: 1000));
          context.read<Sheet>().lyrics[_pageIndex].add(null);
          context.read<Sheet>().chords[_pageIndex].add(null);
          continue;
        }

        context.read<Sheet>().lyrics[_pageIndex].add(json[i]["lyric"]);
        context.read<Sheet>().chords[_pageIndex].add(Chord(
          root: int.parse(json[i]["root"]),
          rootSharp: int.parse(json[i]["root_s"]),
          rootTension: int.parse(json[i]["root_t"]),
          minor: json[i]["minor"],
          minorTension: int.parse(json[i]["minor_t"]),
          major: json[i]["major"],
          majorTension: int.parse(json[i]["major_t"]),
          tensionSharp: int.parse(json[i]["t_sharp"]),
          tension: int.parse(json[i]["tension"]),
          asda: json[i]["asda"],
          asdaTension: int.parse(json[i]["asda_t"]),
          base: int.parse(json[i]["base"]),
          baseSharp: int.parse(json[i]["base_s"]),
        ));

        sheet[_pageIndex].add(ChordCell(
          key: UniqueKey(),
          pageIndex: _pageIndex,
          readOnly: widget.readOnly,
        ));
      }
      setState(() {});
    } else {
      throw Exception("[f][getSheet()] failed to get data");
    }

    return response;
  }
}