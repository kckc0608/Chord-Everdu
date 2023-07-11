import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/delegate/sheet_search_delegate.dart';
import 'package:chord_everdu/page/group/group.dart';
import 'package:chord_everdu/page/my_page/my_page.dart';
import 'package:chord_everdu/page/search_sheet/widget/new_sheet_dialog.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/page/search_sheet/search_sheet.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'environment/firebase_options.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => Sheet()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chord Everdu',
      theme: ThemeData(
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          titleSmall: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        )
      ),
      home: const MainFrame(),
    );
  }
}

class MainFrame extends StatefulWidget {
  const MainFrame({Key? key}) : super(key: key);

  @override
  State<MainFrame> createState() => _MainFrameState();
}

class _MainFrameState extends State<MainFrame> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) =>
      (snapshot.hasData) ? Scaffold(
        appBar: [
          AppBar(
            title: Builder(builder: (context) {
              return GestureDetector(
                onTap: () {
                  showSearch(context: context, delegate: SheetSearchDelegate());
                },
                child: Container(
                  padding: const EdgeInsets.all(6.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                      SizedBox(width: 12),
                      Text("악보를 검색하세요.",
                          style:
                          TextStyle(color: Colors.white60, fontSize: 18)),
                    ],
                  ),
                ),
              );
            }),
            centerTitle: true,
          ),
          AppBar(title: const Text("그룹")),
          AppBar(title: const Text("내 정보"))
        ][_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: "악보 검색",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: "그룹",
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.my_library_music), label: "내 악보"),
          ],
          currentIndex: _selectedIndex,
          onTap: (idx) {
            setState(() {
              _selectedIndex = idx;
            });
          },
        ),
        body: const [SearchSheet(), Group(), MyPage()][_selectedIndex],
        floatingActionButton: [
          FloatingActionButton(
            onPressed: () {
              showDialog(
                  context: context, builder: (_) => const NewSheetDialog());
            },
            child: const Icon(Icons.add),
          ),
          null,
          null
        ][_selectedIndex],
      )
      : const Text("loading firebase"),
    );
  }
}
