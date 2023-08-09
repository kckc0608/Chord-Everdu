import 'package:flutter/material.dart';
enum TagContent { level1, level2, level3, kpop }
class Tag extends StatelessWidget {
  final TagContent tagContent;
  const Tag({super.key, required this.tagContent});


  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    String label;
    switch(tagContent) {
      case TagContent.level1:
        backgroundColor = Colors.lightGreen;
        label = "Lv.1";
        break;
      case TagContent.level2:
        backgroundColor = Colors.orange;
        label = "Lv.2";
        break;
      case TagContent.level3:
        backgroundColor = Colors.redAccent;
        label = "Lv.3";
        break;
      case TagContent.kpop:
        backgroundColor = Colors.cyan;
        label = "K-POP";
      default:
        backgroundColor = Colors.grey;
        label = "Default";
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Chip(
        label: Text(label),
        backgroundColor: backgroundColor,
      ),
    );
    return const Placeholder();
  }
}
