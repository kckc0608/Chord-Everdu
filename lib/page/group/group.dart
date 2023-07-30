import 'package:chord_everdu/page/common_widget/loading_circle.dart';
import 'package:chord_everdu/page/common_widget/section_content.dart';
import 'package:chord_everdu/page/common_widget/section_title.dart';
import 'package:chord_everdu/page/group/widget/group_list_item.dart';
import 'package:chord_everdu/page/login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Group extends StatelessWidget {
  Group({super.key});

  final _db = FirebaseFirestore.instance;
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_user == null) { // not login
      return const LoginPage();
    }

    String userEmail = _user!.email!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle("내가 속한 그룹"),
          SectionContent(
            height: 300,
            child: StreamBuilder(
                stream: _db.collection('user_list')
                    .doc(userEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingCircle();
                  }

                  var data = snapshot.data!.data();
                  List<dynamic> groupIn = data!["group_in"];

                  if (groupIn.isEmpty) {
                    return const Center(child: Text("내가 속한 그룹이 없습니다."));
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(height: 0),
                    itemCount: groupIn.length,
                    itemBuilder: (context, index) {
                      var groupData = groupIn[index];
                      return GroupListItem(
                        groupID: groupData["group_id"],
                        groupName: groupData["group_name"],
                      );
                    },
                  );
                }
            ),
          ),
          const SectionTitle("그룹 찾기"),
          Expanded(
            child: SectionContent(
              child: StreamBuilder(
                  stream: _db.collection('group_list')
                      .where("is_private", isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingCircle();
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text(snapshot.error.toString()));
                    }

                    List<QueryDocumentSnapshot> docs = snapshot.data!.docs;

                    return ListView.separated(
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        var doc = docs[index].data()! as Map<String, dynamic>;
                        return GroupListItem(
                          groupID: docs[index].id,
                          groupName: doc["group_name"],
                        );
                      },
                    );
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}
