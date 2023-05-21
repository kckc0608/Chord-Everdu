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
  @override
  Widget build(BuildContext context) {
    List<ChordCell> cellList = [];
    List<Chord?> chordList = context.read<Sheet>().chords[widget.blockID];
    List<String?> lyricList = context.read<Sheet>().lyrics[widget.blockID];

    for (int i = 0; i < chordList.length; i++) {
      cellList.add(ChordCell(
        chord: chordList[i],
        lyric: lyricList[i],
      ));
    }

    return Container(
      //color: Colors.yellow,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 0, 8),
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
    );
  }
}
