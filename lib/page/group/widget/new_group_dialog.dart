import 'package:chord_everdu/page/group_detail/group_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class NewGroupDialog extends StatefulWidget {
  const NewGroupDialog({super.key});

  @override
  State<NewGroupDialog> createState() => _NewGroupDialogState();
}

class _NewGroupDialogState extends State<NewGroupDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _groupNameController;
  late bool isPrivate;
  late User user;
  final _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("새 그룹"),
      content: Form(
        key: _formKey,
        child: Container(
          height: 300,
          color: Colors.yellow,
          child: Column(
            children: [
              /// 그룹 이름
              TextFormField(
                controller: _groupNameController,
                decoration: const InputDecoration(
                  labelText: "그룹 이름",
                  labelStyle: TextStyle(fontSize: 16),
                  helperText: "* 필수 입력값입니다.",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(8, 12, 12, 8),
                  isCollapsed: true,
                ),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
              ),
              /// 공개 여부
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPrivate = false;
                      });
                    },
                    child: Row(
                      children: [
                        Radio(value: false, groupValue: isPrivate,
                          onChanged: (_) {},
                        ),
                        const Text("공개"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        isPrivate = true;
                      });
                    },
                    child: Row(
                      children: [
                        Radio(value: true, groupValue: isPrivate, onChanged: (_) {},),
                        const Text("비공개"),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: const Text("취소")),
        ElevatedButton(onPressed: () {
          _db.collection('group_list').add({
            "group_name": _groupNameController.text,
            "is_private": isPrivate,
            "manager": [FirebaseAuth.instance.currentUser!.email],
            "member": [],
          })
              .then((doc) {
                _db.collection('user_list').doc(user.email).update({
                  "group_in": FieldValue.arrayUnion([{
                    "group_id": doc.id,
                    "group_name": _groupNameController.text,
                  }])}
                ).then((value) {
                  Logger().i('내가 속한 그룹에 추가되었습니다.');
                  Navigator.of(context).pop();
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => GroupDetail(
                      groupName: _groupNameController.text,
                      groupID: doc.id,
                    ),
                  ));
                }, onError: (e) {
                  Logger().e(e);
                });
              },
            onError: (e) {
                Logger().e(e);
            },
          );
        }, child: const Text("생성"))
      ],
    );
  }

  @override
  void initState() {
    _groupNameController = TextEditingController();
    isPrivate = false;
    user = FirebaseAuth.instance.currentUser!;
    super.initState();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
}
