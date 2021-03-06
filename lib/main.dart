import 'package:chord_everdu/custom_widget/group/new_group_floating_button.dart';
import 'package:chord_everdu/page/search_sheet.dart';
import 'package:chord_everdu/page/my_sheet.dart';
import 'package:chord_everdu/page/group.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/custom_widget/search_sheet/new_sheet_floating_button.dart';
import 'package:chord_everdu/custom_widget/search_sheet/search_sheet_delegate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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

  List<Widget> _bodyWidgets = [
    SearchSheet(),
    Group(),
    MySheet(),
  ];

  List<PreferredSizeWidget> _appBarWidgets = [
    AppBar(
      title: Builder(
        builder: (context) {
          return GestureDetector(
            onTap: () {
              showSearch(context: context, delegate: MySearchDelegate())
                  .toString(); // MySearchDelegate is declared in page_searchSheet.dart
            },
            child: Container(
              padding: EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(Icons.search, color: Colors.white70,),
                  SizedBox(width: 12),
                  Text("????????? ???????????????.", style: TextStyle(color: Colors.white60, fontSize: 18)),
                ],
              ),
            ),
          );
        }
      ),
      centerTitle: true,
    ),
    AppBar(
      title: Text("??????"),
    ),
    AppBar(
      title: Text("??? ??????"),
    ),
  ];

  List<Widget?> _floatingButtonWidgets = [
    SearchSheetFloatingButton(),
    NewGroupFloatingButton(),
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
            label: "????????????",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "??????",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_library_music), label: "??? ??????"),
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

            else if (snapshot.connectionState == ConnectionState.none)
              return Text("No data");

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
