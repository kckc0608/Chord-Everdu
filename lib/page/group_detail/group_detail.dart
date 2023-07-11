import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class GroupDetail extends StatefulWidget {
  final String groupID, groupName;
  const GroupDetail({super.key, required this.groupName, required this.groupID});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  int dropDownValue = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('group_list').doc(widget.groupID).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var doc = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> members = doc['member'];
                List<dynamic> sheetGroups = doc['sheet_groups'];

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        "멤버 (${members.length})",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Wrap(
                      children: members.map((memberEmail) => Text(memberEmail)).toList(),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("일정",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: DropdownButton2(
                            items: List.generate(sheetGroups.length, (index) =>
                                DropdownMenuItem(
                                  child: Text(sheetGroups[index]["group_name"]),
                                  value: index,
                                )),
                            onChanged: (value) {
                              setState(() {
                                dropDownValue = value!;
                              });
                            },
                            value: dropDownValue,
                            style: Theme.of(context).textTheme.titleSmall,
                            isDense: true,
                            underline: Container(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text("악보", style: Theme.of(context).textTheme.titleMedium),
                        ),
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
                      child: ListView.separated(
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.yellow,
                            child: ListTile(
                              title: Text(sheetGroups[dropDownValue]['sheets'][index]['title'], style: Theme.of(context).textTheme.titleSmall,),
                              subtitle: Text("singer"),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: sheetGroups[dropDownValue]['sheets'].length,
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
