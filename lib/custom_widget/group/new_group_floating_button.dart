import 'package:chord_everdu/page/group_detail.dart';
import 'package:flutter/material.dart';

class NewGroupFloatingButton extends StatelessWidget {
  const NewGroupFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(context: context, builder: (context) {
          return NewGroupInfoDialog();
        });
      },
      child: Icon(Icons.add),
    );
  }
}

class NewGroupInfoDialog extends StatefulWidget {
  const NewGroupInfoDialog({Key? key}) : super(key: key);

  @override
  _NewGroupInfoDialogState createState() => _NewGroupInfoDialogState();
}

class _NewGroupInfoDialogState extends State<NewGroupInfoDialog> {
  bool isPrivate = true;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("새 그룹"),
      content: Container(
        width: 370,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controller,
                style: TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  isCollapsed: true,
                  hintText: "그룹 이름",
                  contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 2),
                ),
              ),
              Row(
                children: [
                  Text("비공개 그룹"),
                  Checkbox(value: isPrivate, onChanged: (isChecked) {
                    setState(() {
                      isPrivate = isChecked!;
                    });
                  }),
                ],
              ),
              Text(
                isPrivate
                  ? "* 초대를 통해서만 그룹에 가입할 수 있습니다."
                  : "* 검색을 통해서 누구나 가입할 수 있습니다.",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => GroupDetail(
            groupName: _controller.text,
          )));
        }, child: Text("확인")),
        TextButton(onPressed: () {
          Navigator.of(context).pop();
        }, child: Text("취소")),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

