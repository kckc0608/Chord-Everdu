import 'package:flutter/material.dart';

class EditorHelpDialog extends StatelessWidget {
  const EditorHelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("도움말"),
      content: Container(
        width: 320,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text("기본적으로 하나의 칸에 하나의 코드와 가사를 작성하는 방법으로 악보를 작성합니다.\n"),
              Row(
                children: [
                  Icon(Icons.add, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text("현재 선택한 칸의 오른쪽에 새로운 칸을 하나 추가합니다.")
                  )
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.remove, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(child: Text("현재 선택한 칸을 삭제합니다.")),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.arrow_downward_outlined,
                      color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text("현재 선택한 칸과 이후의 칸들을 다음 줄로 내립니다.\n""연속으로 쓸 수 없습니다. 전체 악보를 볼 때 중간에 빈줄을 만드려면 페이지를 나누어야 합니다."))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.arrow_back,
                      color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text("현재 선택한 셀의 왼쪽의 칸을 지웁니다. 만약 줄이 바뀌어있다면 줄바꿈을 취소합니다."))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.text_rotation_none, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                      "현재 커서를 기준으로 오른쪽 가사를 오른쪽 칸으로 이동합니다.""오른쪽 칸에 가사가 이미 있거나 오른쪽에 칸이 없다면 새로운 칸을 추가하여 가사를 이동합니다."))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.format_textdirection_r_to_l_outlined,
                    color: Colors.black,
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text(
                      "현재 커서를 기준으로 왼쪽 가사를 왼쪽 칸의 가사 뒤에 붙입니다.""왼쪽에 칸이 없다면 칸을 새로 추가하여 가사를 이동합니다."))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.edit_outlined, color: Colors.black),
                  SizedBox(width: 10),
                  Expanded(child: Text("현재 블록의 이름을 수정합니다."))
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.delete_forever_outlined, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(child: Text("현재 블록을 삭제합니다."))
                ],
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
