import 'package:chord_everdu/custom_widget/group/group_list_item.dart';
import 'package:chord_everdu/page/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  const Group({Key? key}) : super(key: key);

  @override
  _GroupState createState() => _GroupState();
}

class _GroupState extends State<Group> {

  TextStyle _headerStyle = TextStyle(fontSize: 20);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        /// 로그인이 안되어 있을 때
        if (snapshot.data == null) return Login();
        /// 로그인이 되어 있을 때

        String _userEmail = FirebaseAuth.instance.currentUser!.email!;
        return StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('user_list').doc(_userEmail).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(child: CircularProgressIndicator());

            var doc = snapshot.data!.data() as Map<String, dynamic>;
            var group_in = doc['group_in'] as List<dynamic>;
            print(doc);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                    child: Text("내가 속한 그룹", style: _headerStyle),
                  ),
                  ListView.builder(
                    itemCount: group_in.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> now_group = group_in[index];
                      return GroupListItem(groupID: now_group['group_id'], name: now_group['group_name']);
                    },
                  ),
                  Text("인기 그룹", style: _headerStyle),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
