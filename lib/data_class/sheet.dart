import 'package:flutter/material.dart';

class Sheet with ChangeNotifier {
  int songKey = 0;
  int nowBlock = -1;
  int selectedCellIndex = -1;

  List<String> blockNameList = [];
  List<Widget> blocks = [];
  List<List<Widget>> cellsOfBlock = [];
  //List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  void copyFromSheet(Sheet sheet) {

  }

  void copyFromData(dynamic sheetData) {
    
  }
}
