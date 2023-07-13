import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("로그인이 필요합니다."),
          ElevatedButton(
            child: const Text("Google 로그인"),
            onPressed: () async {
              await signInWithGoogle();
              String userEmail = FirebaseAuth.instance.currentUser!.email!;
              FirebaseFirestore.instance
                  .collection('user_list')
                  .doc(userEmail)
                  .get().then((snapshot) async {
                    if (!snapshot.exists) {
                      await FirebaseFirestore.instance
                          .collection('user_list')
                          .doc(userEmail)
                          .set({
                        "favorite_sheet" : [],
                        "group_in": [],
                      }); /// TODO : 초기 유저 데이터 세팅 필요
                    }
              });
            },
          ),
        ],
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn()
        .onError((error, stackTrace) {Logger().e(error); return null;});
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
