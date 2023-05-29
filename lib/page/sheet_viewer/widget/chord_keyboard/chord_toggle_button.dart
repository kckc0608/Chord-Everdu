import 'package:flutter/material.dart';
import 'chord_keyboard.dart';

class ChordToggleButton extends StatelessWidget {
  final void Function(int)? onPressed;
  final List<String> buttonTextList;
  final List<bool> isSelected;
  final int type;

  const ChordToggleButton({
    Key? key,
    this.onPressed,
    required this.buttonTextList,
    required this.isSelected,
    this.type = ChordKeyboard.typeRoot,
  }) : super(key: key);

  Color? setFillColor() {
    if (type == ChordKeyboard.typeRoot) {return Colors.blue[300];}
    else if (type == ChordKeyboard.typeASDA) {return Colors.green[300];}
    else if (type == ChordKeyboard.typeBase) {return Colors.amber[300];}
    else if (type == ChordKeyboard.typeTens) {return Colors.deepOrange[300];}
  }

  Color? setSelectedBorderColor() {
    if (type == ChordKeyboard.typeRoot) {
      return Colors.blue[600];
    } else if (type == ChordKeyboard.typeASDA) {
      return Colors.green[600];
    } else if (type == ChordKeyboard.typeBase) {
      return Colors.amber[600];
    } else if (type == ChordKeyboard.typeTens) {
      return Colors.deepOrange[600];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      constraints: const BoxConstraints(minWidth: 52, minHeight: 52),
      borderWidth: 2.0,
      color: Colors.black38,
      borderColor: Colors.black12,
      selectedColor: Colors.black,
      selectedBorderColor: setSelectedBorderColor(),
      fillColor: setFillColor(),
      isSelected: isSelected,
      onPressed: onPressed,
      children: List.generate(
          isSelected.length,
          (int index) => Text(
              buttonTextList[index],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
      ),
    );
  }
}
