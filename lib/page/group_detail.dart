import 'package:chord_everdu/custom_widget/dynamic_tab.dart';
import 'package:flutter/material.dart';
class GroupDetail extends StatefulWidget {
  final String groupName;
  const GroupDetail({
    Key? key,
    required this.groupName,
  }) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {

  late String groupName;
  int dropDownValue = 1;
  List<String> tabs = ["1", "2", "3"];
  List<String> members = [];

  @override
  void initState() {
    super.initState();
    groupName = widget.groupName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(groupName),
      ),
      body: SafeArea(child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("멤버 (" + members.length.toString() + ")", style: TextStyle(fontSize: 16)),
            Row(
              children: [
                Text("일정", style: TextStyle(fontSize: 16)),
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
            Text("악보", style: TextStyle(fontSize: 16)),
            Expanded(
              child: CustomTabView(
                itemCount: tabs.length,
                tabBuilder: (context, index) => Tab(text: tabs[index],),
                pageBuilder: (context, index) => Container(
                  color: Colors.black12,
                ),
              ),
            ),
          ],
        )
      ))
    );
  }
}