import 'package:chord_everdu/sheet_editor.dart';
import 'custom_data_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class ChordCell extends StatefulWidget {
  final bool readOnly;
  final int pageIndex;
  const ChordCell({Key? key, required this.pageIndex, this.readOnly = false}) : super(key: key);

  @override
  _ChordCellState createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell>
    with AutomaticKeepAliveClientMixin {

  var lyricController = TextEditingController();
  var chordController = TextEditingController();

  Chord? chord;

  bool isSelected = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    SheetEditorState? parent = context.findAncestorStateOfType<SheetEditorState>();

    int cellIndex = parent!.sheet[widget.pageIndex].indexOf(widget);

    chord = parent.chord[widget.pageIndex][cellIndex];
    lyricController.text = parent.lyric[widget.pageIndex][cellIndex]!;
    chordController.text = chord!.toStringChord(songKey: parent.songKey);

    print("build call from chord " + chord.toString());

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.amberAccent : Colors.white,
        border: (!widget.readOnly) ? Border.all() : null,
      ),
      child: Focus(
        onFocusChange: (!widget.readOnly) ? (hasFocus) {
          setState(() {
            isSelected = hasFocus;
            if (hasFocus) {
              print("has Focus of sheet Cell called");
              parent.setState(() {
                parent.currentCell = this.widget;
              });
            }
            else { // 포커스가 꺼졌을 때, 현재 가사를 저장
              parent.lyric[widget.pageIndex][cellIndex] = lyricController.text;
            }
          });
        } : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 24.0),
              child: IntrinsicWidth(
                child: TextField(
                  onTap: (!widget.readOnly) ? () {
                    parent.setState(() {
                      parent.isChordInput = true;
                      parent.cellTextController = this.chordController;
                    });
                  } : null,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  controller: chordController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: (widget.readOnly) ? InputBorder.none : null,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 48.0,
              ),
              child: IntrinsicWidth(
                child: TextField(
                  onTap: (!widget.readOnly) ? () {
                    parent.setState(() {
                      parent.isChordInput = false;
                      parent.cellTextController = this.lyricController;
                    });
                  } : null,
                  onEditingComplete: () {
                    setState(() {
                      FocusScope.of(context).unfocus();
                      parent.currentCell = null;
                      parent.selectedIndex = -1;
                    });
                  },
                  controller: lyricController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
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
}