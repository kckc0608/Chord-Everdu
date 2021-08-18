import 'package:chord_everdu/page/group_detail.dart';
import 'package:flutter/material.dart';
class GroupListItem extends StatelessWidget {
  final String name, groupID;

  const GroupListItem({
    Key? key,
    required this.groupID,
    required this.name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return GroupDetail(groupName: name, groupID: groupID);
            })
        );
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}