import 'package:chord_everdu/page/login.dart';
import 'package:chord_everdu/custom_class/sheet_info.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
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
        if (snapshot.data == null) return Login();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("내가 속한 그룹", style: _headerStyle),
              ),
              Text("인기 그룹", style: _headerStyle),
            ],
          ),
        );
      },
    );
  }
}
