import 'package:chord_everdu/page/group_detail/group_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class MemberListItem extends StatelessWidget {
  final String groupID;
  final String memberEmail;
  final GroupAuthority groupAuthority;

  const MemberListItem(
      {super.key, required this.memberEmail, required this.groupID, required this.groupAuthority});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: groupAuthority == GroupAuthority.reader
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                      title: Center(child: Text(memberEmail)),
                      content: TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('group_list')
                              .doc(groupID)
                              .update({
                            "member": FieldValue.arrayRemove([memberEmail])
                          }).then((value) {
                            Logger().i("멤버 $memberEmail 가 삭제되었습니다.");
                          }, onError: (e) => Logger().e(e));
                          Navigator.of(context).pop();
                        },
                        child: const Text("멤버 삭제"),
                      )),
                );
              },
        child: Container(
          decoration: const BoxDecoration(
              border: Border(
            bottom: BorderSide(style: BorderStyle.solid),
          )),
          child: Text(memberEmail),
        ),
      ),
    );
  }
}
