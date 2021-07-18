import 'package:chord_everdu/chord_input_keyboard.dart';
import 'package:chord_everdu/custom_data_structure.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chord_everdu/chord_cell.dart';
import 'global.dart' as global;

class NewSheet extends StatefulWidget {
  final String title;
  final String singer;
  final int songKey;

  const NewSheet(
      {Key? key,
      required this.title,
      required this.singer,
      required this.songKey})
      : super(key: key);

  @override
  NewSheetState createState() => NewSheetState();
}

class NewSheetState extends State<NewSheet> {

  int songKey = 0;

  List<String> data = ['전체', 'page1',];

  List<List<Widget>> sheet = [
    [ChordCell(key: UniqueKey(), lyric: "가사테스트",),ChordCell(key: UniqueKey(), ), ChordCell(key: UniqueKey(), ), ChordCell(key: UniqueKey(), ),],
    [ChordCell(key: UniqueKey(), lyric: "가사테스트",), ChordCell(key: UniqueKey(), )],
  ];

  var _formKey = GlobalKey<FormState>(); // 새 탭 추가시 띄우는 다이어로그의 폼 키
  int _initPosition = 0;

  ChordCell? currentCell;
  TextEditingController? cellTextController;
  Chord? currentChord;

  bool isChordInput = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    songKey = widget.songKey;

    return Scaffold(
      appBar: AppBar(
        title: Text("새 악보 - " + widget.title),
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
          initPosition: _initPosition,
          itemCount: data.length,
          tabBuilder: (context, index) => Tab(text: data[index]),
          pageBuilder: (context, index) {
            print("Builder called $index");
            List<Widget> pageSheet = sheet[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(
                children: pageSheet,
              ),
            );
          },
          onPositionChange: (index) {
            print('current position: $index');
            _initPosition = index;
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
              data.add(pageTitle);
              List<ChordCell> list = [ChordCell(key: UniqueKey(), lyric: "가사")];
              sheet.add(list);
              //_initPosition = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
            });
          });

        },
        child: Icon(Icons.add),
      ),
      bottomSheet: (currentCell == null) ? null : Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TextButton(
                child: Text("코드 추가"),
                onPressed: () {
                  if (currentCell != null) {
                    String _lyric = "가사";
                    int selectedIndex = sheet[_initPosition].indexOf(currentCell!);
                    sheet[_initPosition].insert(selectedIndex+1, ChordCell(key: UniqueKey(),lyric: _lyric));
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
                      sheet[_initPosition].remove(currentCell);
                    });
                  }
                },
              ),
              TextButton(
                onPressed: () {
                  // 현재 선택한 코드셀 이후의 셀들을 다음 줄로 넘김
                  if (currentCell != null) {
                    int selectedIndex = sheet[_initPosition].indexOf(currentCell!);
                    if (!(sheet[_initPosition][selectedIndex+1] is Container)) {
                      sheet[_initPosition].insert(selectedIndex+1, Container(width: 1000, key: UniqueKey()));
                      setState(() {});
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
                    int selectedIndex = sheet[_initPosition].indexOf(currentCell!);
                    if (sheet[_initPosition][selectedIndex-1] is Container ) {
                      sheet[_initPosition].removeAt(selectedIndex-1);
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
              String chord = "";
              if (currentChord!.root > -1) {
                int rootKey = (currentChord!.root + currentChord!.rootSharp + 12)%12;
                if (rootKey == 1 || rootKey == 3 || rootKey == 6 || rootKey == 8 || rootKey == 10) {
                  if (currentChord!.rootSharp == 1)
                    chord += global.keyList[rootKey][0];
                  else if (currentChord!.rootSharp == -1)
                    chord += global.keyList[rootKey][1];
                }
                else {
                  chord += global.keyList[rootKey];
                }

                if (currentChord!.rootTension > -1)
                  chord += global.tensionList[currentChord!.rootTension];

                chord += currentChord!.minor;
                if (currentChord!.minorTension > -1)
                  chord += global.tensionList[currentChord!.minorTension];

                chord += currentChord!.major;
                if (currentChord!.majorTension > -1)
                  chord += global.tensionList[currentChord!.majorTension];

                if (currentChord!.tensionSharp == 1)
                  chord += '#';
                else if (currentChord!.tensionSharp == -1)
                  chord += "b";

                if (currentChord!.tension > -1)
                  chord += global.tensionList[currentChord!.tension];

                chord += currentChord!.asda;
                if (currentChord!.asdaTension > -1)
                  chord += global.tensionList[currentChord!.asdaTension];
              }

              if (currentChord!.base > -1) {
                chord += "/";
                int baseKey = (currentChord!.base + currentChord!.baseSharp + 12)%12;
                if (baseKey == 1 || baseKey == 3 || baseKey == 6 || baseKey == 8 || baseKey == 10) {
                  if (currentChord!.baseSharp == 1)
                    chord += global.keyList[baseKey][0];
                  else if (currentChord!.baseSharp == -1)
                    chord += global.keyList[baseKey][1];
                }
                else {
                  chord += global.keyList[baseKey];
                }
              }
              cellTextController!.text = chord;
            });
          }) : Container(),
        ],
      ),
    );
  }

  Future<http.Response> createSheet() async {
    print(widget.title + ", " + widget.singer);
    final response = await http.post(
        Uri.parse('http://193.122.123.213/sheet_insert.php'),
        headers: <String, String>{
          'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: <String, String>{
          'song_name': widget.title,
          'singer': widget.singer,
          'song_key': songKey.toString(),
        });

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      throw Exception("failed to save data");
    }

    return response;
  }
}