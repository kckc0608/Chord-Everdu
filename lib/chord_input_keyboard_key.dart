import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextKey extends StatelessWidget {
  final String text;
  final ValueSetter<String>? onTextInput;
  final int? flex;

  const TextKey({
    Key? key,
    required this.text,
    this.onTextInput,
    this.flex = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex!,
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Material(
          color: Colors.blue.shade300,
          child: InkWell(
            onTap: () {
              onTextInput?.call(text);
            },
            child: Container(
              child: Center(child: Text(text),),
            ),
          ),
        ),
      ),
    );
  }
}
