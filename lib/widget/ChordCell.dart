import 'package:flutter/material.dart';

class ChordCell extends StatefulWidget {
  const ChordCell({Key? key}) : super(key: key);

  @override
  State<ChordCell> createState() => _ChordCellState();
}

class _ChordCellState extends State<ChordCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Text("chord", style: TextStyle(fontSize: 16)),
          ),
          Text("lyric", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
