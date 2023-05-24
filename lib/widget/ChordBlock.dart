import 'package:chord_everdu/widget/ChordCell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_class/chord.dart';
import '../data_class/sheet.dart';

class ChordBlock extends StatefulWidget {
  final int blockID;
  const ChordBlock({Key? key, required this.blockID}) : super(key: key);

  @override
  State<ChordBlock> createState() => _ChordBlockState();
}

class _ChordBlockState extends State<ChordBlock> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    List<ChordCell> cellList = [];
    /// 이렇게 하면 sheet.chords[blockID] 가 아니라 sheet.chords 를 추적하는 것 같음.
    List<Chord?> chordList = context.select((Sheet sheet) => sheet.chords[widget.blockID]);
    List<String?> lyricList = context.select((Sheet sheet) => sheet.lyrics[widget.blockID]);

    for (int i = 0; i < chordList.length; i++) {
      cellList.add(ChordCell(
        blockID: widget.blockID,
        cellID: i,
      ));
    }

    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          context.read<Sheet>().selectedBlockIndex = widget.blockID;
        }

        /// setState를 호출하면 기존에 선택했던 블록과, 새로 선택된 블록을 통으로 리빌드함.
        setState(() {
          isSelected = hasFocus;
        });
      },
      child: Builder(
        builder: (context) {
          FocusNode focusNode = Focus.of(context);
          return GestureDetector(
            onTap: () {
              if (focusNode.hasFocus) {
                focusNode.unfocus();
              } else {
                focusNode.requestFocus();
              }
            },
            child: Container(
              color: isSelected ? Colors.yellow : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                          child: Text("change block name"),
                        ),
                        InkWell(
                          child: Icon(Icons.edit_outlined),
                        ),
                        InkWell(
                          child: Icon(Icons.delete_forever_outlined, color: Colors.red,),
                        )
                      ],
                    ),
                  ),
                  Wrap(
                    children: cellList,
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
