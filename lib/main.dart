import 'package:flutter/material.dart';
import 'package:chord_everdu/page/search_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: MainFrame(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("그룹"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "악보검색",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "그룹",
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.my_library_music),
              label: "내 악보"
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (idx) => {setState(() {_selectedIndex = idx;})},
      ),
      body: const SearchSheet(),
    );
  }
}
