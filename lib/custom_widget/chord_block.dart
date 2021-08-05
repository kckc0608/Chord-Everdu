import 'package:chord_everdu/custom_class/sheet.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class ChordBlock extends StatefulWidget {
  final bool readOnly;
  const ChordBlock({
    Key? key,
    this.readOnly = false,
  }) : super(key: key);

  @override
  _ChordBlockState createState() => _ChordBlockState();
}

class _ChordBlockState extends State<ChordBlock> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    SheetEditorState? parent = context.findAncestorStateOfType<SheetEditorState>();
    int blockIndex = context.select((Sheet s) => s.blocks.indexOf(widget));
    print("block of " + blockIndex.toString() + " is builded");
    isSelected = blockIndex == context.select((Sheet s) => s.nowBlock);

    /// 블럭 삭제할 때 인덱스 문제가 발생하는 것을 해결하기 위한 코드
    if (blockIndex == -1) return SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        print("Block tapped");
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: (!widget.readOnly && isSelected) ? Colors.amber.shade100 : Color(0xfffafafa),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 0, 8.0),
              child: Row(
                children: [
                  Text(
                    context.select((Sheet s) => s.blockNameList[blockIndex]),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8.0),
                  (isSelected && !widget.readOnly) ?
                  InkWell(
                    onTap: () {
                      var _controller = TextEditingController();
                      _controller.text = context.read<Sheet>().blockNameList[blockIndex];
                      showDialog(context: context, builder: (context) => AlertDialog(
                        title: Text("블록 이름 변경"),
                        content: TextField(
                          controller: _controller,
                        ),
                        actions: [
                          TextButton(child: Text("확인"), onPressed: () {
                            Navigator.of(context).pop(_controller.text);
                          }),
                        ],
                      )).then((blockTitle) {
                        setState(() {
                          context.read<Sheet>().blockNameList[blockIndex] = blockTitle;
                        });
                      });
                    },
                    child: Icon(Icons.edit_outlined, size: 22),
                  ) : SizedBox.shrink(),
                  SizedBox(width: 8.0),
                  (isSelected && !widget.readOnly) ?
                  InkWell(
                    onTap: () {
                      showDialog(context: context, builder: (context) {
                        return AlertDialog(
                          title: Text("블록 삭제"),
                          content: Text("현재 블록을 삭제하시겠습니까?"),
                          actions: [
                            TextButton(child: Text("예"), onPressed: () {
                              parent!.setState(() {
                                parent.isChordInput = false;
                              });
                              context.read<Sheet>().removeBlock(blockIndex);
                              Navigator.of(context).pop();
                            }),
                            TextButton(child: Text("아니오"), onPressed: () {Navigator.of(context).pop();})
                          ],
                        );
                      });
                    },
                    child: Icon(Icons.delete_forever_outlined, size: 22, color: Colors.red),
                  ) : SizedBox.shrink(),
                ],
              ),
            ),
            Wrap(
              // TODO: 왜 인지 갱신이 안되는 문제가 있음
              //children: context.select((Sheet s) => s.cellsOfBlock[blockIndex]),
              children: context.watch<Sheet>().cellsOfBlock[blockIndex],
            ),
          ],
        ),
      ),
    );
  }
}