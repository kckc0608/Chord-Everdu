import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AddNewMemberDialog extends StatefulWidget {
  final String groupID;
  const AddNewMemberDialog({super.key, required this.groupID});

  @override
  State<AddNewMemberDialog> createState() => _AddNewMemberDialogState();
}

class _AddNewMemberDialogState extends State<AddNewMemberDialog> {
  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("추가할 멤버 이메일을 입력하세요."),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.emailAddress,
      ),
      actions: [
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(onPressed: () async {
          await FirebaseFirestore.instance.collection('group_list')
              .doc(widget.groupID)
              .update({"member": FieldValue.arrayUnion([_controller.text])})
              .then((value) {
                Logger().i("새 멤버가 추가되었습니다.");
              },onError: (e) => Logger().e(e));
          Navigator.of(context).pop();
        }, child: const Text("확인")),
      ],
    );;
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
