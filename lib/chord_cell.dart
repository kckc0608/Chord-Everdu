import 'package:chord_everdu/page_NewSheet.dart';
import 'package:chord_everdu/sheet_viewer.dart';
import 'custom_data_structure.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class ChordCell extends StatefulWidget {
  final String? lyric;
  final Map<String, dynamic>? chord;
  final bool readOnly;

  const ChordCell({Key? key, this.lyric, this.chord, this.readOnly = false}) : super(key: key);

  @override
  _ChordCellState createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell>
    with AutomaticKeepAliveClientMixin {

  var lyricController = TextEditingController();
  var chordController = TextEditingController();

  var chord_t = Chord();

  Map<String, dynamic> chord = {
    "root" : -1,
    "rootSharp" : 0,
    "rootTension" : -1,
    "minor" : "",
    "minorTension" : -1,
    "major" : "",
    "majorTension" : -1,
    "tension" : -1,
    "tensionSharp" : 0,
    "asda" : "",
    "asdaTension" : -1,
    "base" : -1,
    "baseSharp" : 0
  };

  String? lyric = "hi";

  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    if (widget.lyric != null) lyricController.text = widget.lyric!;
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    dynamic parent = context.findAncestorStateOfType<NewSheetState>();
    if (parent == null) parent = context.findAncestorStateOfType<SheetViewerState>();
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.amberAccent : Colors.white,
        border: Border.all(),
      ),
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {
            isSelected = hasFocus;
            if (hasFocus) {
              print("has Focus of sheet Cell called");
              parent!.setState(() {
                parent.currentCell = this.widget;
                parent.cellTextController = this.chordController;
                parent.currentChord = this.chord;
              });
            }
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 24.0),
              child: IntrinsicWidth(
                child: TextField(
                  onTap: () {
                    parent!.isChordInput = true;
                    parent.setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold),
                  controller: chordController,
                  readOnly: true,
                  decoration: InputDecoration(
                    //border: InputBorder.none,
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
                  onTap: () {
                    parent!.setState(() {
                      parent.isChordInput = false;
                    });
                  },
                  onEditingComplete: () {
                    lyric = lyricController.text;
                    FocusScope.of(context).unfocus();
                    parent!.currentCell = null;
                    parent.setState(() {});
                  },
                  controller: lyricController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                  ),
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