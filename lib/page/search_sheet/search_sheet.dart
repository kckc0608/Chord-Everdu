import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/page/common_widget/loading_circle.dart';
import 'package:chord_everdu/page/search_sheet/widget/sheet_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  bool isFavoriteSheet(String sheetID, List<dynamic> favoriteSheets) {
    for (dynamic favoriteSheet in favoriteSheets) {
      if (favoriteSheet["sheet_id"] == sheetID) {
        return true;
      }
    }
    return false;
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
            return StreamBuilder(
              stream: FirebaseAuth.instance.currentUser != null
                  ? FirebaseFirestore.instance.collection('user_list')
                  .doc(FirebaseAuth.instance.currentUser!.email).snapshots()
                : null,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingCircle();
                }

                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }

                List<dynamic> favoriteSheets = [];
                if (snapshot.hasData) {
                  favoriteSheets = snapshot.data!.data()!["favorite_sheet"];
                }

                return ListView.separated(
                  itemCount: sheetsData.length,
                  itemBuilder: (context, idx) => SheetListItem(
                    sheetID: sheetsData[idx].id,
                    sheetInfo: SheetInfo.fromMap(sheetsData[idx].data()),
                    isFavorite: isFavoriteSheet(sheetsData[idx].id, favoriteSheets),
                  ),
                  separatorBuilder: (context, idx) {
                    return const Divider(
                      height: 4.0,
                      thickness: 1.0,
                    );
                  },
                );
              }
            );
          } else {
            return const LoadingCircle();
          }
        },
      ),
    );
  }
}
