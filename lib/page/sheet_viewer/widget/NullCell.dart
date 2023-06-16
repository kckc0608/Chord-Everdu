import 'package:flutter/material.dart';

class NullCell extends StatelessWidget {
  final Color color;
  const NullCell({Key? key, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width+100,
      //height: 40,
    );
  }
}
