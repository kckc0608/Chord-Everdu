import 'package:flutter/material.dart';

enum TagContent {
  noTag(
    displayName: '',
    backgroundColor: Colors.transparent,
  ),
  level1(
    displayName: 'Lv.1',
    backgroundColor: Colors.lightGreen,
  ),
  level2(
    displayName: 'Lv.2',
    backgroundColor: Colors.orange,
  ),
  level3(
    displayName: 'Lv.3',
    backgroundColor: Colors.redAccent,
  ),
  kpop(
    displayName: 'K-POP',
  ),
  jpop(
    displayName: 'J-POP',
  ),
  pop(
    displayName: 'POP',
  ),
  ccm(
    displayName: 'CCM',
  ),
  hiphop(
    displayName: 'Hip-Hop',
  );

  const TagContent({
    required this.displayName,
    this.backgroundColor = Colors.cyan,
  });

  final String displayName;
  final Color backgroundColor;
}