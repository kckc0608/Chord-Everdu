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

  @override
  void initState() {
    super.initState();
    fetchAndSetSheetToProvider();
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
                        saveSheet();
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
                  onPressed: () {},
                  icon: const Icon(Icons.remove),
                ),
                IconButton(
                  onPressed: () {},
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
            ChordKeyboard(insertAllFunction: () {}),
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
            for (String lyricData in data!["lyrics"]) {
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
    }
  }

  void saveSheet() async {
    Map<String, dynamic> data = {};
    data['chords'] = context.read<Sheet>().convertChordsToStringList();
    data['lyrics'] = context.read<Sheet>().convertLyricsToStringList();
    if (widget.sheetID.isNotEmpty) {
      await FirebaseFirestore.instance.collection('sheet_list').doc(widget.sheetID).set(
        data, SetOptions(merge: true)
      ).onError((error, stackTrace) => Logger().i(error));
    }
  }
}
