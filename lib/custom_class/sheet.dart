import 'package:flutter/material.dart';
import 'package:chord_everdu/custom_class/chord.dart';
import 'package:chord_everdu/custom_widget/chord_cell.dart';
import 'package:chord_everdu/custom_widget/chord_block.dart';
class Sheet with ChangeNotifier {
  int songKey = 0;
  int nowBlock = -1;
  int selectedCellIndex = -1;

  List<String> blockNameList = [];
  List<Widget> blocks = [];
  List<List<Widget>> cellsOfBlock = [];
  List<List<Chord?>> chords = [];
  List<List<String?>> lyrics = [];

  void addCell({Chord? chord, String? lyric, int? index}) {
    index = index ?? selectedCellIndex + 1;

    if (index > chords[nowBlock].length || index < 0)
      throw Exception("[sheet.dart][addCell] 인덱스 범위를 벗어났습니다. index : " + index.toString());

    chords[nowBlock].insert(index, chord ?? Chord());
    lyrics[nowBlock].insert(index, lyric ?? "");
    cellsOfBlock[nowBlock].insert(index, ChordCell(key: UniqueKey()));
    notifyListeners();
  }

  void remove({int? index}) {
    index = index ?? selectedCellIndex;

    if (index >= chords[nowBlock].length || index < 0)
      throw Exception("[sheet.dart][removeCell] 인덱스 범위를 벗어났습니다. index : " + index.toString());

    if (index == 0 || cellsOfBlock[nowBlock][index -1] is Container) {
      if (index < cellsOfBlock[nowBlock].length-1 && cellsOfBlock[nowBlock][index+1] is Container) {
        cellsOfBlock[nowBlock].removeAt(index+1);
        chords[nowBlock].removeAt(index+1);
        lyrics[nowBlock].removeAt(index+1);
      }
    }

    cellsOfBlock[nowBlock].removeAt(index);
    chords[nowBlock].removeAt(index);
    lyrics[nowBlock].removeAt(index);
    notifyListeners();
  }

  void newLine() {
    /// 이 조건에서는 아예 버튼이 활성화가 안되기 때문에 실행될 일이 없기는 하다.
    if (selectedCellIndex == 0) return;
    if (chords[nowBlock][selectedCellIndex - 1] == null) return;

    chords[nowBlock].insert(selectedCellIndex, null);
    lyrics[nowBlock].insert(selectedCellIndex, null);
    cellsOfBlock[nowBlock].insert(selectedCellIndex, Container(key: UniqueKey(), width: 1000));

    selectedCellIndex += 1;
    notifyListeners();
  }

  void removeBefore() {
    if (selectedCellIndex == 0) return;

    cellsOfBlock[nowBlock].removeAt(selectedCellIndex-1);
    chords[nowBlock].removeAt(selectedCellIndex-1);
    lyrics[nowBlock].removeAt(selectedCellIndex-1);

    // 자신의 포커스를 유지한 채로 앞의 위젯들을 지우다보면 selectedIndex가 갱신이 안됨.
    selectedCellIndex -= 1;

    notifyListeners();
  }

  void moveLyric() {
    // TODO: 줄바꿈을 한 경우 가사 이동이 이상하게 되고 인덱스가 꼬임.
    if (selectedCellIndex == chords[nowBlock].length -1) {
      chords[nowBlock].add(Chord());
      lyrics[nowBlock].add("");
    }
  }

  void addBlock({String? blockName}) {
    blockNameList.add(blockName ?? "새 블록");
    blocks.add(ChordBlock(key: UniqueKey(),));
    chords.add([Chord()]);
    lyrics.add(["가사"]);
    cellsOfBlock.add([ChordCell(key: UniqueKey())]);
    notifyListeners();
  }

