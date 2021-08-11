import 'package:flutter/material.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:chord_everdu/custom_class/sheet_info.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({Key? key}) : super(key: key);

  @override
  _SearchSheetState createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sheet_list').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();
        final documents = snapshot.data!.docs;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView.separated(
            itemBuilder: (context, index) {
              return _buildItemWidget(documents[index]);
            },
            separatorBuilder: (context, index) {
              return const Divider(height: 4.0, thickness: 1.0);
            },
            itemCount: snapshot.data!.size
          ),
        );
      },
    );
  }

  Widget _buildItemWidget(doc) {
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
      onLongPress: () {
        print("long Press Event");
        showDialog(context: context, builder: (context) {
          return SimpleDialog(
            children: [
              TextButton(child: Text("악보 삭제"), onPressed: () {
                Navigator.of(context).pop();
              }),
            ],
          );
        });
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
  }
}