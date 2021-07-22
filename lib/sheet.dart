import 'package:flutter/material.dart';
import 'package:chord_everdu/custom_data_structure.dart';
import 'package:chord_everdu/chord_cell.dart';
class Sheet with ChangeNotifier {
  int songKey = 0;
  int nowPage = 0;
  int selectedIndex = 0;

  ChordCell? nowCell;

  List<String> pageList = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  void add(Chord chord) {
    chords[nowPage].insert(selectedIndex+1, chord);
    lyrics[nowPage].insert(selectedIndex+1, "");
    notifyListeners();
  }

  void remove() {
    chords[nowPage].removeAt(selectedIndex);
    lyrics[nowPage].removeAt(selectedIndex);
    notifyListeners();
  }

  void newLine() {
    chords[nowPage].insert(selectedIndex, null);
    lyrics[nowPage].insert(selectedIndex, null);
    notifyListeners();
  }

  void removeBefore() {
    chords[nowPage].removeAt(selectedIndex-1);
    lyrics[nowPage].removeAt(selectedIndex-1);
    notifyListeners();
  }

  void moveLyric() {
    notifyListeners();
  }

  void allClear() {
    nowCell = null;
    songKey = 0;
    pageList = [];
    nowPage = 0;
    selectedIndex = 0;
    chords = [];
    lyrics = [];
  }

  bool isLastSelection() => (selectedIndex == lyrics[nowPage].length-1);

  void setLyric(int index, String newLyric) {
    if (index == -1) throw Exception("selected index == -1");
    if (index > lyrics[nowPage].length - 1) throw Exception("selected index is bigger than lyric list max index.");
    lyrics[nowPage][index] = newLyric;
  }

  void changePageName(String name) {
    pageList[nowPage] = name;
  }
}