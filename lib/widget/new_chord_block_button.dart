import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class NewChordBlockButton extends StatelessWidget {
  const NewChordBlockButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {},
        child: DottedBorder(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey,
          borderType: BorderType.RRect,
          dashPattern: [3, 3],
          strokeWidth: 1.5,
          radius: const Radius.circular(4.0),
          child: const Center(
            child: Icon(Icons.add_circle_outline, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}