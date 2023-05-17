import 'package:chord_everdu/widget/sheet_list_item.dart';
import 'package:flutter/material.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({Key? key}) : super(key: key);

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.separated(
          itemBuilder: (context, idx) {
            return SheetListItem(sheetID: idx.toString(), title: "take my hand", singer: "IU",);
          },
          separatorBuilder: (context, idx) {
            return const Divider(
              height: 4.0,
              thickness: 1.0,
            );
          },
          itemCount: 100),
    );
  }
}
