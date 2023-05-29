import 'package:chord_everdu/page/sheet_viewer/widget/ChordBlock.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/chord_keyboard/chord_keyboard.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/new_chord_block_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data_class/chord.dart';
import '../../data_class/sheet.dart';
import '../../data_class/sheet_data.dart';

class SheetViewer extends StatefulWidget {
  final String sheetID;
  final String title;

  const SheetViewer({
    Key? key,
    required this.sheetID,
    required this.title,
  }) : super(key: key);

  @override
  State<SheetViewer> createState() => _SheetViewerState();
}

class _SheetViewerState extends State<SheetViewer> {
  late int _songKey;

  @override
  void initState() {
    super.initState();
    SheetData sheetData = getSheetDataFromDB();
    setSheetToProvider(sheetData);
  }

  @override
  Widget build(BuildContext context) {
    int blockCount = context.select((Sheet sheet) => sheet.chords.length);
    _songKey = context.select((Sheet s) => s.songKey);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(context: context, builder: (_) => AlertDialog(
                title: const Text("취소"),
                content: const Text("악보 작성 페이지를 나가시겠습니까?"),
                actions: [
                  TextButton(child: const Text("취소"),onPressed: () {
                    Navigator.of(context).pop();
                  }),
                  TextButton(child: const Text("확인"),onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }),
                  // TODO : 뒤로 가기 버튼 작업을 해줘야 함.
                ],
              ));
            },
          ),
          actions: [],
        ),
        body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      itemCount: blockCount+1,
                      itemBuilder: (context, index) {
                        return index == blockCount
                            ? const NewChordBlockButton()
                            : ChordBlock(blockID: index);
                        },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        context.read<Sheet>().addCell(
                          context.read<Sheet>().selectedBlockIndex,
                          Chord(),
                          "",
                        );
                      });
                    },
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.arrow_downward_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.text_rotation_none),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {});
                    },
                    icon: const Icon(Icons.format_textdirection_r_to_l_outlined),
                  ),
                ],
              ),
            ChordKeyboard(insertAllFunction: (){}),
              //   insertAllFunction: () {
              // setState(() {
              //   int _select = context.read<Sheet>().selectedCellIndex + 1;
              //   for (int i = 0; i < global.recentChord.length; i++) {
              //     context.read<Sheet>().addCell(
              //       index: _select + i,
              //       chord: Chord.fromMap(global.recentChord[i].toMap()),
              //     );
              //   }
              // });
            //}),

          ],
        )));
  }

  SheetData getSheetDataFromDB() {
    // TODO: DB 연동
    if (widget.sheetID.isEmpty) {
      return SheetData(chordData: "", lyricData: "");
    }
    return SheetData(
      chordData: 'C|C#|Cadd2|C/E',
      lyricData: 'hi|hi|hi|hihi',
    );
  }

  void setSheetToProvider(SheetData sheetData) {
    context.read<Sheet>().chords.clear();
    context.read<Sheet>().lyrics.clear();
    context.read<Sheet>().selectedCellIndex = -1;
    context.read<Sheet>().selectedBlockIndex = -1;
    context.read<Sheet>().copyFromData(sheetData);
  }
}
