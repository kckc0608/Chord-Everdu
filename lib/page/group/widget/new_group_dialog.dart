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
        child: SizedBox(
          height: 180,
          child: Column(
            children: [
              /// 그룹 이름
              TextFormField(
                controller: _groupNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '값을 입력하세요.';
                  }
                  return null;
                },
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

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.fromBorderSide(BorderSide(color: Colors.grey[300]!,)),
                            borderRadius: BorderRadius.circular(4.0)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                                    onChanged: (value) {
                                      setState(() {
                                        isPrivate = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "공개",
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
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
                                  Radio(
                                    value: true,
                                    groupValue: isPrivate,
                                    onChanged: (value) {
                                      setState(() {
                                        isPrivate = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    "비공개",
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: 5,
                      child: Container(
                          color: Theme.of(context).dialogBackgroundColor,
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: const Text(
                            "그룹 공개 여부",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          )),
                    ),
                  ],
                ),
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
          if (_formKey.currentState!.validate()) {
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
          }
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
