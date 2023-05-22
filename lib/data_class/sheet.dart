import 'package:chord_everdu/data_class/sheet_data.dart';
import 'package:chord_everdu/widget/ChordBlock.dart';
import 'package:flutter/material.dart';

import 'chord.dart';

class Sheet with ChangeNotifier {
  int songKey = 0;
  int selectedBlockIndex = -1;
  int selectedCellIndex = -1;

  List<String> blockNameList = [];
  List<ChordBlock> blocks = [];
  List<List<Widget>> cellsOfBlock = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  void copyFromData(SheetData sheetData) {
    List<Chord> chordList = [];
    for (String chord in sheetData.chordData.split("|")) {
      chordList.add(Chord.fromString(chord));
    }
    chords.add(chordList);
    lyrics.add(sheetData.lyricData.split("|"));

    // test
    chords.add(chordList);
    lyrics.add(sheetData.lyricData.split("|"));
  }

  void setSelectedBlockIndex(int index) {
    selectedBlockIndex = index;
    notifyListeners();
  }
}
