import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
class DottedButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;
  const DottedButton({
    Key? key,
    required this.onTap,
    required this.child,
    this.padding,
    this.borderColor,
  }) : super(key: key);

  @override
  _DottedButtonState createState() => _DottedButtonState();
}

class _DottedButtonState extends State<DottedButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        color: widget.borderColor ?? Colors.black,
        dashPattern: [3, 3],
        strokeWidth: 1.5,
        radius: Radius.circular(4.0),
        padding: widget.padding ?? EdgeInsets.zero,
        child: widget.child,
      ),
    );
  }
}
