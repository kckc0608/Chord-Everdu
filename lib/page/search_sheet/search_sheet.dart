import 'package:chord_everdu/page/search_sheet/widget/sheet_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({Key? key}) : super(key: key);

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  Stream<QuerySnapshot<Map<String, dynamic>>> getSheetList() {
    return FirebaseFirestore.instance.collection('sheet_list').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: StreamBuilder(
        stream: getSheetList(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var sheetsData = snapshot.data!.docs;
            return ListView.separated(
                itemCount: sheetsData.length,
                itemBuilder: (context, idx) => SheetListItem(
                  sheetID: sheetsData[idx].id,
                  title: sheetsData[idx].data()["title"],
                  singer: sheetsData[idx].data()["singer"],
                ),
                separatorBuilder: (context, idx) {
                  return const Divider(
                    height: 4.0,
                    thickness: 1.0,
                  );
                },
            );
          } else {
            return const Text("loading"); /// TODO : 원형 진행 바로 수정
          }
        },
      ),
    );
  }
}
