import 'package:chord_everdu/page/common_widget/section_title.dart';
import 'package:chord_everdu/page/group/widget/group_list_item.dart';
import 'package:chord_everdu/page/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Group extends StatelessWidget {
  const Group({super.key});

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null ) { // not login
      return const LoginPage();
    }

    String userEmail = FirebaseAuth.instance.currentUser!.email!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('user_list').doc(userEmail).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          var data = snapshot.data!.data();
          List<dynamic> groupIn = data!["group_in"];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle("내가 속한 그룹"),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 300,
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: groupIn.length,
                      itemBuilder: (context, index) {
                        var groupData = groupIn[index];
                        return GroupListItem(
                          groupID: groupData["group_id"],
                          groupName: groupData["group_name"],
                        );
                      },
                    ),
                  ),
                ),
                const SectionTitle("그룹 찾기"),
                const Expanded(child: Center(child: Text("그룹 검색 기능 추가 예정"))),
              ],
            ),
          );
        }
        return const CircularProgressIndicator();
      }
    );
  }
}
