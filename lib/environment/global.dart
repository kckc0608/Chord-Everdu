import 'package:flutter/material.dart';
import '../data_class/chord.dart';

List<dynamic> chordKeyList = const ["C", ["C#", "Db"], "D", ["D#", "Eb"], "E", "F", ["F#", "Gb"], "G", ["G#", "Ab"], "A", ["A#", "Bb"], "B"];
List<dynamic> sheetKeyList = const ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"];
List<int> keyWithSharpOrFlat = const [0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0];
List<String> tensionList = const ['2', '4', '5', '6', '9', '11', '13', '7'];
List<int> indexToKeyOffset = const [0, 2, 4, 5, 7, 9, 11];

List<Chord> recentChord = [];

class NowInput {
  static const String root = "root";
  static const String asda = "asda";
  static const String minor = "minor";
  static const String major = "major";
  static const String tension = "tension";
}

const backgroundColor = const Color(0xfffafafa);