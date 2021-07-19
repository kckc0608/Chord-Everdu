import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chord_everdu/page_NewSheet.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({Key? key}) : super(key: key);

  @override
  _SearchSheetState createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  late Future<List<Sheet>> futureSheet;
  var _maxItem;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _maxItem == null ? 0 : _maxItem * 2,
      itemBuilder: (context, index) {
        if (index.isOdd) {
          return const Divider();
        }
        return _getSheet(index);
      },
    );
  }

  Widget _getSheet(index) {
    return FutureBuilder<List<Sheet>>(
        future: futureSheet,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final item = snapshot.data![index ~/ 2];

            return ListTile(
              title: Text(item.title),
              subtitle: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(item.singer == null ? "없음" : item.singer.toString()),
                ],
              ),
              onTap: () {
                print("on Tap from page search Sheet. dart line 49");
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return SheetEditor(
                        sheetID: item.sheetId,
                        title: item.title,
                        singer: item.singer.toString(),
                        songKey: 0,
                      );
                    })
                );
              },
            );
          } else if (snapshot.hasError) {
            print("${snapshot.error}");
          }
          return ListTile(
            title: Center(child: CircularProgressIndicator()),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    futureSheet = fetchSheet();
  }

  Future<List<Sheet>> fetchSheet() async {
    List<Sheet> list = [];
    final response =
    await http.get(Uri.parse('http://193.122.123.213/SheetSelect.php'));

    if (response.statusCode == 200) {
      final result = utf8.decode(response.bodyBytes);
      List<dynamic> json = jsonDecode(result)['qry_result'];
      _maxItem = json.length;

      for (int i = 0; i < json.length; i++) {
        list.add(Sheet.fromJson(json[i]));
      }
      setState(() {});
      return list;
    } else {
      throw Exception('Failed to load sheet');
    }
  }
}

class Sheet {
  //final int userID;
  final String sheetId;
  final String title;
  String? singer;

  Sheet({
    required this.sheetId,
    required this.title,
    this.singer,
  });

  factory Sheet.fromJson(Map<String, dynamic> json) {
    return Sheet(
      sheetId: json['sheet_id'],
      title: json['song_name'],
      singer: json['singer'],
    );
  }
}

// Search Function
class MySearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => "악보를 검색하세요.";

  // 앱바의 'actions' 란에 위치하는 것과 동일한 위치에 배치할 버튼들
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  // AppBar의 leading에 배치할 것과 같은 위치에 배치할 것
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text("item1"),
        ),
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text("item1"),
          onTap: () {
            query = "item1";
            showResults(context);
          },
        ),
        ListTile(
          title: Text("item2"),
        ),
        ListTile(
          title: Text("item3"),
        ),
      ],
    );
  }
}

// Floating Button
class SearchSheetFloatingButton extends StatelessWidget {
  const SearchSheetFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return NewSheetDialog();
          },
        );
      },
    );
  }
}

// Dialog For New Sheet
class NewSheetDialog extends StatefulWidget {
  const NewSheetDialog({Key? key}) : super(key: key);

  @override
  _NewSheetDialogState createState() => _NewSheetDialogState();
}

class _NewSheetDialogState extends State<NewSheetDialog> {

  var _keyList = ["C", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B"];
  var _selectedKey = 0;

  var _controllerForTitle = TextEditingController();
  var _controllerForSinger = TextEditingController();
  var _focusNodeForTitle = FocusNode();
  var _focusNodeForSinger = FocusNode();

  final _formKey = GlobalKey<FormState>();


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
      title: Text("새 악보"),
      content: SizedBox(
        width: 290,
        height: 230,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _controllerForTitle,
                    focusNode: _focusNodeForTitle,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "곡 제목은 필수 입력값입니다.";
                      }
                      return null;
                    },
                    style: TextStyle(fontSize: 20),
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
                  SizedBox(height: 12),
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
                  SizedBox(height: 24),
                  DropdownButtonFormField(
                    style: TextStyle(fontSize: 20, color: Colors.black),
                    decoration: InputDecoration(
                      labelText: "키",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.fromLTRB(12, 12, 12, 8),
                      isCollapsed: true,
                    ),
                    value: _selectedKey,
                    items: _keyList.map((value) {
                      return DropdownMenuItem(
                        value: _keyList.indexOf(value),
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
              Navigator.of(context).pop("OK");
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) {
                    return SheetEditor(
                      title: _controllerForTitle.text,
                      singer: _controllerForSinger.text,
                      songKey: _selectedKey,
                    );
                  })
              );
            }
          },
        ),
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop("Cancel");
          },
        ),
      ],
    );
  }
}
