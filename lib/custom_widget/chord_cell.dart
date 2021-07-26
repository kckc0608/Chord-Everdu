import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import '../custom_class/chord.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';


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

  late Chord chord;

  bool isSelected = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    SheetEditorState? parent = context.findAncestorStateOfType<SheetEditorState>();
    int cellIndex = context.select((Sheet s) => s.getIndexOfCell(widget));

    print("build called cell of " + cellIndex.toString());

    // 현재 줄 넘김시 사이에 컨테이너를 끼어도

    // selector는 객체의 변경을 기준으로 빌드를 호출한다.
    // chord에 selector를 달면, chord의 속성이 변해도 빌드되지 않는다. chord라는 객체는 바뀌지 않았기 때문.
    // chord의 속성값 자체에 selector를 달아야 빌드가 된다. int든 string 이든 속성값 '객체'가 변화했으므로.

    // 해결책은 2가지가 있는데, 첫번째는 속성값이 변할 때마다 코드 객체를 갈아 치우는 것
    // 두번째는 속성값마다 셀렉터를 달아주는 것이다.
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.root);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.rootSharp);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.rootTension);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.minor);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.minorTension);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.major);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.majorTension);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.tensionSharp);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.tension);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.asda);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.asdaTension);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.base);
    context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!.baseSharp);

    chord = context.select((Sheet s) => s.chords[widget.pageIndex][cellIndex]!);
    chordController.text = chord.toStringChord(songKey: context.select((Sheet s) => s.songKey));

    // 이 조건 체크를 안하면 포커스를 받을 때마다 가사를 바꿔서 항상 커서가 앞으로 감.
    if (!isSelected && (lyricController.text != context.select((Sheet s) => s.lyrics[widget.pageIndex][cellIndex]!)))
      lyricController.text = context.select((Sheet s) => s.lyrics[widget.pageIndex][cellIndex]!);

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.amberAccent : Color(0xfffafafa),
        border: (!widget.readOnly) ? Border.all() : null,
      ),
      child: Focus(
        onFocusChange: (!widget.readOnly) ? (hasFocus) {
          setState(() {
            isSelected = hasFocus;
            if (hasFocus) {
              context.read<Sheet>().selectedIndex = context.read<Sheet>().pages[widget.pageIndex].indexOf(widget);
            }
            else { // 포커스가 꺼졌을 때, 현재 가사를 저장
              context.read<Sheet>().lyrics[widget.pageIndex][cellIndex] = lyricController.text;
              if (!chord.isEmpty()) { // TODO : 가사만 수정하고 칸을 옮겨도 최근 코드에 추가되는 문제가 있지만, 코드를 추가하고나서 가사를 수정하고 넘기는 경우도 있을 수 있기에 수정 보류
                global.recentChord.add(chord);
                if (global.recentChord.length > 8) global.recentChord.removeAt(0);
              }
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
                child: TextField(
                  onTap: (!widget.readOnly) ? () {
                    parent!.setState(() {
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
                    contentPadding: EdgeInsets.fromLTRB(2, 0, 0, 0),
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: (widget.readOnly) ? 1.0 : 36.0,
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
                      context.read<Sheet>().selectedIndex = -1;
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