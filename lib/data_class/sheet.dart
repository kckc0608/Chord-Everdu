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
    Logger().d(this.chords);
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
}
