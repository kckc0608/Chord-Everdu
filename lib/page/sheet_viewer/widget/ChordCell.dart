import 'package:chord_everdu/data_class/chord.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/NullCell.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../../data_class/sheet.dart';

class ChordCell extends StatefulWidget {
  final int cellID;
  final int blockID;

  const ChordCell({
    Key? key,
    required this.cellID,
    required this.blockID,
  }) : super(key: key);

  @override
  State<ChordCell> createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell> {
  bool isSelected = false;
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    int sheetKey = context.watch<Sheet>().sheetKey;
    Chord? chord = context.watch<Sheet>().chords[widget.blockID][widget.cellID];
    String? lyric = context.watch<Sheet>().lyrics[widget.blockID][widget.cellID];
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          isSelected = hasFocus;
        });
      },
      child: Builder(builder: (context) {
        FocusNode focusNode = Focus.of(context);
        return GestureDetector(
          onTap: () {
            if (focusNode.hasFocus) { /// sheet 클래스에 조작 메소드를 추가하는 방식으로 수정하자
              focusNode.unfocus();
              context.read<Sheet>().selectedCellIndex = -1;
            } else {
              focusNode.requestFocus();
              context.read<Sheet>().selectedCellIndex = widget.cellID;
            }
            context.read<Sheet>().notifyChange();
          },
          child: (chord == null && lyric == null)
              ? NullCell(
                color: isSelected ? Colors.yellow : Colors.white,
              )
              : Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 4.0),
                  decoration: context.read<Sheet>().isReadOnly ? null : BoxDecoration(
                    color: isSelected ? Colors.yellow : Colors.white,
                    border: Border.all(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: context.read<Sheet>().isReadOnly ? [
                      SizedBox(
                        height: 18,
                        child: Text(
                          chord?.toStringChord(sheetKey: sheetKey) ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                        child: Text(
                          lyric ?? "",
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ] : [
                      Container(
                        color: Colors.black12,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 36.0, minHeight: 18),
                          child: Text(
                            chord!.toStringChord(sheetKey: sheetKey),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.black12,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 36.0,
                            minHeight: 18,
                            maxHeight: 18,
                          ),
                          child: Text(
                            lyric ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.1,
                              textBaseline: TextBaseline.alphabetic
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      }),
    );
  }
}
