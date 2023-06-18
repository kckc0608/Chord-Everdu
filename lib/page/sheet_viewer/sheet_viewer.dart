import 'package:chord_everdu/page/sheet_viewer/widget/ChordBlock.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/chord_keyboard/chord_keyboard.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/new_chord_block_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.sheetID.isNotEmpty) {
      fetchAndSetSheetToProvider();
    } else {
      initializeSheet();
    }
  }


  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int blockCount = context.select((Sheet sheet) => sheet.chords.length);
    int selectedCell = context.select((Sheet sheet) => sheet.selectedCellIndex);
    int selectedBlock = context.read<Sheet>().selectedBlockIndex;
    Logger().d(context.read<Sheet>().chords);
    _songKey = context.select((Sheet s) => s.songKey);

    if (selectedCell > -1 && selectedBlock > -1) {
      _textController.text = context.read<Sheet>().lyrics[selectedBlock][selectedCell] ?? "";
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: const Text("취소"),
                        content: const Text("악보 작성 페이지를 나가시겠습니까?"),
                        actions: [
                          TextButton(
                              child: const Text("취소"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          TextButton(
                              child: const Text("확인"),
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              }),
                          // TODO : 뒤로 가기 버튼 작업을 해줘야 함.
                        ],
                      ));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                showDialog(context: context, builder: (context) => AlertDialog(
                  title: const Text("저장"),
                  content: const Text("저장하고 화면을 나가시겠습니까?"),
                  actions: [
                    TextButton(
                      child: const Text("취소"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text("저장"),
                      onPressed: () {
                        if (widget.sheetID.isNotEmpty) {
                          saveSheet();
                        } else {
                          addSheet(); // TODO : 악보 정보만 추가되고, 악보 이름, 가수 정보는 추가가 안됨.
                        }
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
              },
            ),
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('sheet_list')
                      .where("sheet_id", isEqualTo: widget.sheetID)
                      .get(), /// 앱을 다시 빌드할 때마다 이걸 가져오는 건 비효율적 같아서 initState 부분으로 빼고 싶은데, 그러면 로딩창을 못띄울 거 같음.
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: blockCount + 1,
                        itemBuilder: (context, index) {
                          return index == blockCount
                              ? const NewChordBlockButton()
                              : ChordBlock(blockID: index);
                        },
                      );
                    } else {
                      return const Text("loading sheet");
                    }
                  }
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.add_box_outlined,
                  ),
                  color: Colors.green,
                  onPressed: selectedCell > -1
                      ? () {
                        setState(() {
                          context.read<Sheet>().addCell(
                            context.read<Sheet>().selectedBlockIndex,
                            Chord(),
                            "",
                          );
                        });
                      }
                      : null,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.indeterminate_check_box_outlined,
                  ),
                  color: Colors.red,
                  onPressed: selectedCell > -1
                      ? () {
                        setState(() {
                          context.read<Sheet>().removeCell(
                            blockID: context.read<Sheet>().selectedBlockIndex,
                            cellID: selectedCell,
                          );
                          context.read<Sheet>().setSelectedCellIndex(-1);
                        });
                      }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.subdirectory_arrow_left),
                  onPressed: selectedCell > -1 ? () {
                    setState(() {
                      context.read<Sheet>().addNewLineCell(
                        blockID: context.read<Sheet>().selectedBlockIndex,
                        cellID: selectedCell,
                      );
                    });
                  } : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: selectedCell > 0 ? () {
                    setState(() {
                      context.read<Sheet>().removePreviousCell(
                        blockID: context.read<Sheet>().selectedBlockIndex,
                        cellID: selectedCell,
                      );
                    });
                  } : null,
                ),
                IconButton(
                  icon: const Icon(Icons.text_rotation_none),
                  onPressed: selectedCell > -1 ? () {
                    setState(() {});
                  } : null,
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("가사 : ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    Expanded(
                      child: Container(
                        color: Colors.blue[300],
                        child: TextField(
                          controller: _textController,
                          onChanged: (text) {
                            context.read<Sheet>().updateLyric(selectedBlock, selectedCell, text);
                          },
                          keyboardType: TextInputType.text,
                          style: const TextStyle(fontSize: 18),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(4.0),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MediaQuery.of(context).viewInsets.bottom == 0 ? const ChordKeyboard() : const SizedBox.shrink(),
          ],
        )));
  }

  Future<SheetData> fetchSheet() async {
    // TODO: DB 연동
    assert (widget.sheetID.isNotEmpty);
    return await FirebaseFirestore.instance
        .collection('sheet_list')
        .doc(widget.sheetID)
        .get()
        .then((doc) {
          List<String> chords = [];
          List<String> lyrics = [];
          if (doc.exists) {
            var data = doc.data();
            Logger().d(data);
            for (String chordData in data!["chords"]) {
              chords.add(chordData);
            }
            for (String lyricData in data["lyrics"]) {
              lyrics.add(lyricData);
            }
          }
          return SheetData(lyricData: lyrics, chordData: chords);
        });
  }

  void fetchAndSetSheetToProvider() async {
    SheetData sheetData = await fetchSheet();
    Logger().d(sheetData.chordData);
    if (context.mounted) {
      context.read<Sheet>().chords.clear();
      context.read<Sheet>().lyrics.clear();
      context.read<Sheet>().selectedCellIndex = -1;
      context.read<Sheet>().selectedBlockIndex = -1;
      context.read<Sheet>().copyFromData(sheetData);
      setState(() {}); // 이걸 안하면 데이터만 받아 오고 위젯은 다시 안 그리는 경우가 있음
    }
  }

  Map<String, dynamic> convertSheetToSaveData() {
    Map<String, dynamic> data = {};
    data['chords'] = context.read<Sheet>().convertChordsToStringList();
    data['lyrics'] = context.read<Sheet>().convertLyricsToStringList();
    return data;
  }

  void saveSheet() async {
    Map<String, dynamic> data = convertSheetToSaveData();
    if (widget.sheetID.isNotEmpty) {
      await FirebaseFirestore.instance.collection('sheet_list').doc(widget.sheetID).set(
        data, SetOptions(merge: true)
      ).onError((error, stackTrace) => Logger().i(error));
    }
  }

  void addSheet() async {
    Map<String, dynamic> data = convertSheetToSaveData();
    await FirebaseFirestore.instance.collection('sheet_list').add(data);
  }

  void initializeSheet() {
    if (context.mounted) {
      context.read<Sheet>().initializeSheet();
    }
  }
}
