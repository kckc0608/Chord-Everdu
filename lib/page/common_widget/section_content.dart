import 'package:flutter/material.dart';

class SectionContent extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? contentPadding;

  const SectionContent(
      {super.key, required this.child, this.height, this.contentPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: contentPadding ?? const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, color: Colors.black12),
        ),
        child: child,
      ),
    );
  }
}
