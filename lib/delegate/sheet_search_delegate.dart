import 'package:chord_everdu/page/search_sheet/widget/sheet_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class SheetSearchDelegate extends SearchDelegate {
  @override
  String? get searchFieldLabel => "악보를 검색하세요.";

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Colors.white60
        )
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
      )
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('sheet_list').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          var docs = snapshot.data!.docs;
          List<QueryDocumentSnapshot<Map<String, dynamic>>> results = docs.where((doc) {
            var data = doc.data();
            String title = data["title"];
            return (title.contains(query));
          },).toList();
          Logger().d(results);
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              var data = results[index].data();
              return SheetListItem(
                sheetID: results[index].id,
                title: data["title"],
                singer: data["singer"],
              );
            },
          );
        }
      });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) return const Center(child: Text("검색어를 입력하세요."));
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('sheet_list').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          var docs = snapshot.data!.docs;
          List<QueryDocumentSnapshot<Map<String, dynamic>>> results = docs.where((doc) {
            var data = doc.data();
            String title = data["title"];
            return (title.contains(query));
          },).toList();
          Logger().d(results);
          return ListView.separated(
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              var data = results[index].data();
              return SheetListItem(
                sheetID: results[index].id,
                title: data["title"],
                singer: data["singer"],
              );
            },
          );
        }
      });
  }
}
