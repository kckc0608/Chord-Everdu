import 'package:flutter/material.dart';

class NewChordBlockDialog extends StatelessWidget {
  const NewChordBlockDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        TextButton(onPressed: () {}, child: const Text("새 블럭 만들기")),
        TextButton(onPressed: () {}, child: const Text("블럭 복사하기")),
      ],
    );
  }
}