import 'dart:async';

import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import '../../custom_class/chord.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';


class ChordCell extends StatefulWidget {
  final bool readOnly;
  const ChordCell({Key? key, this.readOnly = false}) : super(key: key);

  @override
  _ChordCellState createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell>
    with AutomaticKeepAliveClientMixin {

  var lyricController = TextEditingController();
  var chordController = TextEditingController();

  late Chord chord;
  late int songKey;

  bool isSelected = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    SheetEditorState? parent = context.findAncestorStateOfType<SheetEditorState>();
    int blockIndex = context.select((Sheet s) => s.getBlockIndexOfCell(widget));
    int cellIndex = context.select((Sheet s) => s.getIndexOfCell(widget, pageIndex: blockIndex));
    print("build called cell of " + cellIndex.toString() + " from block " + blockIndex.toString());

    /// 새로 페이지를 추가하면, 페이지를 추가할 때 생성해서 넣는 코드셀은
    /// 아직 sheet 가 없어서 cellIndex = -1 이 나옴.
    if (cellIndex > -1) {
      /// selector는 객체의 변경을 기준으로 빌드를 호출한다.
      /// chord에 selector를 달면, chord의 속성이 변해도 빌드되지 않는다. chord라는 객체는 바뀌지 않았기 때문.
      /// chord의 속성값 자체에 selector를 달아야 빌드가 된다. int든 string 이든 속성값 '객체'가 변화했으므로.
      /// 해결책은 2가지가 있는데, 첫번째는 속성값이 변할 때마다 코드 객체를 갈아 치우는 것
      /// 두번째는 ""속성값마다 셀렉터를 달아주는 것""이다.
      /// 그런데 모든 속성값을 일일히 체크하기는 귀찮으니, 그냥 toStringChord 변환값을 확인한다.
      if (!widget.readOnly) {
        context.select((Sheet s) => s.chords[blockIndex][cellIndex]!.toStringChord());
      }

      chord = context.select((Sheet s) => s.chords[blockIndex][cellIndex]!);
      songKey = context.select((Sheet s) => s.songKey);

      chordController.text = chord.toStringChord(songKey: songKey);

      /// 이 조건 체크를 안하면 포커스를 받을 때마다 가사를 새로 채워서 항상 커서가 앞으로 감.
      if (!isSelected && (lyricController.text != context.select((Sheet s) => s.lyrics[blockIndex][cellIndex]!)))
        lyricController.text = context.select((Sheet s) => s.lyrics[blockIndex][cellIndex]!);
    }

    return Container(
      padding: widget.readOnly ? EdgeInsets.symmetric(vertical: 4.0) : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isSelected ? Colors.amberAccent : Color.fromRGBO(0, 0, 0, 0),
        border: (!widget.readOnly) ? Border.all() : null,
      ),
      child: Focus(
        onFocusChange: (!widget.readOnly) ? (hasFocus) {
          setState(() {
            isSelected = hasFocus;
            if (hasFocus) {
              context.read<Sheet>().selectedCellIndex = context.read<Sheet>().cellsOfBlock[blockIndex].indexOf(widget);
              context.read<Sheet>().nowBlock = blockIndex;
              context.read<Sheet>().setStateOfSheet();
              print("now focus index : " + context.read<Sheet>().selectedCellIndex.toString());
            }
            else {
              /// 포커스가 꺼졌을 때, 현재 가사를 저장
              context.read<Sheet>().lyrics[blockIndex][cellIndex] = lyricController.text;
            }
          });
        } : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: (widget.readOnly) ? 1.0 : 36.0,
              ),
              child: IntrinsicWidth(
                child: /*TextField(
                  onTap: (!widget.readOnly) ? () {
                    /// 가사를 입력하고나서 코드를 입력하면, 잠시동안 시스템키보드와 코드키보드가 같이 나타나면서
                    /// 스크롤이 밀리는 현상을 방지하기 위해, 시스템 키보드가 사라지는 시간을 기다리는 타이머 설정
                    Timer(Duration(milliseconds: 80), () {
                      parent!.setState(() {
                        parent.isChordInput = true;
                        parent.cellTextController = this.chordController;
                      });
                    });
                  } : null,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  controller: chordController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: (widget.readOnly) ? InputBorder.none : null,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                  ),
                ),*/
                InkWell(
                  onTap: () {
                    parent!.setState(() {
                      parent.isChordInput = true;
                      parent.cellTextController = this.chordController;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      chord.toStringChord(songKey: songKey),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                /// 빈 칸일 때 최소 너비
                minWidth: (widget.readOnly) ? 16.0 : 36.0,
              ),
              child: IntrinsicWidth(
                child: TextField(
                  onTap: (!widget.readOnly) ? () {
                    parent!.setState(() {
                      parent.isChordInput = false;
                      parent.cellTextController = this.lyricController;
                    });
                  } : null,
                  onEditingComplete: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      context.read<Sheet>().selectedCellIndex = -1;
                      context.read<Sheet>().nowBlock = -1;
                      context.read<Sheet>().setStateOfSheet();
                    });
                  },
                  controller: lyricController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 2, 2),
                  ),
                  readOnly: widget.readOnly,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    chordController.dispose();
    lyricController.dispose();
    super.dispose();
  }
}