import 'dart:async';

import 'package:chord_everdu/data_class/sheet_info.dart';
import 'package:chord_everdu/page/common_widget/common_yes_no_dialog.dart';
import 'package:chord_everdu/page/common_widget/loading_circle.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/ChordBlock.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/chord_keyboard/chord_keyboard.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/dialog/edit_sheet_dialog.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/new_chord_block_button.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/dialog/sheet_report_dialog.dart';
import 'package:chord_everdu/page/sheet_viewer/widget/sheet_viewer_control_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../../data_class/chord.dart';
import '../../data_class/sheet.dart';
import '../../data_class/sheet_data.dart';

class SheetViewer extends StatefulWidget {
  final String sheetID;

  const SheetViewer({
    Key? key,
    required this.sheetID,
  }) : super(key: key);

  @override
  State<SheetViewer> createState() => _SheetViewerState();
}

class _SheetViewerState extends State<SheetViewer> {
  late int _sheetKey;
  late SheetInfo sheetInfo;
  late bool isReadOnly;
  late FocusNode lyricFocusNode;
  late ScrollController scrollController;
  final _textController = TextEditingController();
  bool isAutoScroll = false;
  int cursorPos = 0;

  @override
  void initState() {
    super.initState();
    lyricFocusNode = FocusNode();
    scrollController = ScrollController();
    if (widget.sheetID.isNotEmpty) {
      fetchAndSetSheetToProvider();
    } else {
      initializeSheet();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    lyricFocusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int blockCount = context.select((Sheet sheet) => sheet.chords.length);
    int selectedCell = context.select((Sheet sheet) => sheet.selectedCellIndex);
    int selectedBlock = context.read<Sheet>().selectedBlockIndex;

    Logger().i(selectedBlock);

    _sheetKey = context.select((Sheet s) => s.sheetKey);
    sheetInfo = context.select((Sheet sheet) => sheet.sheetInfo);
    isReadOnly = context.read<Sheet>().isReadOnly;

    if (selectedCell > -1 && selectedBlock > -1) {
      _textController.text = context.read<Sheet>().lyrics[selectedBlock][selectedCell] ?? "";
      if (cursorPos <= _textController.text.length) {
        _textController.selection = TextSelection(baseOffset: cursorPos, extentOffset: cursorPos);
      }
    } else {
      _textController.text = "";
    }

    return WillPopScope(
      onWillPop: () async {
        if (isReadOnly) {
          return true;
        }
        bool? isWillPop = await showDialog<bool>(
          context: context,
          builder: (context) => const CommonYesNoDialog(title: "작성 취소", content: "악보 작성 페이지를 나가시겠습니까?"),
        );
        return isWillPop ?? false;
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text(sheetInfo.title),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (isReadOnly) {
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (_) => const CommonYesNoDialog(title: "작성 취소", content: "악보 작성 페이지를 나가시겠습니까?"),
                  ).then((isWillPop) {
                    if (isWillPop) {
                      Navigator.of(context).pop();
                    }
                  });
                }
              },
            ),
            actions: isReadOnly
                ? [
                    PopupMenuButton<String>(
                      offset: const Offset(0, 55),
                      onSelected: (value) {
                        showDialog(
                          context: context,
                          builder: (context) => SheetReportDialog(
                            sheetID: widget.sheetID,
                          ),
                        );
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: "test",
                          child: Text("악보 신고하기"),
                        ),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ]
                : [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => EditSheetDialog(
                            sheetInfo: sheetInfo,
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const CommonYesNoDialog(
                            title: "저장",
                            content: "저장하고 화면을 나가시겠습니까?",
                          ),
                        ).then((isYes) {
                          if (isYes) {
                            saveSheet();
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('sheet_list')
                            .where("sheet_id", isEqualTo: widget.sheetID)
                            .get(),

                        /// 앱을 다시 빌드할 때마다 이걸 가져오는 건 비효율적인 것 같아서 initState 부분으로 빼고 싶은데, 그러면 로딩창을 못띄울 거 같음.
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: isReadOnly ? blockCount : blockCount + 1,
                              itemBuilder: (context, index) {
                                return index == blockCount ? const NewChordBlockButton() : ChordBlock(blockID: index);
                              },
                            );
                          } else {
                            return const LoadingCircle();
                          }
                        }),
                  ),
                ),
                isReadOnly
                    ? SheetViewerControlBar(scrollController: scrollController)
                    : Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0, 0.75),
                            )
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.add_box_outlined,
                                  ),
                                  color: Colors.green,
                                  onPressed: selectedBlock > -1 && selectedCell > -1
                                      ? () {
                                          setState(() {
                                            context.read<Sheet>().addNewCell();
                                            context.read<Sheet>().inputMode = InputMode.root;
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  color: Colors.red,
                                  onPressed: selectedBlock > -1 && selectedCell > 0
                                      ? () {
                                          setState(() {
                                            context.read<Sheet>().removePreviousCell();
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.subdirectory_arrow_left),
                                  onPressed: selectedBlock > -1 &&
                                          selectedCell > 0 &&
                                          !context.read<Sheet>().isPreviousCellIsNewLineCell()
                                      ? () {
                                          setState(() {
                                            context.read<Sheet>().addNewLineCell();
                                          });
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.text_rotation_none),
                                  onPressed: selectedBlock > -1 && selectedCell > -1 && lyricFocusNode.hasFocus
                                      ? () {
                                          setState(() {
                                            context.read<Sheet>().moveLyricToNextCell(
                                                  blockID: selectedBlock,
                                                  cellID: selectedCell,
                                                  selectPosition: _textController.selection.base.offset,
                                                );
                                          });
                                        }
                                      : null,
                                ),
                              ],
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 44),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "가사 : ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: selectedCell > -1 ? Colors.black : Colors.grey),
                                    ),
                                    Expanded(
                                      child: Container(
                                        color: selectedCell > -1 ? Colors.black26 : Colors.black12,
                                        child: TextField(
                                          focusNode: lyricFocusNode,
                                          controller: _textController,
                                          enabled: selectedCell > -1,
                                          onTap: () {
                                            cursorPos = _textController.selection.base.offset;
                                          },
                                          onChanged: (text) {
                                            context.read<Sheet>().updateLyric(selectedBlock, selectedCell, text);
                                          },
                                          keyboardType: TextInputType.text,
                                          style: const TextStyle(fontSize: 18),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            border: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            MediaQuery.of(context).viewInsets.bottom == 0
                                ? const ChordKeyboard()
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
              ],
            ),
          )),
    );
  }

  Future<Map<String, dynamic>> fetchRawSheetData() {
    assert(widget.sheetID.isNotEmpty);
    return FirebaseFirestore.instance.collection('sheet_list').doc(widget.sheetID).get().then((doc) {
      if (doc.exists) {
        var data = doc.data()!;
        return data;
      } else {
        throw Exception("${widget.sheetID}의 데이터가 없습니다.");
      }
    });
  }

  void fetchAndSetSheetToProvider() async {
    Map<String, dynamic> rawData = await fetchRawSheetData();
    SheetInfo sheetInfo = SheetInfo.fromMap(rawData);
    SheetData sheetData = SheetData.fromMap(rawData);
    if (context.mounted) {
      context.read<Sheet>().chords.clear();
      context.read<Sheet>().lyrics.clear();
      context.read<Sheet>().blockNames.clear();
      context.read<Sheet>().selectedCellIndex = -1;
      context.read<Sheet>().selectedBlockIndex = -1;
      context.read<Sheet>().sheetKey = 0;
      context.read<Sheet>().copyFromData(sheetData);
      context.read<Sheet>().updateSheetInfo(sheetInfo);
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
    data["title"] = sheetInfo.title;
    data["singer"] = sheetInfo.singer;
    data["song_key"] = (sheetInfo.songKey + context.read<Sheet>().sheetKey + 12) % 12;
    data["level"] = sheetInfo.level.name;
    data["genre"] = sheetInfo.genre.name;
    data["block_names"] = context.read<Sheet>().blockNames;
    if (widget.sheetID.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('sheet_list')
          .doc(widget.sheetID)
          .set(data, SetOptions(merge: true))
          .onError((error, stackTrace) => Logger().e(error));
    } else {
      data["editor_email"] = FirebaseAuth.instance.currentUser!.email;
      await FirebaseFirestore.instance.collection('sheet_list').add(data);
    }
  }

  void initializeSheet() {
    if (context.mounted) {
      context.read<Sheet>().initializeSheet();
    }
  }
}
