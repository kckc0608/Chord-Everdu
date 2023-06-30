import 'package:chord_everdu/data_class/sheet_info.dart';

class SheetData {
  List<String> chordData = [];
  List<String> lyricData = [];
  List<String> blockNames = [];

  SheetData({required this.chordData, required this.lyricData, required this.blockNames});
}