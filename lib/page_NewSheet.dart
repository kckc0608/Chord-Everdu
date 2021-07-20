import 'package:chord_everdu/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_data_structure.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chord_everdu/chord_cell.dart';
import 'global.dart' as global;
import 'dart:convert';

class SheetEditor extends StatefulWidget {
  final String? sheetID;
  final String title;
  final String singer;
  final int songKey;

  const SheetEditor(
      {Key? key,
      required this.title,
      required this.singer,
      required this.songKey,
      this.sheetID})
      : super(key: key);

  @override
  SheetEditorState createState() => SheetEditorState();
}

class SheetEditorState extends State<SheetEditor> {

  int songKey = 0;

  List<String> pageList = [];
  List<List<Widget>> sheet = [];
  List<List<Chord?>> chord = [];
  List<List<String?>> lyric = [];

  var _formKey = GlobalKey<FormState>(); // 새 탭 추가시 띄우는 다이어로그의 폼 키
  int nowPage = 0;

  ChordCell? currentCell;
  TextEditingController? cellTextController;

  bool isChordInput = false;

  @override
  void initState() {
    if (widget.sheetID != null){
      getSheet();
    }
    else {
      pageList.add('전체');
      chord.add([Chord()]);
      lyric.add(['가사']);
      sheet.add([ChordCell(key: UniqueKey(), pageIndex: 0,)]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    songKey = widget.songKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(( (widget.sheetID == null) ? "새 악보 - " : "" ) + widget.title),
        actions: [
          IconButton(
            onPressed: () {
              createSheet();
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.check),
          )
        ],
      ),
      body: SafeArea(
        child: global.CustomTabView(
          initPosition: nowPage,
          itemCount: pageList.length,
          tabBuilder: (context, index) => Tab(text: pageList[index]),
          pageBuilder: (context, index) {
            print("Builder called $index");
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
            nowPage = index;
          },
          onScroll: (position) => print('$position'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
              pageList.add(pageTitle);
              List<ChordCell> list = [ChordCell(key: UniqueKey(), pageIndex: pageList.length-1,)];
              sheet.add(list);
              //_initPosition = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
            });
          });

        },
        child: Icon(Icons.add),
      ),
      bottomSheet: (currentCell == null) ? null : Column( // TODO : 바텀 시트를 사용하면, 코드셀이 쌓일 경우 뒤에 묻히는 문제 발생.
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                child: Text("코드 추가"),
                onPressed: () {
                  if (currentCell != null) {
                    int selectedIndex = sheet[nowPage].indexOf(currentCell!);
                    if (selectedIndex == -1) throw Exception("선택한 셀을 시트에서 찾을 수 없습니다.");
                    sheet[nowPage].insert(selectedIndex+1, ChordCell(key: UniqueKey(), pageIndex: nowPage,));
                    chord[nowPage].insert(selectedIndex+1, Chord());
                    lyric[nowPage].insert(selectedIndex+1, "가사");
                  }
                  else {
                    print("Line 147 in page_NewSheet.dart, currentCell is null");
                  }
                  setState(() {});
                },
              ),
              TextButton(
                child: Text("코드 삭제"),
                onPressed: () {
                  // 현재 선택한 코드 셀 삭제
                  if (currentCell != null) {
                    setState(() {
                      int selectedIndex = sheet[nowPage].indexOf(currentCell!);
                      sheet[nowPage].removeAt(selectedIndex);
                      chord[nowPage].removeAt(selectedIndex);
                      lyric[nowPage].removeAt(selectedIndex);
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  // 현재 선택한 코드셀 이후의 셀들을 다음 줄로 넘김
                  if (currentCell != null) {
                    int selectedIndex = sheet[nowPage].indexOf(currentCell!);
                    if (!(sheet[nowPage][selectedIndex+1] is Container)) {
                      setState(() {
                        sheet[nowPage].insert(selectedIndex+1, Container(width: 1000, key: UniqueKey()));
                        chord[nowPage].insert(selectedIndex+1, null);
                        lyric[nowPage].insert(selectedIndex+1, null);
                      });
                    }
                  }
                  else {
                    print("Line 173 in page_NewSheet.dart, currentCell is null");
                  }
                },
                child: Text("줄넘김"),
              ),
              TextButton(
                onPressed: () {
                  if (currentCell != null) {
                    int selectedIndex = sheet[nowPage].indexOf(currentCell!);
                    if (sheet[nowPage][selectedIndex-1] is Container ) {
                      sheet[nowPage].removeAt(selectedIndex-1);
                      chord[nowPage].removeAt(selectedIndex-1);
                      lyric[nowPage].removeAt(selectedIndex-1);
                      setState(() {});
                    }
                  }
                  else {
                    print("Line 190 in page_NewSheet.dart, currentCell is null");
                  }
                },
                child: Text("줄넘김 취소"),
              ),
            ],
          ),
          isChordInput ? ChordKeyboard(onButtonTap: () {
            setState(() {
              if (cellTextController != null) cellTextController!.text = getChordOf(currentCell).toString();
              else throw Exception("cellTextController 가 null 이기 때문에 코드 키보드를 불러오지 못했습니다.");
            });
          }) : Container(),
        ],
      ),
    );
  }

  Chord getChordOf(ChordCell? cell) {
    if (cell == null) throw Exception("[f][getChordOf] 인자로 null 이 들어왔습니다.");
    int _index = sheet[nowPage].indexOf(currentCell!);
    if (_index == -1) throw Exception("[f][getChordOf] sheet 에서 cell 을 찾지 못했습니다.");
    if (chord[nowPage][_index] == null) throw Exception("[f][getChordOf] chord 가 없습니다.");
    return chord[nowPage][_index]!;
  }

  Future<http.Response> createSheet() async {
    List<dynamic> _sheet = [];
    for (int i = 0; i < pageList.length; i++) {
      Map<String, dynamic> _page = {};
      _page["page"] = pageList[i];
      List<dynamic> _chordList = [];
      for (int j = 0; j < chord[i].length; j++) {
        if (chord[i][j] == null) _chordList.add(null);
        else _chordList.add({
          "chord" : chord[i][j]!.toJson(),
          "lyric" : lyric[i][j]!,
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
    } else {
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
      final result = utf8.decode(response.bodyBytes); print(result);
      List<dynamic> json = jsonDecode(result)["qry_result"];
      String _nowPage = "";
      int _pageIndex = -1;
      for (int i = 0; i < json.length; i++) {
        String page = json[i]["page"];
        if (page != _nowPage) {
          sheet.add([]); lyric.add([]); chord.add([]);
          pageList.add(page);
          _nowPage = page;
          _pageIndex += 1;
        }
        lyric[_pageIndex].add(json[i]["lyric"]);

        chord[_pageIndex].add(Chord(
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
          readOnly: true,
        ));

        setState(() {});
      }

    } else {
      throw Exception("failed to save data");
    }

    return response;
  }


}