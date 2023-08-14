import 'package:chord_everdu/data_class/sheet.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

class BlockNameEditDialog extends StatefulWidget {
  final int blockID;
  const BlockNameEditDialog({super.key, required this.blockID});

  @override
  State<BlockNameEditDialog> createState() => _BlockNameEditDialogState();
}

class _BlockNameEditDialogState extends State<BlockNameEditDialog> {
  late TextEditingController blockNameController;
  late FocusNode focusNode;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("블럭 이름 변경"),
      content: TextField(
        controller: blockNameController,
        focusNode: focusNode,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 4.0),
          isCollapsed: true
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: const Text("취소")),
        ElevatedButton(onPressed: () {
          context.read<Sheet>().setNameOfBlockAt(blockID: widget.blockID, name: blockNameController.text);
          Navigator.of(context).pop();
        }, child: const Text("확인")),
      ],
    );
  }

  @override
  void initState() {
    blockNameController = TextEditingController();
    focusNode = FocusNode();
    blockNameController.text = context.read<Sheet>().blockNames[widget.blockID];
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        Logger().i("focus");
        blockNameController.selection = TextSelection(baseOffset: 0, extentOffset: blockNameController.value.text.length);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    blockNameController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
