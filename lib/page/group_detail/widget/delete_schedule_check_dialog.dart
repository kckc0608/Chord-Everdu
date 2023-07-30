import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DeleteScheduleCheckDialog extends StatefulWidget {
  final VoidCallback onDeleteGroup;

  const DeleteScheduleCheckDialog({
    super.key,
    required this.onDeleteGroup
  });

  @override
  State<DeleteScheduleCheckDialog> createState() => _DeleteScheduleCheckDialogState();
}

class _DeleteScheduleCheckDialogState extends State<DeleteScheduleCheckDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("일정 삭제"),
      content: const Text("삭제된 일정은 복원할 수 없습니다. 삭제하시겠습니까?"),
      actions: [
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: widget.onDeleteGroup,
          child: const Text("삭제"),
        ),
      ],
    );
  }
}
