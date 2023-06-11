import 'package:chord_everdu/data_class/sheet_data.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'chord.dart';

class Sheet with ChangeNotifier {
  int songKey = 0;
  int selectedBlockIndex = -1;
  int selectedCellIndex = -1;

  List<String> blockNameList = [];
  List<List<Chord>> chords = [];
  List<List<String?>> lyrics = [];

  void copyFromData(SheetData sheetData) {
    for (String chords in sheetData.chordData) {
      List<Chord> chordList = [];
      for (String chord in chords.split("|")) {
        chordList.add(
            chord.isEmpty
                ? Chord()
                : Chord.fromString(chord)
        );
      }
      this.chords.add(chordList);
    }

    for (String lyrics in sheetData.lyricData) {
      this.lyrics.add(lyrics.split("|"));
    }
    Logger().d(chords);
  }

  void setSelectedBlockIndex(int index) {
    selectedBlockIndex = index;
    notifyListeners();
  }

  void setSelectedCellIndex(int index) {
    selectedCellIndex = index;
    notifyListeners();
  }

  void addCell(int blockID, Chord chord, String lyric) {
    chords[blockID].add(chord);
    lyrics[blockID].add(lyric);
    notifyListeners();
  }

  void removeCell({required int blockID, required int cellID}) {
    chords[blockID].removeAt(cellID);
    lyrics[blockID].removeAt(cellID);
    notifyListeners();
  }

  void addBlock() {
    chords.add([]);
    lyrics.add([]);
    notifyListeners();
  }

  void notifyChange() {
    notifyListeners();
  }

  void updateChord(int blockID, int cellID, Chord chord) {
    chords[blockID][cellID] = chord;
    notifyListeners();
  }

  List<String> convertChordsToStringList() {
    List<String> list = [];
    for (int i = 0; i < chords.length; i++) {
      String block = '';
      for (int j = 0; j < chords[i].length; j++) {
        block += chords[i][j].toStringChord();
        if (j < chords[i].length - 1) block += '|';
      }
      list.add(block);
    }
    return list;
  }

  List<String> convertLyricsToStringList() {
    List<String> list = [];
    for (int i = 0; i < lyrics.length; i++) {
      String block = '';
      for (int j = 0; j < lyrics[i].length; j++) {
        block += lyrics[i][j]!; /// String? 을 써야하는가? 그냥 빈 문자열로 치면 안되나 싶음.
        if (j < lyrics[i].length - 1) block += '|';
      }
      list.add(block);
    }
    return list;
  }

  void initializeSheet() {
    chords.clear();
    lyrics.clear();
  }
}
