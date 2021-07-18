import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chord_everdu/chord_cell.dart';
import 'global.dart' as global;

class SheetViewer extends StatefulWidget {
  final String sheetID;
  final String title;
  final String singer;
  final int songKey;

  const SheetViewer(
      {Key? key,
        required this.sheetID,
        required this.title,
        required this.singer,
        required this.songKey})
      : super(key: key);

  @override
  SheetViewerState createState() => SheetViewerState();
}

class SheetViewerState extends State<SheetViewer> {

  int songKey = 0;

  List<String> data = ['전체',];
  List<List<Widget>> sheet = [[],];
  int _initPosition = 0;
  ChordCell? currentCell;

  @override
  void initState() {
    super.initState();
    getSheet();
  }

  @override
  Widget build(BuildContext context) {
    songKey = widget.songKey;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: global.CustomTabView(
          initPosition: _initPosition,
          itemCount: data.length,
          tabBuilder: (context, index) => Tab(text: data[index]),
          pageBuilder: (context, index) {
            print("page builder called $index");
            List<Widget> page = sheet[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Wrap(children: page),
            );
          },
          onPositionChange: (index) {
            print('current position: $index');
            _initPosition = index;
          },
          onScroll: (position) => print('$position'),
        ),
      ),
      bottomSheet: Row(
        children: [
          TextButton(
            child: Text("코드 추가"),
            onPressed: () {}
          ),
          TextButton(
            child: Text("코드 삭제"),
            onPressed: () {},
          ),
          TextButton(
            onPressed: () {},
            child: Text("줄넘김"),
          ),
          TextButton(
            onPressed: () {},
            child: Text("줄넘김 취소"),
          ),
        ],
      ),
    );
  }

  Future<http.Response> getSheet() async {
    final response = await http.post(
        Uri.parse('http://193.122.123.213/chordEverdu/get_sheet.php'),
        headers: <String, String>{
          'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
        body: <String, String>{
          'sheet_id': widget.sheetID,
        });

    //setState(() {});
    print(response.statusCode);
    if (response.statusCode == 200) {
      final result = utf8.decode(response.bodyBytes);
      print(result);
      List<dynamic> json = jsonDecode(result)["qry_result"];
      String now_page = "";
      for (int i = 0; i < json.length; i++) {
        String page = json[i]["page"];
        if (page != now_page) {
          sheet.add([]);
          data.add(page);
          now_page = page;
        }
        //int chord_id = json[i]["chord_id"]; // select 할 때 오름차순으로 고르면 이건 의미 없음. 저장할 때 의미있는 컬럼이다.
        String? lyric = json[i]["lyric"];
        var cell = ChordCell(
          key: UniqueKey(),
          pageIndex: 0, // TODO : 수정
          readOnly: true,
        );
        sheet[data.length-1].add(cell);
        //int root = json[i]["root"];
        setState(() {});
      }

    } else {
      throw Exception("failed to save data");
    }

    return response;
  }
}