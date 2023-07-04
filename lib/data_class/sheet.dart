import 'package:chord_everdu/data_class/sheet_data.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:flutter/material.dart';

import 'chord.dart';

class Sheet with ChangeNotifier {
  int sheetKey = 0;
  int selectedBlockIndex = -1;
  int selectedCellIndex = -1;
  bool isReadOnly = true;

  List<String> blockNames = [];
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

    blockNames = sheetData.blockNames;
  }

  void setSelectedBlockIndex(int index) {
    selectedBlockIndex = index;
    notifyListeners();
  }

  void setSelectedCellIndex(int index) {
    selectedCellIndex = index;
    notifyListeners();
  }

  void unsetSelectedCellIndex() {
    selectedCellIndex = -1;
    notifyListeners();
  }

  void addCell({
    required int blockID,
    int? cellID,
    required Chord chord,
    required String lyric
  }) {
    if (cellID == null || cellID == chords[blockID].length - 1) {
      chords[blockID].add(chord);
      lyrics[blockID].add(lyric);
    } else {
      chords[blockID].insert(cellID+1, chord);
      lyrics[blockID].insert(cellID+1, lyric);
    }
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
    if (selectedCellIndex > 0) {
      selectedCellIndex -= 1;
    }
    notifyListeners();
  }

  void addBlock() {
    chords.add([Chord()]);
    lyrics.add([""]);
    blockNames.add("블럭 이름을 설정하세요.");
    notifyListeners();
  }

  void removeBlock({required int blockID}) {
    chords.removeAt(blockID);
    lyrics.removeAt(blockID);
    blockNames.removeAt(blockID);
    selectedBlockIndex = -1;
    notifyListeners();
  }

  void setNameOfBlockAt({required int blockID, required String name}) {
    assert (0 <= blockID && blockID < blockNames.length);
    blockNames[blockID] = name;
    notifyListeners();
  }

  void copyBlock({required int blockID}) {
    List<Chord?> copiedChordList = [];
    List<String?> copiedLyricList = [];
    for (Chord? chord in chords[blockID]) {
      copiedChordList.add(chord);
    }
    for (String? lyric in lyrics[blockID]) {
      copiedLyricList.add(lyric);
    }
    chords.add(copiedChordList);
    lyrics.add(copiedLyricList);
    blockNames.add(blockNames[blockID]);
    notifyListeners();
  }

  void moveLyricToNextCell({required int blockID, required int cellID, required int selectPosition}) {
    String lyric = lyrics[blockID][cellID]!;
    lyrics[blockID][cellID+1] = lyric.substring(selectPosition) + lyrics[blockID][cellID+1]!;
    lyrics[blockID][cellID] = lyric.substring(0, selectPosition);
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

  void increaseSheetKey() {
    sheetKey += 1;
    sheetKey %= 12;
    notifyListeners();
  }

  void decreaseSheetKey() {
    sheetKey -= 1;
    sheetKey += 12;
    sheetKey %= 12;
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
          block += chords[i][j]!.toStringChord(sheetKey: sheetKey);
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
    blockNames.clear();
    chords.add([Chord.fromString("C")]);
    lyrics.add([""]);
    blockNames.add("블럭 이름을 설정하세요.");
  }
}
