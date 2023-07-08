import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GroupDetail extends StatelessWidget {
  final String groupID, groupName;
  const GroupDetail({super.key, required this.groupName, required this.groupID});

  @override
  Widget build(BuildContext context) {
    int dropDownValue = 1;
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('group_list').doc(groupID).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var doc = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> members = doc['member'];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "멤버 (${members.length})",
                      //style: _headerStyle,
                    ),
                    Wrap(
                      children: members.map((memberEmail) => Text(memberEmail)).toList(),
                    ),
                    Row(
                      children: [
                        Text("일정",
                            // style: _headerStyle
                        ),
                        DropdownButton<int>(
                          items: [
                            DropdownMenuItem(child: Text("아가페 8/15 콘티"), value: 1),
                            DropdownMenuItem(child: Text("2"), value: 2),
                            DropdownMenuItem(child: Text("3"), value: 3),
                            DropdownMenuItem(child: Text("4"), value: 4),
                          ],
                          onChanged: (value) {
                            // setState(() {
                            dropDownValue = value!;
                            // });
                          },
                          value: dropDownValue,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Text("악보", style: _headerStyle),
                        TextButton(onPressed: () {
                          showDialog(context: context, builder: (context) => SimpleDialog(
                            children: [
                              TextButton(
                                child: const Text("검색해서 추가하기"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  //showDialog(context: context, builder: (context) => SearchSheetDialog());
                                },
                              ),
                              TextButton(onPressed: () {}, child: Text("내가 만든 악보에서 추가하기")),
                              TextButton(onPressed: () {}, child: Text("좋아요 표시한 악보에서 추가하기")),
                              TextButton(onPressed: () {}, child: Text("직접 만들기")),
                            ],
                          ));
                        }, child: const Text("악보 추가"))
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
        ),
      ),
    );
  }
}
