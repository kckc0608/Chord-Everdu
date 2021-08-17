import 'package:chord_everdu/custom_widget/common/sheet_list_item.dart';
import 'package:flutter/material.dart';
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
    return SheetListItem(
      sheetID: doc.id,
      title: sheet.title,
      singer: sheet.singer,
      songKey: sheet.songKey,
    );
  }
}