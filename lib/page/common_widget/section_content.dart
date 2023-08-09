import 'package:flutter/material.dart';

class SectionContent extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  const SectionContent(
      {super.key, required this.child, this.height, this.margin, this.contentPadding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.all(8.0),
      child: Container(
        height: height,
        padding: contentPadding,
        decoration: BoxDecoration(
          border: Border.all(style: BorderStyle.solid, color: Colors.black12),
        ),
        child: child,
      ),
    );
  }
}
