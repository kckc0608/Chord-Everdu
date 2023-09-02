import 'package:chord_everdu/data_class/sheet_data.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/data_class/tag_content.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/chord_keyboard/chord_keyboard.dart';
import 'package:flutter/material.dart';

import 'chord.dart';
enum InputMode {root, asda, base, tension}
class Sheet with ChangeNotifier {
  int sheetKey = 0;
  int selectedBlockIndex = -1;
  int selectedCellIndex = -1;
  InputMode inputMode = InputMode.root;
  bool isReadOnly = true;

  List<String> blockNames = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  SheetInfo sheetInfo = SheetInfo(
    songKey: 0,
    singer: "",
    title: "",
    level: TagContent.noTag,
    genre: TagContent.noTag,
  );

  void copyFromData(SheetData sheetData) {
    for (String chords in sheetData.chordData) {
      List<Chord?> chordList = [];
      for (String chordData in chords.split("|")) {
        chordList.add(
            chordData == '\n'
            ? null
            : chordData.isEmpty
                ? Chord()
                : Chord.fromData(chordData));
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

  void unsetSelectedCellAndBlockIndex() {
    selectedCellIndex = -1;
    selectedBlockIndex = -1;
    notifyListeners();
  }

  void addNewCell() {
    assert (isValidBlockAndCell(blockID: selectedBlockIndex, cellID: selectedCellIndex));
    chords[selectedBlockIndex].insert(selectedCellIndex+1, Chord());
    lyrics[selectedBlockIndex].insert(selectedCellIndex+1, "");
    selectedCellIndex += 1;
    notifyListeners();
  }

  void addNewLineCell() {
    assert (isValidBlockAndCell(blockID: selectedBlockIndex, cellID: selectedCellIndex));
    chords[selectedBlockIndex].insert(selectedCellIndex, null);
    lyrics[selectedBlockIndex].insert(selectedCellIndex, null);
    selectedCellIndex += 1;
    notifyListeners();
  }

  void removeCell() {
    assert (isValidBlockAndCell(blockID: selectedBlockIndex, cellID: selectedCellIndex));
    chords[selectedBlockIndex].removeAt(selectedCellIndex);
    lyrics[selectedBlockIndex].removeAt(selectedCellIndex);
    notifyListeners();
  }

  void removePreviousCell() {
    assert (isValidBlockAndCell(blockID: selectedBlockIndex, cellID: selectedCellIndex));
    assert (selectedCellIndex > 0);
    chords[selectedBlockIndex].removeAt((selectedCellIndex-1));
    lyrics[selectedBlockIndex].removeAt((selectedCellIndex-1));
    selectedCellIndex -= 1;
    notifyListeners();
  }

  void addBlock() {
    chords.add([Chord()]);
    lyrics.add([""]);
    blockNames.add("블럭 이름을 설정하세요.");
    selectedBlockIndex = blockNames.length-1;
    selectedCellIndex = 0;
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
    if (cellID == lyrics[blockID].length-1) {
      lyrics[blockID].add("");
      chords[blockID].add(Chord());
      lyrics[blockID][cellID+1] = lyric.substring(selectPosition) + lyrics[blockID][cellID+1]!;
      lyrics[blockID][cellID] = lyric.substring(0, selectPosition);
    } else if (lyrics[blockID][cellID+1] == null) {
      lyrics[blockID][cellID+2] = lyric.substring(selectPosition) + lyrics[blockID][cellID+2]!;
      lyrics[blockID][cellID] = lyric.substring(0, selectPosition);
    }
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
          block += chords[i][j]!.toStringDataForSave();
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
    sheetKey = 0;
  }

  bool isValidBlockAndCell({required int blockID, required int cellID}) {
    if (chords.length != lyrics.length) {
      return false;
    }
    if (selectedBlockIndex < 0 || chords.length <= selectedBlockIndex ) {
      return false;
    }
    if (selectedCellIndex < 0 || chords[selectedBlockIndex].length <= selectedCellIndex) {
      return false;
    }
    return true;
  }

  bool isPreviousCellIsNewLineCell() {
    assert (isValidBlockAndCell(blockID: selectedBlockIndex, cellID: selectedCellIndex));
    if (selectedCellIndex == 0) {
      return false;
    }
    if (chords[selectedBlockIndex][selectedCellIndex-1] == null &&
        lyrics[selectedBlockIndex][selectedCellIndex-1] == null) {
      return true;
    }
    return false;
  }
}
