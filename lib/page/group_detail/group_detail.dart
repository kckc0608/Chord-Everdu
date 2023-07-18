import 'package:chord_everdu/delegate/sheet_search_for_group_set_list_delegate.dart';
import 'package:chord_everdu/page/common_widget/section_title.dart';
import 'package:chord_everdu/page/group_detail/widget/group_detail_sheet_list_item.dart';
import 'package:chord_everdu/page/group_detail/widget/new_schecule_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GroupDetail extends StatefulWidget {
  final String groupID, groupName;
  const GroupDetail({super.key, required this.groupName, required this.groupID});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  int dropDownValue = 0;
  final _db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: StreamBuilder<DocumentSnapshot>(
              stream: _db.collection('group_list').doc(widget.groupID).snapshots(),
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
                    SectionTitle("멤버 (${members.length})"),
                    Wrap(
                      children: members.map((memberEmail) => Text(memberEmail)).toList(),
                    ),
                    Expanded(
                      child: StreamBuilder(
                          stream: _db.collection('group_list')
                              .doc(widget.groupID)
                              .collection('set_lists').snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          List<QueryDocumentSnapshot> setLists = snapshot.data!.docs;
                          print(setLists);

                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const SectionTitle("일정"),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          style: BorderStyle.solid,
                                        ),
                                      ),
                                      child: setLists.isNotEmpty 
                                          ? DropdownButton2<int>(
                                              items: List.generate(setLists.length, (index) =>
                                                DropdownMenuItem(
                                                  value: index,
                                                  child: Text(setLists[index].id),
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
                                            )
                                          :
                                      const SizedBox(
                                        height: 24,
                                        width: 70,
                                        child: Center(child: Text("일정 없음")),
                                      ),
                                    ),
                                  ),
                                  TextButton(onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => NewScheduleDialog(
                                        groupID: widget.groupID,
                                      ),
                                    );
                                  }, child: const Text("일정 추가"))
                                ],
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  const SectionTitle("악보"),
                                  TextButton(onPressed: () {
                                    showSearch(context: context, delegate: SheetSearchFroGroupSetListDelegate(
                                      groupID: widget.groupID,
                                      setList: setLists[dropDownValue].id,
                                    ));
                                  }, child: const Text("악보 추가"))
                                ],
                              ),
                              setLists.isNotEmpty ?
                              Expanded(
                                child: StreamBuilder(
                                    stream: _db.collection('group_list').doc(widget.groupID).collection('set_lists').doc(setLists[dropDownValue].id).snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      List<dynamic> sheets = snapshot.data!.data()!['sheets'];
                                      return ListView.separated(
                                        itemBuilder: (context, index) {
                                          DocumentReference ref = sheets[index];
                                          return StreamBuilder(
                                              stream: ref.snapshots(),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState == ConnectionState.waiting) {
                                                  return const Center(child: CircularProgressIndicator());
                                                }
                                                var sheet = snapshot.data!.data() as Map<String, dynamic>;
                                                return GroupDetailSheetList(
                                                  sheetID: ref.id,
                                                  title: sheet['title'],
                                                  singer: sheet["singer"],
                                                  onDelete: () {
                                                    sheets.removeAt(index);
                                                    _db.collection('group_list')
                                                        .doc(widget.groupID)
                                                        .collection('set_lists')
                                                        .doc(setLists[dropDownValue].id)
                                                        .update({"sheets": sheets})
                                                        .then(
                                                          (value) => Logger().i("set list updated"),
                                                      onError: (e) {
                                                        Logger().e(e);
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                          );
                                        },
                                        separatorBuilder: (context, index) => const Divider(),
                                        itemCount: sheets.length,
                                      );
                                    }
                                ),
                              ) :
                              const Expanded(child: Center(child: Text("일정이 없습니다."),))
                            ],
                          );
                        }
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
