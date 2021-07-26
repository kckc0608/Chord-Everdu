import 'package:chord_everdu/page/login.dart';
import 'package:chord_everdu/custom_class/sheet_info.dart';
import 'package:chord_everdu/page/sheet_editor.dart';
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
                child: Text("내 정보", style: _headerStyle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //color: Colors.white24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      child: Image.network(FirebaseAuth.instance.currentUser!.photoURL!, fit: BoxFit.fill),
                      width: 50,
                      height: 50,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(FirebaseAuth.instance.currentUser!.displayName!, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Text(FirebaseAuth.instance.currentUser!.email!),
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
                        
                      }),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Text("내가 만든 악보", style: _headerStyle),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_ios_outlined, size: 18)
                    ],
                  ),
                ),
              ),
              // TODO: 내가 만든 악보가 없으면, '내가 만든 악보가 없어요' '첫 악보 만들러 가기' '악보 만들기 튜토리얼' 등 기능 넣기
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sheet_list')
                    .where("editor_email", isEqualTo: FirebaseAuth.instance.currentUser!.email)
                    .limit(3)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final documents = snapshot.data!.docs;
                  print(documents.toString());
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        if (index < documents.length)
                          return _buildItemWidget(documents[index]);
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
              Text("좋아요 표시한 악보", style: _headerStyle),
            ],
          ),
        );
      },
    );
  }

  void signOutFromGoogle() async {
    return await FirebaseAuth.instance.signOut();
  }


  Widget _buildItemWidget(doc) {
    final sheet = SheetInfo(
      title:   doc['title'],
      songKey: doc['song_key'],
      singer:  doc['singer'],
    );

    return InkWell(
      onTap: () {
        print("onTap event");
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return SheetEditor(
                sheetID: doc.id,
                title:   sheet.title,
                singer:  sheet.singer,
                songKey: sheet.songKey,
                readOnly: true,
              );
            })
        );
      },
      onLongPress: () {
        print("long Press Event");
        showDialog(context: context, builder: (context) {
          return SimpleDialog(
            children: [
              TextButton(child: Text("악보 삭제"), onPressed: () {
                Navigator.of(context).pop();
              }),
            ],
          );
        });
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        color: Colors.grey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(sheet.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(sheet.singer, style: TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
