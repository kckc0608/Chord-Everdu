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
      //color: Colors.yellow,
      padding: const EdgeInsets.all(8.0),
      child: const Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 0, 8),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 4, 0),
                  child: Text("change block name"),
                ),
                InkWell(
                  child: Icon(Icons.edit_outlined),
                ),
                InkWell(
                  child: Icon(Icons.delete_forever_outlined, color: Colors.red,),
                )
              ],
            ),
          ),
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
