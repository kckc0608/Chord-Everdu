import 'package:chord_everdu/custom_widget/common/sheet_list_item.dart';
import 'package:chord_everdu/page/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MySheet extends StatefulWidget {
  const MySheet({Key? key}) : super(key: key);

  @override
  _MySheetState createState() => _MySheetState();
}

class _MySheetState extends State<MySheet> {

  TextStyle _headerStyle = TextStyle(fontSize: 20);

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _DB = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.data == null) return Login();

        /// 로그인 한 유저가 DB user_list에 없다면 user_list에 유저 추가
        _DB.collection('user_list').doc(_auth.currentUser!.email).get().then((value) async {
          if (!value.exists)
            _DB.collection('user_list').doc(_auth.currentUser!.email).set({
              'displayName' : _auth.currentUser!.displayName,
              'favoriteSheet' : [],
            });
          return await null;
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text("내 정보", style: _headerStyle),
              ),
              /// CONTENT OF 내 정보
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //color: Colors.white24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Image.network(_auth.currentUser!.photoURL!, fit: BoxFit.fill),
                      width: 50, height: 50
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_auth.currentUser!.displayName!, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(_auth.currentUser!.email!),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      child: Text("로그아웃", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).canvasColor),
                        foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark),
                        side: MaterialStateProperty.all(BorderSide(color: Colors.black54)),
                      ),
                      onPressed: signOutFromGoogle,
                    ),
                    Expanded(
                      child: IconButton(icon: Icon(Icons.settings), onPressed: () {
                        showDialog(context: context, builder: (context) => AlertDialog(

                        ));
                      }),
                    ),
                  ],
                ),
              ),
              /// 내가 만든 악보 더보기 버튼
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Text("내가 만든 악보", style: _headerStyle),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios_outlined, size: 18)
                    ],
                  ),
                ),
              ),
              /// 내가 만든 악보 최근 리스트
              // TODO: 내가 만든 악보가 없으면, '내가 만든 악보가 없어요' '첫 악보 만들러 가기' '악보 만들기 튜토리얼' 등 기능 넣기
              StreamBuilder<QuerySnapshot>(
                stream: _DB.collection('sheet_list')
                    .where("editor_email", isEqualTo: _auth.currentUser!.email)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  final documents = snapshot.data!.docs;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var _doc = documents[index];
                        if (index < documents.length)
                          return SheetListItem(
                            sheetID: _doc.id,
                            title:   _doc['title'],
                            singer:  _doc['singer'],
                            songKey: _doc['song_key'],
                            isDeletable: true,
                            isEditable: true,
                          );

                        return SizedBox(height: 50);
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 4.0, thickness: 1.0);
                      },
                      itemCount: 3,
                    ),
                  );
                },
              ),
              /// 좋아요 표시한 악보 버튼
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Text("좋아요 표시한 악보", style: _headerStyle),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios_outlined, size: 18)
                    ],
                  ),
                ),
              ),
              /// 최근 좋아요 표시한 악보 리스트
              StreamBuilder<DocumentSnapshot>(
                stream: _DB.collection('user_list').doc(_auth.currentUser!.email).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  final doc = snapshot.data!.data() as Map<String, dynamic>;

                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index >= doc["favoriteSheet"].length)
                          return SizedBox(height: 50);

                        var sheet = doc["favoriteSheet"][index];
                        return SheetListItem(
                          sheetID: sheet['sheet_id'],
                          title:   sheet['title'],
                          singer:  sheet['singer'],
                          songKey: sheet['song_key'],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider(height: 4.0, thickness: 1.0);
                      },
                      itemCount: 3,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void signOutFromGoogle() async {
    return await FirebaseAuth.instance.signOut();
  }
}
