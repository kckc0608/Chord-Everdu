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

  @override
  Widget build(BuildContext context) {
    int sheetKey = context.watch<Sheet>().sheetKey;
    int songKey = context.read<Sheet>().sheetInfo.songKey;
    int selectedCellID = context.select((Sheet sheet) => sheet.selectedCellIndex);
    int selectedBlockID = context.select((Sheet sheet) => sheet.selectedBlockIndex);
    Chord? chord = context.watch<Sheet>().chords[widget.blockID][widget.cellID];
    String? lyric = context.watch<Sheet>().lyrics[widget.blockID][widget.cellID];

    //Logger().d("build cell : ${widget.blockID} ${widget.cellID}");
    isSelected = selectedCellID == widget.cellID && selectedBlockID == widget.blockID;
    return Focus(
      onFocusChange: (hasFocus) {

      },
      child: Builder(builder: (context) {
        FocusNode focusNode = Focus.of(context);
        return GestureDetector(
          onTap: () {
            if (focusNode.hasFocus) {
              focusNode.unfocus();
              context.read<Sheet>().unsetSelectedCellAndBlockIndex();
            } else {
              focusNode.requestFocus();
              context.read<Sheet>().inputMode = InputMode.root;
              context.read<Sheet>().setSelectedCellIndex(widget.cellID);
              context.read<Sheet>().setSelectedBlockIndex(widget.blockID);
            }
          },
          child: (chord == null && lyric == null)
              ? NullCell(
                color: isSelected ? Colors.yellow : Colors.white,
              )
              : Container(
                  padding: context.read<Sheet>().isReadOnly
                      ? lyric!.isNotEmpty
                        ? const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0)
                        : const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0)
                      : const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
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
                          chord?.toStringChord(key: (sheetKey + songKey)%12) ?? "",
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
                            chord!.toStringChord(key: (sheetKey + songKey)%12),
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
