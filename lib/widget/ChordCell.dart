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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(),
      ),
      child: Column(
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 36.0),
            child: GestureDetector(
              onTap: () {
                // chord keyboard open
              },
              child: const Padding(
                padding: EdgeInsets.all(2.0),
                child: Text("chord", style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          const Text("lyric", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
