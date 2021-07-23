import 'package:chord_everdu/page/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("내 정보", style: _headerStyle),
              Padding(
                padding: const EdgeInsets.all(8.0),
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
                      child: Text("Log Out", style: TextStyle(fontSize: 14)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Theme.of(context).canvasColor),
                        foregroundColor: MaterialStateProperty.all(Theme.of(context).primaryColorDark),
                        side: MaterialStateProperty.all(BorderSide(color: Colors.black54)),
                      ),
                      onPressed: signOutFromGoogle,
                    ),
                    IconButton(icon: Icon(Icons.settings), onPressed: () {

                    }),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text("내가 만든 악보", style: _headerStyle),
              // TODO: 내가 만든 악보가 없으면, '내가 만든 악보가 없어요' '첫 악보 만들러 가기' '악보 만들기 튜토리얼' 등 기능 넣기
              SizedBox(height: 240),
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
}
