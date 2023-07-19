import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class NewScheduleDialog extends StatefulWidget {
  final String groupID;
  const NewScheduleDialog({super.key, required this.groupID});

  @override
  State<NewScheduleDialog> createState() => _NewScheduleDialogState();
}

class _NewScheduleDialogState extends State<NewScheduleDialog> {
  late TextEditingController _controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("추가할 일정 이름을 입력하세요."),
      content: TextField(
        controller: _controller,
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
              .doc(widget.groupID).collection('set_lists').doc(_controller.text).set(
              {"sheets": []}).then((value) {
                Logger().i("새 일정이 추가되었습니다.");
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
