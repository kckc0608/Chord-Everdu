import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/page/common_widget/loading_circle.dart';
import 'package:chord_everdu/page/common_widget/section_content.dart';
import 'package:chord_everdu/page/common_widget/section_title.dart';
import 'package:chord_everdu/page/login/login.dart';
import 'package:chord_everdu/page/my_page/widget/delete_account_dialog.dart';
import 'package:chord_everdu/page/my_page/widget/sheet_list_item.dart';
import 'package:chord_everdu/page/search_sheet/widget/sheet_list_item.dart';
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingCircle();
        }
        if (snapshot.hasData) {
          User user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle("내 정보"),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.network(user.photoURL!),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                user.displayName ?? "표시할 이름이 없습니다.",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(user.email!),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            GoogleSignIn().disconnect(); // 매 로그인 시 구글 계정 선택
                            await FirebaseAuth.instance.signOut();
                          }, child: const Text("로그아웃"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => const DeleteAccountDialog(),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          child: const Text("계정 삭제"),
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionTitle("내 악보"),
                SectionContent(
                  height: 220,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('sheet_list')
                        .where(
                      "editor_email",
                      isEqualTo: FirebaseAuth.instance.currentUser!.email,
                    ).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoadingCircle();
                      }

                      var docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return const Center(child: Text("내가 만든 악보가 없습니다."));
                      }

                      return ListView.separated(
                        itemCount: docs.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder:(context, index) {
                          var dicID = docs[index].id;
                          var doc = docs[index].data();
                          return MySheetListItem(
                            sheetID: dicID,
                            title: doc["title"],
                            singer: doc["singer"],
                          );
                        },
                      );
                    },
                  ),
                ),
                const SectionTitle("좋아요 표시한 악보"),
                Expanded(
                  child: SectionContent(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('user_list')
                          .doc(FirebaseAuth.instance.currentUser!.email)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const LoadingCircle();
                        }

                        var data = snapshot.data!.data();
                        List<dynamic> favoriteSheets = data!["favorite_sheet"];
                        if (favoriteSheets.isEmpty) {
                          return const Center(child: Text("내가 좋아요 표시한 악보가 없습니다."));
                        }
                        return ListView.separated(
                          itemCount: favoriteSheets.length,
                          itemBuilder:(context, index) {
                            var sheetInfo = favoriteSheets[index];
                            return SheetListItem(
                              sheetID: sheetInfo["sheet_id"],
                              sheetInfo: SheetInfo.fromMap(sheetInfo),
                              isFavorite: true,
                            );
                          },
                          separatorBuilder: (context, index) => const Divider(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        } else {
          return const LoginPage();
        }
    },);
  }
}

