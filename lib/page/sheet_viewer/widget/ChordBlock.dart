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
    int selectedBlockID = context.select((Sheet sheet) => sheet.selectedBlockIndex);
    isSelected = selectedBlockID == widget.blockID;
    List<Chord?> chordList = context.select((Sheet sheet) => sheet.chords[widget.blockID]);
    List<String?> lyricList = context.select((Sheet sheet) => sheet.lyrics[widget.blockID]);

    for (int i = 0; i < chordList.length; i++) {
      cellList.add(ChordCell(
        blockID: widget.blockID,
        cellID: i,
      ));
    }

    return Builder(builder: (context) {
      return GestureDetector(
        onTap: () {
          if (!isSelected) {
            context.read<Sheet>().setSelectedBlockIndex(widget.blockID);
            context.read<Sheet>().setSelectedCellIndex(0); // selected cell index 가 이전 블록 index 로 남아 있어 초기화
          }
        },
        child: Container(
          color: isSelected ? Colors.yellow : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      blockName ?? "",
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  !isReadOnly && isSelected
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                                context: context, builder: (context) => BlockNameEditDialog(blockID: widget.blockID));
                          },
                          iconSize: 24.0,
                          icon: const Icon(Icons.edit_outlined),
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          constraints: const BoxConstraints(),
                        )
                      : const SizedBox.shrink(),
                  !isReadOnly && isSelected
                      ? IconButton(
                          onPressed: () {
                            context.read<Sheet>().copyBlock(blockID: widget.blockID);
                          },
                          iconSize: 20.0,
                          icon: const Icon(Icons.copy),
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          constraints: const BoxConstraints(),
                        )
                      : const SizedBox.shrink(),
                  !isReadOnly && isSelected
                      ? IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => const CommonCheckDialog(title: "블럭 삭제", content: "블럭을 삭제하시겠습니까?"),
                            ).then((isYes) {
                              if (isYes) {
                                context.read<Sheet>().removeBlock(blockID: widget.blockID);
                              }
                            });
                          },
                          iconSize: 26.0,
                          icon: const Icon(Icons.delete_forever_outlined),
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          constraints: const BoxConstraints(),
                          color: Colors.red,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
              Wrap(
                children: cellList,
              )
            ],
          ),
        ),
      );
    });
  }
}
