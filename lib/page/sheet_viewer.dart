import 'package:chord_everdu/widget/ChordBlock.dart';
import 'package:chord_everdu/widget/chord_keyboard/chord_keyboard.dart';
import 'package:chord_everdu/widget/new_chord_block_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data_class/chord.dart';
import '../data_class/sheet.dart';
import '../data_class/sheet_data.dart';

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

  @override
  void initState() {
    super.initState();
    SheetData sheetData = getSheetDataFromDB();
    setSheetToProvider(sheetData);
  }

  @override
  Widget build(BuildContext context) {
    int blockCount = context.watch<Sheet>().chords.length;
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
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
                    onPressed: () {
                      context.read<Sheet>().addCell(
                        context.read<Sheet>().selectedBlockIndex,
                        Chord(),
                        "",
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                      });
                    },
                    icon: const Icon(Icons.remove),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {});
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
    return SheetData('C|C#', 'hi|hi');
  }

  void setSheetToProvider(SheetData sheetData) {
    context.read<Sheet>().chords.clear();
    context.read<Sheet>().lyrics.clear();
    context.read<Sheet>().copyFromData(sheetData);

  }
}
