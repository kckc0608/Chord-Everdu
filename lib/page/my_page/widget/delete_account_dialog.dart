import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("계정 삭제"),
      content: Text(
        "계정을 삭제하면 복구할 수 없습니다.\n정말 삭제하시겠습니까?",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: const Text("취소")),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            FirebaseFirestore.instance.collection('user_list')
                .doc(FirebaseAuth.instance.currentUser!.email)
                .delete().then((value) async {
                  GoogleSignIn().disconnect(); // 매 로그인 시 구글 계정 선택
                  await FirebaseAuth.instance.signOut();
                },
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: const Text("삭제"),
        )
      ],
    );
  }
}
