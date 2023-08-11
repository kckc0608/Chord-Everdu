import 'package:chord_everdu/data_class/tag_content.dart';
import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  final TagContent tagContent;
  final bool isSelected;
  final VoidCallback? onTap;
  const Tag({super.key, required this.tagContent, this.onTap, this.isSelected = true});


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Chip(
          label: Text(tagContent.displayName),
          labelStyle: TextStyle(color: isSelected ? Colors.black : Colors.black26),
          backgroundColor: isSelected ? tagContent.backgroundColor : Colors.transparent,
          side: BorderSide(
            color: tagContent.backgroundColor,
            width: 1.4,
          ),
        ),
      ),
    );
    return const Placeholder();
  }
}
