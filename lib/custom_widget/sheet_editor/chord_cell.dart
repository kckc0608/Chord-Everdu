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
      /// selector는 객체의 변경을 기준으로 변화를 감지해 빌드한다.
      /// chord 객체에 selector를 달면, chord의 속성이 변해도 빌드되지 않는다. chord라는 객체는 바뀌지 않았기 때문.
      /// 코드 객체의 모든 속성값에 셀렉터를 달기는 힘들지만, 속성값을 조합한 결과물로 변화를 체크할 수 있다.
      if (!widget.readOnly) {
        context.select((Sheet s) => s.chords[blockIndex][cellIndex]!.toStringChord());
      }

      chord = context.select((Sheet s) => s.chords[blockIndex][cellIndex]!);
      songKey = context.select((Sheet s) => s.songKey);
      isSelected = context.select((Sheet s) => s.isSelectedCell(widget, blockIndex));

      /// 이 조건 체크를 안하면 포커스를 받을 때마다 가사를 새로 채워서 항상 커서가 앞으로 감.
      if (!isSelected && (lyricController.text != context.select((Sheet s) => s.lyrics[blockIndex][cellIndex]!)))
        lyricController.text = context.select((Sheet s) => s.lyrics[blockIndex][cellIndex]!);
    }

    return Focus(
      onFocusChange: (!widget.readOnly)
          ? (hasFocus) {
            setState(() {
              if (hasFocus) {
                context.read<Sheet>().selectedCellIndex = context.read<Sheet>().cellsOfBlock[blockIndex].indexOf(widget);
                context.read<Sheet>().nowBlock = blockIndex;
                context.read<Sheet>().setStateOfSheet();
                print("now focus index : " + context.read<Sheet>().selectedCellIndex.toString());
              } else {
                /// 포커스가 꺼졌을 때, 현재 가사를 저장
                context.read<Sheet>().lyrics[blockIndex][cellIndex] = lyricController.text;
              }
            });
          }
          : null,
      child: Container(
        padding: widget.readOnly
            ? EdgeInsets.symmetric(vertical: 4.0)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected ? Colors.amberAccent : Color.fromRGBO(0, 0, 0, 0),
          border: (!widget.readOnly) ? Border.all() : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: (widget.readOnly) ? 1.0 : 36.0),
              child: GestureDetector(
                onTap: (!widget.readOnly)
                    ? () {
                        parent!.setState(() {
                          parent.isChordInput = true;
                          FocusScope.of(context).unfocus();
                        });
                        setState(() {
                          context.read<Sheet>().selectedCellIndex = context.read<Sheet>().cellsOfBlock[blockIndex].indexOf(widget);
                          context.read<Sheet>().nowBlock = blockIndex;
                          context.read<Sheet>().setStateOfSheet();
                          print("now focus index : " + context.read<Sheet>().selectedCellIndex.toString());
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(2, 0, 0, 0),
                  child: Text(
                    chord.toStringChord(songKey: songKey),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            widget.readOnly
                ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(
                      context.select((Sheet s) => s.lyrics[blockIndex][cellIndex]!),
                      style: TextStyle(fontSize: 16, height: 1),
                    ),
                )

            : ConstrainedBox(
              constraints: BoxConstraints(
                /// 빈 칸일 때 최소 너비
                minWidth: (widget.readOnly) ? 16.0 : 36.0,
              ),
              child: IntrinsicWidth(
                child: TextField(
                  onTap: (!widget.readOnly)
                      ? () {
                          parent!.setState(() {
                            parent.isChordInput = false;
                            parent.cellTextController = this.lyricController;
                          });
                        }
                      : null,
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
    lyricController.dispose();
    super.dispose();
  }
}
