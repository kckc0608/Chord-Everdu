import 'package:flutter/material.dart';

enum TagContent {
  noTag(
    code: 'no_tag',
    displayName: '',
    backgroundColor: Colors.transparent,
  ),
  level1(
    code: 'level1',
    displayName: 'Lv.1',
    backgroundColor: Colors.lightGreen,
  ),
  level2(
    code: 'level2',
    displayName: 'Lv.2',
    backgroundColor: Colors.orange,
  ),
  level3(
    code: 'level3',
    displayName: 'Lv.3',
    backgroundColor: Colors.redAccent,
  ),
  kpop(
    code: 'kpop',
    displayName: 'K-POP',
  ),
  jpop(
    code: 'jpop',
    displayName: 'J-POP',
  ),
  pop(
    code: 'pop',
    displayName: 'POP',
  ),
  ccm(
    code: 'ccm',
    displayName: 'CCM',
  ),
  hiphop(
    code: 'hiphop',
    displayName: 'Hip-Hop',
  );

  const TagContent({
    required this.code,
    required this.displayName,
    this.backgroundColor = Colors.cyan,
  });

  final String code, displayName;
  final Color backgroundColor;
}