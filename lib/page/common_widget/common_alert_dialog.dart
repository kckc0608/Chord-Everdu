import 'package:flutter/material.dart';

class CommonAlertDialog extends StatelessWidget {
  final String content;
  const CommonAlertDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("알림"),
      content: Text(content, style: Theme.of(context).textTheme.bodyLarge,),
      actions: [
        ElevatedButton(
          child: const Text("확인"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
