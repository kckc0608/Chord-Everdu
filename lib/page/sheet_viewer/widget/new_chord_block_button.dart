import 'package:chord_everdu/page/sheet_viewer/widget/new_chord_blcok_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class NewChordBlockButton extends StatelessWidget {
  const NewChordBlockButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          showDialog(context: context, builder: (context) {
            return const NewChordBlockDialog();
          });
        },
        child: DottedBorder(
          padding: const EdgeInsets.all(8.0),
          color: Colors.grey,
          borderType: BorderType.RRect,
          dashPattern: const [3, 3],
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
