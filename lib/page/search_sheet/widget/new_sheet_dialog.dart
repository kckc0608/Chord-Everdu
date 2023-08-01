import 'package:chord_everdu/data_class/sheet.dart';
import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/page/sheet_viewer/sheet_viewer.dart';
import 'package:provider/provider.dart';
class NewSheetDialog extends StatefulWidget {
  const NewSheetDialog({Key? key}) : super(key: key);

  @override
  _NewSheetDialogState createState() => _NewSheetDialogState();
}

class _NewSheetDialogState extends State<NewSheetDialog> {
  final _minorKeyList = []; // TODO : Minor Key List Set
  final _majorKeyList = ["C", "C#/Db", "D", "Eb", "E", "F", "F#/Gb", "G", "Ab", "A", "Bb", "B"];

  final _controllerForTitle = TextEditingController();
  final _controllerForSinger = TextEditingController();
  final _focusNodeForTitle = FocusNode();
  final _focusNodeForSinger = FocusNode();

  final _formKey = GlobalKey<FormState>();

  int _selectedKey = 0;

  @override
  void dispose() {
    _controllerForSinger.dispose();
    _controllerForTitle.dispose();
    _focusNodeForSinger.dispose();
    _focusNodeForTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("새 악보"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controllerForTitle,
              focusNode: _focusNodeForTitle,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "곡 제목은 필수 입력값입니다.";
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: "곡 제목",
                helperText: "* 필수 입력값입니다.",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                isCollapsed: true,
              ),
              onEditingComplete: () {
                _focusNodeForTitle.unfocus();
              },
              autofocus: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: TextField(
                focusNode: _focusNodeForSinger,
                controller: _controllerForSinger,
                decoration: const InputDecoration(
                  labelText: "가수",
                  border: OutlineInputBorder(),
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                ),
                onEditingComplete: () {
                  _focusNodeForSinger.unfocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: DropdownButtonFormField2(
                style: const TextStyle(fontSize: 18, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: "키",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                  isCollapsed: true,
                ),
                dropdownStyleData: const DropdownStyleData(
                  maxHeight: 200,
                  offset: Offset(0, -2)
                ),
                value: _selectedKey,
                items: _majorKeyList.map((value) {
                  return DropdownMenuItem(
                    value: _majorKeyList.indexOf(value),
                    child: Text(value),
                  );
                }
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKey = int.parse(value.toString());
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("취소"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text("확인"),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              context.read<Sheet>().updateSheetInfo(SheetInfo(
                title: _controllerForTitle.text,
                singer: _controllerForSinger.text,
                songKey: _selectedKey,
              ));
              context.read<Sheet>().isReadOnly = false;
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const SheetViewer(sheetID: "",))
              );
            }
          },
        ),
      ],
    );
  }
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(DiagnosticsProperty<TextEditingController>('_controllerForSinger', _controllerForSinger));
  // }
}