  copyBlock(int blockIndex) {
    blockNameList.add(blockNameList[blockIndex] + " - 복사본");
    // 코드 복사
    chords.add([]);
    for (int i = 0; i < chords[blockIndex].length; i++) {
      if (chords[blockIndex][i] == null)
        chords.last.add(null);
      else
        chords.last.add(Chord.fromMap(chords[blockIndex][i]!.toMap()));
    }
    // 가사 복사
    lyrics.add([]);
    for (int i = 0; i < lyrics[blockIndex].length; i++) {
      if (lyrics[blockIndex][i] == null)
        lyrics.last.add(null);
      else
        lyrics.last.add(lyrics[blockIndex][i].toString());
    }
    // 코드셀 복사
    cellsOfBlock.add([]);
    for (int i = 0; i < cellsOfBlock[blockIndex].length; i++) {
      if (cellsOfBlock[blockIndex][i] is Container)
        cellsOfBlock.last.add(Container(key: UniqueKey(), width: 1000));
      else
        cellsOfBlock.last.add(ChordCell(key: UniqueKey()));
    }
    // 코드 블럭 추가
    blocks.add(ChordBlock(key: UniqueKey()));
    notifyListeners();
  }

  void removeBlock(int? index) {
    blocks.removeAt(index ?? nowBlock);
    cellsOfBlock.removeAt(index ?? nowBlock);
    chords.removeAt(index ?? nowBlock);
    lyrics.removeAt(index ?? nowBlock);
    blockNameList.removeAt(index ?? nowBlock);

    nowBlock = -1;
    notifyListeners();
  }

  void allClear() {
    songKey = 0;
    blocks = [];
    blockNameList = [];
    chords = [];
    lyrics = [];
    cellsOfBlock = [];
    nowBlock = -1;
    selectedCellIndex = -1;
  }

  bool isLastSelection() => (selectedCellIndex == lyrics[nowBlock].length-1);
  bool isAvailableNewLineButton() => (selectedCellIndex > 0 && chords[nowBlock][selectedCellIndex-1] != null);
  bool isAvailableDeleteCellButton() => (selectedCellIndex > -1 && cellsOfBlock[nowBlock].length > 1);

  void setLyric(int index, String newLyric) {
    if (index == -1) throw Exception("selected index == -1");
    if (index > lyrics[nowBlock].length - 1) throw Exception("selected index is bigger than lyric list max index.");
    lyrics[nowBlock][index] = newLyric;
  }

  String? getLyric({required int index}) {
    if (index <= -1) throw Exception("현재 선택한 셀이 없습니다.");
    if (index >= lyrics[nowBlock].length) throw Exception("셀 범위를 벗어났습니다.");
    return lyrics[nowBlock][index];
  }

  void setChord(int index, Chord newChord) {
    if (index == -1) throw Exception("selected index == -1");
    if (index > lyrics[nowBlock].length - 1) throw Exception("selected index is bigger than lyric list max index.");
    chords[nowBlock][index] = newChord;
    notifyListeners();
  }

  int getIndexOfCell(ChordCell? cell, {int? pageIndex}) {
    if (cell == null) {
      print("[sheet.dart][getIndexOfCell] cell 이 null 입니다.");
      return selectedCellIndex = -1;
    }
    if (pageIndex != null && (pageIndex >= cellsOfBlock.length || pageIndex < 0))
      return selectedCellIndex = -1;

    return cellsOfBlock[pageIndex ?? nowBlock].indexOf(cell);
  }

  int getBlockIndexOfCell(ChordCell? cell) {
    if (cell == null) {
      print("[sheet.dart][getIndexOfCell] cell 이 null 입니다.");
      return -1;
    }

    for (int i = 0; i < cellsOfBlock.length; i++) {
      int _index = cellsOfBlock[i].indexOf(cell);
      if (_index > -1) return i;
    }

    return -1;
  }

  void setStateOfSheet () {
    print("notify");
    notifyListeners();
  }

  void changePageName(String name) {
    blockNameList[nowBlock] = name;
  }
}