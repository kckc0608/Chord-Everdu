import 'package:chord_everdu/data_class/chord.dart';
import 'package:flutter/material.dart';

class ChordCell extends StatefulWidget {
  final Chord? chord;
  final String? lyric;

  const ChordCell({
    Key? key,
    required this.chord,
    required this.lyric,
  }) : super(key: key);

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
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36.0),
              child: GestureDetector(
                onTap: () {
                  // chord keyboard open
                },
                child: Text(widget.chord!.toStringChord(), style: const TextStyle(fontSize: 16)),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 36.0),
              child: Text(widget.lyric!, style: const TextStyle(fontSize: 16)),
            ),
          ],      ),
      ),
    );
  }
}
