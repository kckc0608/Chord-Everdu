import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data_class/sheet.dart';

class NewChordBlockDialog extends StatelessWidget {
  const NewChordBlockDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        TextButton(
          child: const Text("새 블럭 만들기"),
          onPressed: () {
            context.read<Sheet>().addBlock();
            Navigator.of(context).pop();
          },
        ),
        TextButton(onPressed: () {}, child: const Text("블럭 복사하기")),
      ],
    );
  }
}