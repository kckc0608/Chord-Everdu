import 'package:chord_everdu/data_class/sheet_data.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'chord.dart';

class Sheet with ChangeNotifier {
  int songKey = 0;
  int selectedBlockIndex = -1;
  int selectedCellIndex = -1;
  bool isReadOnly = true;

  List<String> blockNameList = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  SheetInfo sheetInfo = SheetInfo(
    songKey: 0,
    singer: "",
    title: "",
  );

  void copyFromData(SheetData sheetData) {
    for (String chords in sheetData.chordData) {
      List<Chord?> chordList = [];
      for (String chord in chords.split("|")) {
        chordList.add(
            chord == '\n'
            ? null
            : chord.isEmpty
                ? Chord()
                : Chord.fromString(chord));
      }
      this.chords.add(chordList);
    }

    for (String lyrics in sheetData.lyricData) {
      List<String?> lyricList = [];
      for (String lyric in lyrics.split("|")) { // Split 한거 바로 넣으면 List<String> 타입이 들어감.
        lyricList.add(lyric == '\n' ? null : lyric);
      }
      this.lyrics.add(lyricList);
    }
    Logger().d(chords);
    Logger().d(lyrics);
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

  void addNewLineCell({required int blockID, required int cellID}) {
    chords[blockID].insert(cellID, null);
    lyrics[blockID].insert(cellID, null);
    notifyListeners();
  }

  void removeCell({required int blockID, required int cellID}) {
    chords[blockID].removeAt(cellID);
    lyrics[blockID].removeAt(cellID);
    notifyListeners();
  }

  void removePreviousCell({required int blockID, required int cellID}) {
    if (cellID == 0) return;
    chords[blockID].removeAt((cellID-1));
    lyrics[blockID].removeAt((cellID-1));
    selectedCellIndex = -1;
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

  void updateLyric(int blockID, int cellID, String lyric) {
    lyrics[blockID][cellID] = lyric;
    notifyListeners();
  }

  void updateSheetInfo(SheetInfo newInfo) {
    sheetInfo = newInfo;
    notifyListeners();
  }

  List<String> convertChordsToStringList() {
    List<String> list = [];
    for (int i = 0; i < chords.length; i++) {
      String block = '';
      for (int j = 0; j < chords[i].length; j++) {
        if (chords[i][j] == null) {
          block += '\n';
        } else {
          block += chords[i][j]!.toStringChord();
        }
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
        if (lyrics[i][j] == null) {
          block += '\n';
        } else {
          block += lyrics[i][j]!;
        }
        if (j < lyrics[i].length - 1) block += '|';
      }
      list.add(block);
    }
    return list;
  }

  void initializeSheet() {
    chords.clear();
    lyrics.clear();
    chords.add([Chord.fromString("C")]);
    lyrics.add([""]);
  }
}
