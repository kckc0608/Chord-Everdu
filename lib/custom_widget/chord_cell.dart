import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:chord_everdu/custom_class/sheet.dart';
import '../custom_class/chord.dart';
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
    print(context.read<Sheet>().selectedIndex);

    // 현재 줄 넘김시 사이에 컨테이너를 끼어도

    if (cellIndex > -1) { /// 새로 페이지를 추가하면, 페이지를 추가할 때 생성해서 넣는 코드셀은 아직 sheet 없어서 cellIndex = -1 이 나옴.

      /// selector는 객체의 변경을 기준으로 빌드를 호출한다.
      /// chord에 selector를 달면, chord의 속성이 변해도 빌드되지 않는다. chord라는 객체는 바뀌지 않았기 때문.
      /// chord의 속성값 자체에 selector를 달아야 빌드가 된다. int든 string 이든 속성값 '객체'가 변화했으므로.
      /// 해결책은 2가지가 있는데, 첫번째는 속성값이 변할 때마다 코드 객체를 갈아 치우는 것
      /// 두번째는 ""속성값마다 셀렉터를 달아주는 것""이다.

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

      /// 이 조건 체크를 안하면 포커스를 받을 때마다 가사를 새로 채워서 항상 커서가 앞으로 감.
      if (!isSelected && (lyricController.text != context.select((Sheet s) => s.lyrics[widget.pageIndex][cellIndex]!)))
        lyricController.text = context.select((Sheet s) => s.lyrics[widget.pageIndex][cellIndex]!);
    }

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
              print("now focus index : " + context.read<Sheet>().selectedIndex.toString());
            }
            else { // 포커스가 꺼졌을 때, 현재 가사를 저장
              context.read<Sheet>().lyrics[widget.pageIndex][cellIndex] = lyricController.text;
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