import 'package:chord_everdu/page/group/widget/new_group_dialog.dart';
import 'package:flutter/material.dart';

class GroupAddFloatingButton extends StatelessWidget {
  const GroupAddFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const NewGroupDialog(),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
