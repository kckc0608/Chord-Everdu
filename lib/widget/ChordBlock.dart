import 'package:chord_everdu/widget/ChordCell.dart';
import 'package:flutter/material.dart';

class ChordBlock extends StatefulWidget {
  const ChordBlock({Key? key}) : super(key: key);

  @override
  State<ChordBlock> createState() => _ChordBlockState();
}

class _ChordBlockState extends State<ChordBlock> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.yellow,
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Wrap(
            children: [
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
              ChordCell(),
            ]
          )
        ],
      ),
    );
  }
}
