import 'package:flutter/material.dart';
import 'package:chord_everdu/custom_class/chord.dart';
import 'package:chord_everdu/custom_widget/chord_cell.dart';
class Sheet with ChangeNotifier {
  int songKey = 0;
  int nowPage = 0;
  int selectedIndex = -1;

  List<String> pageList = [];
  List<List<Widget>> pages = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  void addCell({Chord? chord, String? lyric, int? index}) {
    index = index ?? selectedIndex + 1;

    if (index > chords[nowPage].length || index < 0)
      throw Exception("[sheet.dart][addCell] 인덱스 범위를 벗어났습니다. index : " + index.toString());

    chords[nowPage].insert(index, chord ?? Chord());
    lyrics[nowPage].insert(index, lyric ?? "");
    pages[nowPage].insert(index, ChordCell(key: UniqueKey(), pageIndex: nowPage));
    notifyListeners();
  }

  void remove({int? index}) {
    index = index ?? selectedIndex;

    if (index >= chords[nowPage].length || index < 0)
      throw Exception("[sheet.dart][addCell] 인덱스 범위를 벗어났습니다. index : " + index.toString());

    pages[nowPage].removeAt(selectedIndex);
    chords[nowPage].removeAt(selectedIndex);
    lyrics[nowPage].removeAt(selectedIndex);
    notifyListeners();
  }

  void newLine() {
    if (selectedIndex == 0) return;
    if (chords[nowPage][selectedIndex - 1] == null) return;

    chords[nowPage].insert(selectedIndex, null);
    lyrics[nowPage].insert(selectedIndex, null);
    pages[nowPage].insert(selectedIndex, Container(key: UniqueKey(), width: 1000));
    notifyListeners();
  }

  void removeBefore() {
    if (selectedIndex == 0) return;

    chords[nowPage].removeAt(selectedIndex-1);
    lyrics[nowPage].removeAt(selectedIndex-1);
    pages[nowPage].removeAt(selectedIndex-1);
    notifyListeners();
  }

  void moveLyric() {
    if (selectedIndex == chords[nowPage].length -1) {
      chords[nowPage].add(Chord());
      lyrics[nowPage].add("");
    }
  }

  void addPage(String pageName) {
    pageList.add(pageName);
    chords.add([Chord()]);
    lyrics.add(["가사"]);
    pages.add([ChordCell(key: UniqueKey(), pageIndex: pageList.length-1)]);
    //nowPage = sheet.length-1; // 탭만 바뀌고 탭뷰가 안바뀌는 문제 존재
    notifyListeners();
  }

  void allClear() {
    songKey = 0;
    pageList = [];
    chords = [];
    lyrics = [];
    pages = [];
    nowPage = 0;
    selectedIndex = -1;
  }

  bool isLastSelection() => (selectedIndex == lyrics[nowPage].length-1);

  void setLyric(int index, String newLyric) {
    if (index == -1) throw Exception("selected index == -1");
    if (index > lyrics[nowPage].length - 1) throw Exception("selected index is bigger than lyric list max index.");
    lyrics[nowPage][index] = newLyric;
  }

  String? getLyric({required int index}) {
    if (index <= -1) throw Exception("현재 선택한 셀이 없습니다.");
    if (index >= lyrics[nowPage].length) throw Exception("셀 범위를 벗어났습니다.");
    return lyrics[nowPage][index];
  }

  void setChord(int index, Chord newChord) {
    if (index == -1) throw Exception("selected index == -1");
    if (index > lyrics[nowPage].length - 1) throw Exception("selected index is bigger than lyric list max index.");
    chords[nowPage][index] = newChord;
    notifyListeners();
  }

  void getChord() {

  }

  int getIndexOfCell(ChordCell? cell) {
    if (cell == null) {
      print("[sheet.dart][getIndexOfCell] cell 이 null 입니다.");
      return selectedIndex = -1;
    }
    return pages[nowPage].indexOf(cell);
  }

  void setStateOfSheet () {
    print("notify");
    notifyListeners();
  }

  void changePageName(String name) {
    pageList[nowPage] = name;
  }
}