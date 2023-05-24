import 'package:chord_everdu/data_class/chord.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_class/sheet.dart';

class ChordCell extends StatefulWidget {
  final Chord? chord;
  final String? lyric;
  final int cellID;
  final int blockID;

  const ChordCell({
    Key? key,
    required this.chord,
    required this.lyric,
    required this.cellID,
    required this.blockID,
  }) : super(key: key);

  @override
  State<ChordCell> createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    print("build:${widget.cellID}");
    //print(context.read<Sheet>().selectedCellIndex);
    return Focus(
      onFocusChange: (hasFocus) {
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
                context.read<Sheet>().selectedCellIndex = -1;
              } else {
                focusNode.requestFocus();
                context.read<Sheet>().selectedCellIndex = widget.cellID;
              }
              context.read<Sheet>().notifyChange();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow : Colors.white,
                border: Border.all(),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 36.0),
                    child: Text(widget.chord!.toStringChord(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 36.0),
                    child:
                      Text(widget.lyric!, style: const TextStyle(fontSize: 16)),
                      //TextField(),
                  ),
                ],      ),
            ),
          );
        }
      ),
    );
  }
}
