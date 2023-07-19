import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemberListItem extends StatelessWidget {
  final String memberEmail;
  final VoidCallback onTapDelete;
  const MemberListItem({super.key, required this.memberEmail, required this.onTapDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Center(child: Text(memberEmail)),
              content: TextButton(
                child: const Text("멤버 삭제"),
                onPressed: onTapDelete,
              )
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(style: BorderStyle.solid),
            )
          ),
          child: Text(memberEmail),
        ),
      ),
    );
  }
}
