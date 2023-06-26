import 'package:chord_everdu/page/login/login.dart';
import 'package:chord_everdu/page/my_page/widget/sheet_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
          User user = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("내 정보", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.network(user.photoURL!),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? "표시할 이름이 없습니다.",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(user.email!),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            GoogleSignIn().disconnect(); // 매 로그인 시 구글 계정 선택
                            await FirebaseAuth.instance.signOut();
                          }, child: const Text("로그아웃"),
                        ),
                      ],
                    ),
                  ),
                  const Text("내 악보", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('sheet_list')
                          .where("editor_email", isEqualTo: FirebaseAuth.instance.currentUser!.email).get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var docs = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder:(context, index) {
                              var dicID = docs[index].id;
                              var doc = docs[index].data();
                              return SheetListItem(
                                sheetID: dicID,
                                title: doc["title"],
                                singer: doc["singer"],
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text("loading..."));
                        }
                      },
                    ),
                  ),
                  const Text("내 악보", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                  SizedBox(
                    height: 180,
                    child: FutureBuilder(
                      future: FirebaseFirestore.instance.collection('sheet_list')
                          .where("editor_email", isEqualTo: FirebaseAuth.instance.currentUser!.email).get(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var docs = snapshot.data!.docs;
                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder:(context, index) {
                              var dicID = docs[index].id;
                              var doc = docs[index].data();
                              return SheetListItem(
                                sheetID: dicID,
                                title: doc["title"],
                                singer: doc["singer"],
                              );
                            },
                          );
                        } else {
                          return const Center(child: Text("loading..."));
                        }
                      },
                    ),
                  ),
                  const Text("내 그룹", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  )),
                ],
              ),
            ),
          );
        } else {
          return const LoginPage();
        }
    },);
  }
}

