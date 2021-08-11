import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chord_everdu/custom_class/sheet_info.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
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

  /// 시스템 키보드의 검색 버튼을 눌렀을 때, 검색 결과 리스트
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

  /// 쿼리가 바뀔 때마다 호출되는 검색 결과 제안 리스트 생성
  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return Center(child: Text("검색어를 입력하세요."));

    var _db = FirebaseFirestore.instance;
    return StreamBuilder<QuerySnapshot>(
      stream: _db.collection('sheet_list').orderBy('title').startAt([query]).endAt([query + '\uf8ff']).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null)
          return Center(child: Text("검색 결과가 없습니다."));

        final docs = snapshot.data!.docs;
        if (docs.length > 0)
          return ListView.separated(
            itemBuilder: (context, index) {
              if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

              var doc = docs[index];
              final sheet = SheetInfo(
                title:   doc['title'],
                songKey: doc['song_key'],
                singer:  doc['singer'],
              );

              return InkWell(
                onTap: () {
                  print("onTap event");
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        return SheetEditor(
                          sheetID: doc.id,
                          title:   sheet.title,
                          singer:  sheet.singer,
                          songKey: sheet.songKey,
                          readOnly: true,
                        );
                      })
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(sheet.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text(sheet.singer, style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return const Divider();
            },
            itemCount: docs.length,
          );
        else
          return Center(child: Text("검색 결과가 없습니다."));
      },
    );
  }
}