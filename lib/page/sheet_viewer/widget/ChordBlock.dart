import 'package:chord_everdu/page/common_widget/common_check_dialog.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/ChordCell.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/dialog/block_name_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data_class/chord.dart';
import '../../../data_class/sheet.dart';

class ChordBlock extends StatefulWidget {
  final int blockID;

  const ChordBlock({Key? key, required this.blockID}) : super(key: key);

  @override
  State<ChordBlock> createState() => _ChordBlockState();
}

class _ChordBlockState extends State<ChordBlock> {
  bool isSelected = false;
  late bool isReadOnly;
  late String blockName;

  @override
  Widget build(BuildContext context) {
    isReadOnly = context.read<Sheet>().isReadOnly;
    blockName = context.watch<Sheet>().blockNames[widget.blockID];

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
      child: Builder(builder: (context) {
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                        child: Text(
                          blockName ?? "",
                          style: const TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      if (isReadOnly)
                        const SizedBox.shrink()
                      else
                        InkWell(
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(Icons.edit_outlined),
                          ),
                          onTap: () {
                            showDialog(
                                context: context, builder: (context) => BlockNameEditDialog(blockID: widget.blockID));
                          },
                        ),
                      isReadOnly
                          ? const SizedBox.shrink()
                          : InkWell(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  Icons.copy,
                                ),
                              ),
                              onTap: () {
                                context.read<Sheet>().copyBlock(blockID: widget.blockID);
                              },
                            ),
                      isReadOnly
                          ? const SizedBox.shrink()
                          : InkWell(
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.0),
                                child: Icon(
                                  Icons.delete_forever_outlined,
                                  color: Colors.red,
                                ),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const CommonCheckDialog(title: "블럭 삭제", content: "블럭을 삭제하시겠습니까?"),
                                ).then((isYes) {
                                  if(isYes) {
                                    context.read<Sheet>().removeBlock(blockID: widget.blockID);
                                  }
                                });
                              },
                            ),
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
      }),
    );
  }
}
