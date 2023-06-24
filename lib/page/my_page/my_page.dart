import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

class MyPage extends StatefulWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          User? user = snapshot.data;
          return SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Text("내 정보", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                ),
                TextButton(child: Text("logout"), onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              children: [
                const Text("로그인이 필요합니다."),
                TextButton(onPressed: () {
                  signInWithGoogle();
                }, child: Text("Google로 로그인")),
              ],
            ),
          );
        }
    },);
  }

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn().onError((error, stackTrace) {Logger().e(error); return null;});
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

