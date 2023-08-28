import 'package:chord_everdu/data_class/sheet_info.dart';

class SheetData {
  List<String> chordData = [];
  List<String> lyricData = [];
  List<String> blockNames = [];

  SheetData({required this.chordData, required this.lyricData, required this.blockNames});

  factory SheetData.fromMap(Map<String, dynamic> data) {
    List<String> chords = [];
    List<String> lyrics = [];
    List<String> blockNames = [];
    for (String chordData in data["chords"]) {
      chords.add(chordData);
    }
    for (String lyricData in data["lyrics"]) {
      lyrics.add(lyricData);
    }
    for (String blockName in data["block_names"]) {
      blockNames.add(blockName);
    }
    return SheetData(lyricData: lyrics, chordData: chords, blockNames: blockNames);
  }
}