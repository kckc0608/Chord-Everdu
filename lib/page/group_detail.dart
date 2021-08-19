import 'package:chord_everdu/custom_widget/group/search_sheet_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class GroupDetail extends StatefulWidget {
  final String groupName;
  final String groupID;
  const GroupDetail({
    Key? key,
    required this.groupName,
    required this.groupID,
  }) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {

  late String groupName;
  int dropDownValue = 1;
  List<String> tabs = ["1", "2", "3"];

  late List<dynamic> members;
  late DocumentReference _database;

  TextStyle _headerStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    groupName = widget.groupName;
    _database = FirebaseFirestore.instance.collection('group_list').doc(widget.groupID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: SafeArea(child: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: StreamBuilder<DocumentSnapshot>(
            stream: _database.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());

              var doc = snapshot.data!.data() as Map<String, dynamic>;
              members = doc['member'];

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text("멤버 (" + members.length.toString() + ")", style: _headerStyle),
                  Wrap(
                    children: members.map((memberEmail) => Text(memberEmail)).toList(),
                  ),
                  Row(
                    children: [
                      Text("일정", style: _headerStyle),
                      SizedBox(width: 20),
                      DropdownButton<int>(
                        items: [
                          DropdownMenuItem(child: Text("아가페 8/15 콘티"), value: 1),
                          DropdownMenuItem(child: Text("2"), value: 2),
                          DropdownMenuItem(child: Text("3"), value: 3),
                          DropdownMenuItem(child: Text("4"), value: 4),
                        ],
                        onChanged: (value) {
                          setState(() {
                            dropDownValue = value!;
                          });
                        },
                        value: dropDownValue,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text("악보", style: _headerStyle),
                      TextButton(onPressed: () {
                        showDialog(context: context, builder: (context) => SimpleDialog(
                          children: [
                            TextButton(onPressed: () {
                              Navigator.of(context).pop();
                              showDialog(context: context, builder: (context) => SearchSheetDialog());
                            }, child: Text("검색해서 추가하기")),
                            TextButton(onPressed: () {}, child: Text("내가 만든 악보에서 추가하기")),
                            TextButton(onPressed: () {}, child: Text("좋아요 표시한 악보에서 추가하기")),
                            TextButton(onPressed: () {}, child: Text("직접 만들기")),
                          ],
                        ));
                      }, child: Text("악보 추가"))
                    ],
                  ),
                  Expanded(
                    child: ListView(

                    ),
                  ),
                ],
              );
            }
          ),
        )
      ))
    );
  }
}