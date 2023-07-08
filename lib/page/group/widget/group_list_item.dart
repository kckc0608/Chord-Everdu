import 'package:chord_everdu/page/group_detail/group_detail.dart';
import 'package:flutter/material.dart';

class GroupListItem extends StatelessWidget {
  final String groupID, groupName;
  const GroupListItem({super.key, required this.groupID, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GroupDetail(
            groupName: groupName,
            groupID: groupID,
          ),
        ));
      },
      child: Container(
        height: 40,
        width: 40,
        color: Colors.yellow,
        child: Row(
          children: [
            Text(groupName),
          ],
        ),
      ),
    );
  }
}
