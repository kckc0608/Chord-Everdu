import 'package:chord_everdu/delegate/sheet_search_for_group_set_list_delegate.dart';
import 'package:chord_everdu/page/common_widget/section_content.dart';
import 'package:chord_everdu/page/common_widget/section_title.dart';
import 'package:chord_everdu/page/group/group.dart';
import 'package:chord_everdu/page/group_detail/widget/add_new_member_dialog.dart';
import 'package:chord_everdu/page/group_detail/widget/delete_group_check_dialog.dart';
import 'package:chord_everdu/page/group_detail/widget/delete_schedule_check_dialog.dart';
import 'package:chord_everdu/page/group_detail/widget/group_detail_sheet_list_item.dart';
import 'package:chord_everdu/page/group_detail/widget/manager_list_item.dart';
import 'package:chord_everdu/page/group_detail/widget/member_list_item.dart';
import 'package:chord_everdu/page/group_detail/widget/new_schecule_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class GroupDetail extends StatefulWidget {
  final String groupID, groupName;

  const GroupDetail({super.key, required this.groupName, required this.groupID});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

enum GroupAuthority { manager, member, reader }

class _GroupDetailState extends State<GroupDetail> {
  int dropDownValue = 0;
  GroupAuthority groupAuthority = GroupAuthority.reader;
  final _db = FirebaseFirestore.instance;
  final User user = FirebaseAuth.instance.currentUser!;
  late VoidCallback onDeleteGroup;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _db.collection('group_list').doc(widget.groupID).snapshots(),
        builder: (context, snapshot) {
          List<dynamic> members = [];
          List<dynamic> managers = [];

          if (snapshot.hasData) {
            var doc = snapshot.data!.data() as Map<String, dynamic>;
            members = doc['member'];
            managers = doc['manager'];
          }

          onDeleteGroup = () async {
            await FirebaseFirestore.instance.collection('group_list').doc(widget.groupID).delete().then((value) {
              Logger().i("그룹이 삭제되었습니다.");

              /// 그룹 하나 삭제하면 멤버 돌면서 그 멤버의 group_in을 도는게 맞나
              for (String userEmail in members) {
                _db.collection('user_list').doc(userEmail).update({
                  "group_in": FieldValue.arrayRemove([
                    {
                      "group_id": widget.groupID,
                      "group_name": widget.groupName,
                    }
                  ])
                }).then((value) => Logger().i("유저에서도 그룹 삭제됨"));
              }

              for (String userEmail in managers) {
                _db.collection('user_list').doc(userEmail).update({
                  "group_in": FieldValue.arrayRemove([
                    {
                      "group_id": widget.groupID,
                      "group_name": widget.groupName,
                    }
                  ])
                }).then((value) => Logger().i("유저에서도 그룹 삭제됨"));
              }
            }, onError: (e) => Logger().e(e));
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          };

          if (managers.contains(user.email!)) {
            groupAuthority = GroupAuthority.manager;
          } else if (members.contains(user.email!)) {
            groupAuthority = GroupAuthority.member;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.groupName),
              actions: groupAuthority == GroupAuthority.manager
                  ? [
                      IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => DeleteGroupCheckDialog(
                                groupID: widget.groupID,
                                onDeleteGroup: onDeleteGroup,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete,
                          ))
                    ]
                  : null,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              SectionTitle("멤버 (${members.length + managers.length})"),
                              groupAuthority == GroupAuthority.manager
                                  ? TextButton(
                                      child: const Text(
                                        "멤버 추가",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AddNewMemberDialog(groupID: widget.groupID),
                                        );
                                      },
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          ),
                          Wrap(
                            children: managers
                                .map((managerEmail) => ManagerListItem(
                                      managerEmail: managerEmail,
                                    ))
                                .toList(),
                          ),
                          Wrap(
                            children: members
                                .map((memberEmail) => MemberListItem(
                                      memberEmail: memberEmail,
                                      groupID: widget.groupID,
                                      groupAuthority: groupAuthority,
                                    ))
                                .toList(),
                          ),
                          Expanded(
                            child: StreamBuilder(
                              stream:
                                  _db.collection('group_list').doc(widget.groupID).collection('set_lists').snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                List<QueryDocumentSnapshot> setLists = snapshot.data!.docs;

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
                                                    items: List.generate(
                                                        setLists.length,
                                                        (index) => DropdownMenuItem(
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
                                                : const SizedBox(
                                                    height: 24,
                                                    width: 70,
                                                    child: Center(child: Text("일정 없음")),
                                                  ),
                                          ),
                                        ),
                                        groupAuthority == GroupAuthority.manager
                                            ? TextButton(
                                                child: const Text(
                                                  "일정 추가",
                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => NewScheduleDialog(
                                                      groupID: widget.groupID,
                                                    ),
                                                  );
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                        groupAuthority == GroupAuthority.manager
                                            ? TextButton(
                                                child: const Text("일정 삭제",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold, color: Colors.redAccent)),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => DeleteScheduleCheckDialog(onDeleteGroup: () {
                                                      _db
                                                          .collection('group_list')
                                                          .doc(widget.groupID)
                                                          .collection('set_lists')
                                                          .doc(setLists[dropDownValue].id)
                                                          .delete()
                                                          .then((value) {
                                                        setState(() {
                                                          dropDownValue = 0;
                                                        });
                                                        Logger().i("일정이 삭제되었습니다.");
                                                        Navigator.of(context).pop();
                                                      }, onError: (e) => Logger().e(e));
                                                    }),
                                                  );
                                                },
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        const SectionTitle("악보"),
                                        groupAuthority == GroupAuthority.manager
                                            ? TextButton(
                                                onPressed: setLists.isNotEmpty
                                                    ? () {
                                                        showSearch(
                                                            context: context,
                                                            delegate: SheetSearchFroGroupSetListDelegate(
                                                              groupID: widget.groupID,
                                                              setList: setLists[dropDownValue].id,
                                                            ));
                                                      }
                                                    : null,
                                                child: const Text("악보 추가",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    )))
                                            : const SizedBox.shrink(),
                                      ],
                                    ),
                                    Expanded(
                                      child: SectionContent(
                                        contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: setLists.isNotEmpty
                                            ? StreamBuilder(
                                                stream: _db
                                                    .collection('group_list')
                                                    .doc(widget.groupID)
                                                    .collection('set_lists')
                                                    .doc(setLists[dropDownValue].id)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                    return const Center(child: CircularProgressIndicator());
                                                  }
                                                  List<dynamic> sheets = snapshot.data!.data()!['sheets'];
                                                  if (sheets.isEmpty) {
                                                    return const Center(child: Text("악보가 없습니다."));
                                                  }
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
                                                              onDelete: groupAuthority == GroupAuthority.manager
                                                                  ? () {
                                                                      sheets.removeAt(index);
                                                                      _db
                                                                          .collection('group_list')
                                                                          .doc(widget.groupID)
                                                                          .collection('set_lists')
                                                                          .doc(setLists[dropDownValue].id)
                                                                          .update({"sheets": sheets}).then(
                                                                        (value) => Logger().i("set list updated"),
                                                                        onError: (e) {
                                                                          Logger().e(e);
                                                                        },
                                                                      );
                                                                    }
                                                                  : null,
                                                            );
                                                          });
                                                    },
                                                    separatorBuilder: (context, index) => const Divider(),
                                                    itemCount: sheets.length,
                                                  );
                                                })
                                            : const Center(
                                                child: Text("일정이 없습니다.\n일정을 추가해주세요.", textAlign: TextAlign.center),
                                              ),
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        });
  }
}
