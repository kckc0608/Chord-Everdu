import 'package:flutter/material.dart';
import 'package:chord_everdu/page_searchSheet.dart';
import 'package:provider/provider.dart';
import 'package:chord_everdu/sheet.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Sheet()),
      ],
      child: ChordEverdu(),
    ),
  );
}

class ChordEverdu extends StatelessWidget {
  const ChordEverdu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "ChordEverdu", home: MainFrame());
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  _MainFrameState createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  var _selectedIndex = 0;

  //var _searchResult = '';

  List<Widget> _bodyWidgets = [
    SearchSheet(),
    Text("1"),
    Text("2"),
  ];

  List<PreferredSizeWidget> _appBarWidgets = [
    AppBar(
      title: Text("악보 검색"),
      actions: [
        Builder(builder: (context) {
          return IconButton(
            onPressed: () {
              showSearch(context: context, delegate: MySearchDelegate())
                  .toString(); // MySearchDelegate is declared in page_searchSheet.dart
            },
            icon: Icon(Icons.search),
          );
        })
      ],
    ),
    AppBar(
      title: Text("그룹"),
    ),
    AppBar(
      title: Text("내 악보"),
    ),
  ];

  List<Widget?> _floatingButtonWidgets = [
    SearchSheetFloatingButton(), // page_searchSheet.dart
    null,
    null,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidgets[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "악보검색",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "그룹",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_library_music), label: "내 악보"),
        ],
        currentIndex: _selectedIndex,
        onTap: onTapBottomNavigationItem,
      ),
      body: Center(
        child: FutureBuilder(
          future: Firebase.initializeApp(),
          builder: (context, snapshot) {
            if (snapshot.hasError)
              return Text("firebase load fail");

            if (snapshot.connectionState == ConnectionState.done)
              return _bodyWidgets.elementAt(_selectedIndex);

            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: _floatingButtonWidgets[_selectedIndex],
    );
  }

  void onTapBottomNavigationItem(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
