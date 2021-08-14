import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';



class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("로그인이 필요합니다.", style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image.network('https://littledeep.com/wp-content/uploads/2020/09/google-icon-styl.png'),
                ),
                Text("Google Account"),
              ],
            ),
            onPressed: signInWithGoogle,
          ),
          /// 카카오 로그인 구현에 문제가 존재
          /*ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.yellow),
              foregroundColor: MaterialStateProperty.all(Colors.black),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 35,
                  height: 35,
                  child: Image.network('https://littledeep.com/wp-content/uploads/2020/09/google-icon-styl.png'),
                ),
                Text("Kakao Account"),
              ],
            ),
            onPressed: signInWithKakao,
          ),*/
        ],
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    /// 구글 계정으로 로그인 후, 로그인 계정 정보 저장
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    /// 구글 로그인으로 얻은 구체적인 인증 정보를 저장
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
    /// 파이어 베이스에 접속하는데 사용되는 Credential 생성
    final AuthCredential credential = GoogleAuthProvider.credential(
      /// 이 앱이 구글에 요청하는데 사용하는 accessToken 과, 유저를 구분하는 ID 토큰을 가지고 credential (일종의 방문증) 생성
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    /// credential 을 사용하여 FirebaseAuth 에 로그인
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithKakao() async {
    final clientState = Uuid().v4();
    final url = Uri.https('kauth.kakao.com', '/oauth/authorize', {
      'response_type': 'code',
      'client_id': "0587cde6a00f92865dccc71f96e2d89d",
      'response_mode': 'form_post',
      'redirect_uri': 'http://193.122.103.127/callbacks/kakao/sign_in',
      'state': clientState,
    });

    final result = await FlutterWebAuth.authenticate(
        url: url.toString(),
        callbackUrlScheme: "webauthcallback");
    final body = Uri.parse(result).queryParameters;

    print("code");
    print(body["code"]);

    final tokenUrl = Uri.https('kauth.kakao.com', '/oauth/token', {
      'grant_type': 'authorization_code',
      'client_id': "0587cde6a00f92865dccc71f96e2d89d",
      'redirect_uri': 'http://193.122.103.127/callbacks/kakao/sign_in',
      'code': body["code"],
    });



    var responseTokens = await http.post(tokenUrl);
    print("responseTokens");
    print(responseTokens.body);
    Map<String, dynamic> bodys = json.decode(responseTokens.body);

    /// 플러터 http 모듈 이슈로 이 아래 단계에서
    /// [ERROR:flutter/lib/ui/ui_dart_state.cc(199)] Unhandled Exception: Connection closed before full header was received
    /// 이 오류가 발생함

    var response = await http.post(
        Uri.http("193.122.103.127", "/callbacks/kakao/token"),
        body: {"accessToken": bodys['access_token']}
        );

    print("body : " + response.body.toString());
    return FirebaseAuth.instance.signInWithCustomToken(response.body);
  }
}
