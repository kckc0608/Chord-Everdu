import 'package:flutter/material.dart';

class SheetDeleteCheckDialog extends StatelessWidget {
  const SheetDeleteCheckDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("작성 취소"),
      content: const Text("악보 작성 페이지를 나가시겠습니까?"),
      actions: [
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop(false);
          },
        ),
        ElevatedButton(
          child: const Text("확인"),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ],
    );
  }
}
