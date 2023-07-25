import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class DeleteGroupCheckDialog extends StatefulWidget {
  final String groupID;
  final VoidCallback onDeleteGroup;

  const DeleteGroupCheckDialog({
    super.key,
    required this.groupID,
    required this.onDeleteGroup
  });

  @override
  State<DeleteGroupCheckDialog> createState() => _DeleteGroupCheckDialogState();
}

class _DeleteGroupCheckDialogState extends State<DeleteGroupCheckDialog> {
  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("그룹 삭제"),
      content: const Text("삭제된 그룹은 복원할 수 없습니다. 삭제하시겠습니까?"),
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
    ;
  }

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
