import 'package:chord_everdu/widget/chord_keyboard/chord_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import 'package:provider/provider.dart';
import '../../data_class/chord.dart';
import '../../data_class/sheet.dart';

class ChordKeyboard extends StatefulWidget {
  const ChordKeyboard({
    Key? key,
    required this.insertAllFunction,
  }) : super(key: key);

  static const typeRoot = 1;
  static const typeASDA = 2;
  static const typeBase = 3;
  static const typeTens = 4;

  final VoidCallback insertAllFunction;

  @override
  _ChordKeyboardState createState() => _ChordKeyboardState();
}

class _ChordKeyboardState extends State<ChordKeyboard> {
  late int _songKey;

  final TextStyle _toggleTextStyle =
  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  String? nowInput; // 현재 입력중인 부분체크
  bool isRootInput = true;

  // currentCell 이 null 이 아닐 때 이 위젯이 생성되기 때문에, 코드는 항상 존재함.
  late Chord _chord;
  late int _nowPage;
  late int _selectedCellIndex;
  late int _selectedBlockIndex;

  List<bool> _rootSelection = [false, false, false, false, false, false, false];
  List<bool> _asdaSelection = [false, false, false, false];
  List<bool> _minorMajorSelection = [false, false];
  List<bool> _numberSelection = [false, false, false, false, false, false, false];
  List<bool> _rootSharpSelection = [false, false];
  List<bool> _tensionSharpSelection = [false, false];
  List<bool> _baseSharpSelection = [false, false, false];

  @override
  Widget build(BuildContext context) {
    _selectedBlockIndex = context.select((Sheet s) => s.selectedBlockIndex);
    _selectedCellIndex = context.select((Sheet s) => s.selectedCellIndex);
    if (_selectedBlockIndex > -1 && _selectedCellIndex > -1) {
      _chord = context.read<Sheet>().chords[_selectedBlockIndex][_selectedCellIndex] ?? Chord();
      setButtonWithChord();
    } else {
      _chord = Chord();
    }

    //if (_selectedIndex < context.select((Sheet s) => s.chords[_nowPage].length))

    // TODO : 현재 코드 조합에 따라 now Input 설정
    print("Now Input is $nowInput");

    return Container(
      height: 340,
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      color: Colors.blue[200],
      child: Column(
        children: [
          buildRowRecentChord(),
          buildRowRoot(context),
          buildRowMiddle(),
          buildRowTension(),
          buildRowSharpFlat(),
        ],
      ),
    );
  }

  Widget buildRowRecentChord() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Row(
        children: [
          buildRecentChordButton(text: "all", onPressed: widget.insertAllFunction),
          buildRecentChordButton(text: "+", onPressed: () {
            // setState(() {
            //   if (!chord.isEmpty()) {
            //     global.recentChord.add(Chord.fromMap(chord.toMap()));
            //     if (global.recentChord.length > 24) global.recentChord.removeAt(0);
            //   }
            // });
          }),
          buildRecentChordButton(text: "ㅡ", onPressed: () {
            // setState(() {
            //   if (global.recentChord.length > 0) global.recentChord.removeLast();
            // });
          }),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 6.0, 0),
            child: Container(width: 2, height: 35, color: Colors.black),
          ),
          const Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  // children: global.recentChord.map((chord) => buildRecentChordButton(touchChord: chord)).toList()
              ),
            ),
          ),
        ],
      ),
    );
  }
  //
  Widget buildRowRoot(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(1, (index) {
          // 현재 루트를 입력하는 상태인 경우
          //if (index == chord.root) {
            //return ChordToggleButton(isSelected: [false]);
            //   buildToggleButton(
            //   [Chord(root: index).toStringChord(songKey: _songKey)],
            //   _rootSelection[index],
            //   _onPressedRoot(index, type: ChordKeyboard.typeRoot),
            //   type: 1,
            // );
          //} else if (index == chord.base) {
            //return ChordToggleButton(isSelected: [false]);
            //   buildToggleButton(
            //   [Chord(root: index).toStringChord(songKey: _songKey)],
            //   _rootSelection[index],
            //   _onPressedRoot(index, type: ChordKeyboard.typeBase),
            //   type: 3,
            // );
          //} else {
            return ChordToggleButton(
              buttonTextList: const ['C', 'D', 'E','F','G','A','B'],
              isSelected: _rootSelection,
              onPressed: (index) {
                setState(() {
                  _rootSelection[_chord.root] = false;
                  _rootSelection[index] = true;
                  _chord.root = index;
                  context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
                });
              },
            );
            //   buildToggleButton(
            //   [Chord(root: index).toStringChord(songKey: _songKey)],
            //   _rootSelection[index],
            //   _onPressedRoot(index, type: isRootInput ? ChordKeyboard.typeRoot : ChordKeyboard.typeBase),
            //   type: isRootInput ? ChordKeyboard.typeRoot : ChordKeyboard.typeBase,
            // );
          //}
        }),
      ),
    );
  }
  //
  Expanded buildRowMiddle() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChordToggleButton(
            buttonTextList: const ['add', 'sus', 'dim', 'aug'],
            isSelected: _asdaSelection,
            type: ChordKeyboard.typeASDA,
            onPressed: (index) {
              setState(() {
                _asdaSelection[index] = !_asdaSelection[index];
              });
            },
          ),
                  // (index) {
                // setState(() {
                //   for (int buttonIndex = 0; buttonIndex < 4; buttonIndex++) {
                //     if (buttonIndex == index) {
                //       _asdaSelection[buttonIndex] = !_asdaSelection[buttonIndex];
                //       if (_asdaSelection[buttonIndex]) {
                //         nowInput = global.NowInput.asda;
                //         switch (index) {
                //           case 0:
                //             chord.asda = "add";
                //             break;
                //           case 1:
                //             chord.asda = "sus";
                //             break;
                //           case 2:
                //             chord.asda = "dim";
                //             // 마이너/메이저/루트텐션/asda텐션 해제
                //             chord.minor = "";
                //             _minorMajorSelection[0] = false;
                //             if (chord.minorTension > -1)
                //               _numberSelection[chord.minorTension][0] = false;
                //             chord.major = "";
                //             _minorMajorSelection[1] = false;
                //             if (chord.majorTension > -1)
                //               _numberSelection[chord.majorTension][0] = false;
                //             if (chord.rootTension > -1)
                //               _numberSelection[chord.rootTension][0] = false;
                //             chord.minorTension = -1;
                //             chord.majorTension = -1;
                //             chord.rootTension = -1;
                //             if (chord.asdaTension > -1)
                //               _numberSelection[chord.asdaTension][0] = false;
                //             // 디폴트로 7에 텐션 넣어주고, 7을 해제할 수 있도록, 하지만 다른 텐션은 넣을 수 없도록 설정.
                //             chord.asdaTension = 7;
                //             _numberSelection[7][0] = true;
                //             nowInput = null;
                //             break;
                //           case 3:
                //             chord.asda = "aug";
                //             // 마이너/메이저/루트텐션/asda텐션 해제
                //             chord.minor = "";
                //             _minorMajorSelection[0] = false;
                //             if (chord.minorTension > -1)
                //               _numberSelection[chord.minorTension][0] = false;
                //             chord.major = "";
                //             _minorMajorSelection[1] = false;
                //             if (chord.majorTension > -1)
                //               _numberSelection[chord.majorTension][0] = false;
                //             if (chord.rootTension > -1)
                //               _numberSelection[chord.rootTension][0] = false;
                //             chord.minorTension = -1;
                //             chord.majorTension = -1;
                //             chord.rootTension = -1;
                //             if (chord.asdaTension > -1)
                //               _numberSelection[chord.asdaTension][0] = false;
                //             // 디폴트로 7에 텐션 넣어주고, 7을 해제할 수 있도록, 하지만 다른 텐션은 넣을 수 없도록 설정.
                //             chord.asdaTension = 7;
                //             _numberSelection[7][0] = true;
                //             nowInput = null;
                //             break;
                //         }
                //       } else {
                //         chord.asda = "";
                //         if (chord.asdaTension > -1)
                //           _numberSelection[chord.asdaTension][0] = false;
                //         chord.asdaTension = -1;
                //         nowInput = null;
                //       }
                //     } else
                //       _asdaSelection[buttonIndex] = false;
                //   }
                //
                //   context.read<Sheet>().setStateOfSheet();
                // });
              // },
          ChordToggleButton(
            buttonTextList: const ['m', 'M'],
            isSelected: _minorMajorSelection,
            onPressed: (index) {
              setState(() {
                _minorMajorSelection[index] = !_minorMajorSelection[index];
              });
            },
          ),
            //   (index) {
            // setState(() {
            //   _minorMajorSelection[index] = !_minorMajorSelection[index];
              // 마이너 활성화 시
              // if (_minorMajorSelection[0]) {
              //   chord.minor = "m";
              //   // dim / aug 해제 및 딸려있는 텐션이 있다면 같이 해제
              //   if (chord.asda == "dim" || chord.asda == "aug") {
              //     if (chord.asdaTension > -1) {
              //       _numberSelection[chord.asdaTension][0] = false;
              //       chord.asdaTension = -1;
              //     }
              //     chord.asda = "";
              //     _asdaSelection[2] = false;
              //     _asdaSelection[3] = false;
              //   }
              //   // 메이저도 활성화 시
              //   if (_minorMajorSelection[1]) {
              //     chord.major = "M";
              //     nowInput = global.NowInput.major;
              //   } else {
              //     chord.major = "";
              //     nowInput = global.NowInput.minor;
              //   }
              // } else {
              //   chord.minor = "";
              //   if (_minorMajorSelection[1]) {
              //     // dim / aug 해제 및 딸려있는 텐션이 있다면 같이 해제
              //     if (chord.asda == "dim" || chord.asda == "aug") {
              //       if (chord.asdaTension > -1) {
              //         _numberSelection[chord.asdaTension][0] = false;
              //         chord.asdaTension = -1;
              //       }
              //       chord.asda = "";
              //       _asdaSelection[2] = false;
              //       _asdaSelection[3] = false;
              //     }
              //     chord.major = "M";
              //     nowInput = global.NowInput.major;
              //   } else {
              //     chord.major = "";
              //     nowInput = null;
              //   }
              //}

              //context.read<Sheet>().setStateOfSheet();
            //}

          // }),
          // 7 입력
          // asda input인 상황에서, 루트텐션/mM텐션이 7이 아니거나, asda텐션이 7인 경우
          const ChordToggleButton(
              buttonTextList: ['7'],
              isSelected: [false],
          ),
          // (nowInput == global.NowInput.asda && ((chord.rootTension != 7) && (chord.minorTension != 7) && (chord.majorTension != 7)) || chord.asdaTension == 7)
          //     ? buildToggleButton([global.tensionList[7]], _numberSelection[7],
          //         (_) {
          //       setState(() {
          //         _numberSelection[7][0] = !_numberSelection[7][0];
          //         if (_numberSelection[7][0]) { // 7 활성화 했을 때
          //           if (chord.asdaTension > -1) { // 기존 asda 텐션 해제
          //             _numberSelection[chord.asdaTension][0] = false;
          //             chord.asdaTension = -1;
          //           }
          //           chord.asdaTension = 7; // aasda 텐션 할당
          //         } else { // 7 비활성화 하면
          //           chord.asdaTension = -1;
          //         }
          //
          //         context.read<Sheet>().setStateOfSheet();
          //       });
          //     }, type: ChordKeyboard.typeASDA)
          //     : buildToggleButton([global.tensionList[7]], _numberSelection[7],
          //         (_) {
          //       setState(() {
          //         _numberSelection[7][0] = !_numberSelection[7][0];
          //         if (_numberSelection[7][0]) {
          //           // 기존 값 모두 초기화
          //           if (chord.rootTension > -1) {
          //             _numberSelection[chord.rootTension][0] = false;
          //             chord.rootTension = -1;
          //           } else if (chord.minorTension > -1) {
          //             _numberSelection[chord.minorTension][0] = false;
          //             chord.minorTension = -1;
          //           } else if (chord.majorTension > -1) {
          //             _numberSelection[chord.majorTension][0] = false;
          //             chord.majorTension = -1;
          //           }
          //           // nowInput에 맞게 값 재세팅
          //           if (chord.major == "M")
          //             chord.majorTension = 7;
          //           else if (chord.minor == "m")
          //             chord.minorTension = 7;
          //           else
          //             chord.rootTension = 7;
          //         }
          //         else {
          //           chord.rootTension = -1;
          //           chord.minorTension = -1;
          //           chord.majorTension = -1;
          //         }
          //
          //         context.read<Sheet>().setStateOfSheet();
          //       });
          //     }, type: ChordKeyboard.typeRoot),
        ],
      ),
    );
  }
  //
  Expanded buildRowTension() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(1, (index) {
          int _type = ChordKeyboard.typeTens;
          // // now input에 따라 비활성화 된 버튼의 활성화 색을 결정
          // if (nowInput == global.NowInput.tension || nowInput == null)
          //   _type = ChordKeyboard.typeTens;
          // else if (nowInput == global.NowInput.asda)
          //   _type = ChordKeyboard.typeASDA;
          // else
          //   _type = ChordKeyboard.typeRoot;
          //
          // if (index == chord.tension)
          //   _type = ChordKeyboard.typeTens;
          // else if (index == chord.asdaTension)
          //   _type = ChordKeyboard.typeASDA;
          // else if (index == chord.rootTension || index == chord.minorTension || index == chord.majorTension)
          //   _type = ChordKeyboard.typeRoot;

          // if (_type == ChordKeyboard.typeRoot) {
          //   return buildToggleButton(
          //       [global.tensionList[index]], _numberSelection[index], (i) {
          //     setState(() {
          //       _numberSelection[index][0] = !_numberSelection[index][0];
          //       if (_numberSelection[index][0]) {
          //         // 기존 값 모두 초기화
          //         if (chord.rootTension > -1) {
          //           _numberSelection[chord.rootTension][0] = false;
          //           chord.rootTension = -1;
          //         } else if (chord.minorTension > -1) {
          //           _numberSelection[chord.minorTension][0] = false;
          //           chord.minorTension = -1;
          //         } else if (chord.majorTension > -1) {
          //           _numberSelection[chord.majorTension][0] = false;
          //           chord.majorTension = -1;
          //         }
          //         // nowInput에 맞게 값 재세팅
          //         if (nowInput == global.NowInput.root)
          //           chord.rootTension = index;
          //         else if (nowInput == global.NowInput.minor)
          //           chord.minorTension = index;
          //         else if (nowInput == global.NowInput.major) chord.majorTension = index;
          //       } else {
          //         chord.rootTension = -1;
          //         chord.minorTension = -1;
          //         chord.majorTension = -1;
          //       }
          //
          //       context.read<Sheet>().setStateOfSheet();
          //     });
          //   }, type: _type);
          // }
          // if (_type == ChordKeyboard.typeASDA) {
          //   return buildToggleButton(
          //       [global.tensionList[index]], _numberSelection[index], (i) {
          //     setState(() {
          //       _numberSelection[index][0] = !_numberSelection[index][0];
          //       if (_numberSelection[index][0]) {
          //         if (chord.asdaTension > -1) {
          //           _numberSelection[chord.asdaTension][0] = false;
          //           chord.asdaTension = -1;
          //         }
          //         if (nowInput == global.NowInput.asda)
          //           chord.asdaTension = index;
          //       }
          //       else
          //         chord.asdaTension = -1;
          //
          //       context.read<Sheet>().setStateOfSheet();
          //     });
          //   }, type: _type);
          // }
          // type ChordKeyboard.typeTens
          return ChordToggleButton(
              buttonTextList: global.tensionList,
              isSelected: _numberSelection
          );
          // return buildToggleButton(
          //     [global.tensionList[index]], _numberSelection[index], (i) {
          //   setState(() {
          //     _numberSelection[index][0] = !_numberSelection[index][0];
          //     if (_numberSelection[index][0]) {
          //       if (chord.tension > -1) {
          //         _numberSelection[chord.tension][0] = false;
          //         chord.tension = -1;
          //       }
          //       if (nowInput == global.NowInput.tension || nowInput == null)
          //         chord.tension = index;
          //     } else
          //       chord.tension = -1;
          //
          //     context.read<Sheet>().setStateOfSheet();
          //   });
          // }, type: _type);
        }),
      ),
    );
  }
  //
  Expanded buildRowSharpFlat() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChordToggleButton(
            buttonTextList: const ['#', 'b'],
            isSelected: _rootSharpSelection,
            onPressed: (index) {
            },
          ),
          ChordToggleButton(
            buttonTextList: const ['#', 'b'],
            isSelected: _tensionSharpSelection,
            type: ChordKeyboard.typeTens,
          ),
          ChordToggleButton(
            buttonTextList: const ['/', '#', 'b'],
            isSelected: _baseSharpSelection,
            type: ChordKeyboard.typeBase,
          ),

          // buildToggleButton(['#', 'b'], _rootAddSelection, (index) {
          //   setState(() {
          //     _rootAddSelection[index] = !_rootAddSelection[index];
          //
          //     if (index == 0) _rootAddSelection[1] = false;
          //     else _rootAddSelection[0] = false;
          //
          //     if (_rootAddSelection[0]) chord.rootSharp = 1;
          //     else if (_rootAddSelection[1]) chord.rootSharp = -1;
          //     else chord.rootSharp = 0;
          //
          //     context.read<Sheet>().setStateOfSheet();
          //   });
          // }),
          // buildToggleButton(['#', 'b'], _tensionAddSelection, (index) {
          //   setState(() {
          //     _tensionAddSelection[index] = !_tensionAddSelection[index];
          //
          //     if (index == 0) _tensionAddSelection[1] = false;
          //     else _tensionAddSelection[0] = false;
          //
          //     if (_tensionAddSelection[0]) {
          //       chord.tensionSharp = 1;
          //       nowInput = global.NowInput.tension;
          //     } else if (_tensionAddSelection[1]) {
          //       chord.tensionSharp = -1;
          //       nowInput = global.NowInput.tension;
          //     } else {
          //       chord.tensionSharp = 0;
          //     }
          //
          //     context.read<Sheet>().setStateOfSheet();
          //   });
          // }, type: ChordKeyboard.typeTens),
          // buildToggleButton(['/', '#', 'b'], _baseAddSelection, (index) {
          //   setState(() {
          //     _baseAddSelection[index] = !_baseAddSelection[index];
          //
          //     if (index == 0) isRootInput = !_baseAddSelection[index];
          //     else if (index == 1) _baseAddSelection[2] = false;
          //     else if (index == 2) _baseAddSelection[1] = false;
          //
          //     if (_baseAddSelection[1]) chord.baseSharp = 1;
          //     else if (_baseAddSelection[2]) chord.baseSharp = -1;
          //     else chord.baseSharp = 0;
          //
          //     context.read<Sheet>().setStateOfSheet();
          //   });
          // }, type: ChordKeyboard.typeBase),
        ],
      ),
    );
  }

  Widget buildRecentChordButton({Chord? touchChord, String text = "", VoidCallback? onPressed}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: TextButton(
        onPressed: onPressed ?? () {
          // chord.setByMap(touchChord!.toMap());
          // context.read<Sheet>().setStateOfSheet();
        },
        child: Text(
          text,
          //touchChord?.toStringChord(songKey: _songKey) ?? text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(Size(40.0, 35.0)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: BorderSide(color: Colors.black, width: 1.5),
          )),
        ),
      ),
    );
  }
  //
  // ValueSetter<int> _onPressedRoot(int index, {int type = 1}) { //type 은 현재 선택한 버튼의 타입.
  //   return (i) {
  //     setState(() {
  //       for (int buttonIndex = 0; buttonIndex < 7; buttonIndex++) {
  //         if (buttonIndex == index) { // 현재 체크하는 버튼이 선택한 버튼일 때
  //           _rootSelection[index][0] = !_rootSelection[index][0];
  //           if (_rootSelection[index][0]) { // 비활성화 -> 활성화
  //             if (type == ChordKeyboard.typeRoot) { // 선택한 버튼 타입 = root
  //               chord.root = index;
  //               if (index == 1 || index == 2 || index == 5 || index == 6) {
  //                 chord.minor = 'm';
  //                 _minorMajorSelection[0] = true; // 마이너(m) 활성화
  //                 nowInput = global.NowInput.minor;
  //               }
  //               else {
  //                 chord.minor = '';
  //                 _minorMajorSelection[0] = false; // 메이저(M) 활성화
  //                 nowInput = global.NowInput.major;
  //               }
  //             } else { // 선택한 버튼 타입 = base
  //               chord.base = index;
  //             }
  //           } else { // 활성화 -> 비활성화
  //             if (type == ChordKeyboard.typeRoot) { // 선택한 버튼 타입 = root
  //               chord.root = -1;
  //             } else { // 선택한 버튼 타입 = base
  //               chord.base = -1;
  //               _baseAddSelection[1] = false; // 베이스 # 비활성화
  //               _baseAddSelection[2] = false; // 베이스 b 비활성화
  //             }
  //             nowInput = null;
  //           }
  //         } else {
  //           // 현재 체크하는 버튼이 선택한 버튼이 아닌 나머지 버튼들 중 하나 일 때
  //           if (isRootInput && buttonIndex == chord.base) {
  //             // 루트를 입력중인데, 선택하지 않은 버튼이 base의 코드로 사용중이면
  //             continue;
  //           }
  //           if (!isRootInput && buttonIndex == chord.root) {
  //             continue;
  //           }
  //           _rootSelection[buttonIndex][0] = false;
  //         }
  //       }
  //       context.read<Sheet>().setStateOfSheet();
  //     });
  //   };
  // }
  //
  void setButtonWithChord() {
    _rootSelection = [false, false, false, false, false, false, false];
    _minorMajorSelection = [false, false];
    _asdaSelection = [false, false, false, false];
    _rootSharpSelection = [false, false];
    _tensionSharpSelection = [false, false];
    _baseSharpSelection = [false, false, false];
    _numberSelection = [false, false, false, false, false, false, false];

    if (_chord.root > -1) _rootSelection[_chord.root] = true;
    if (_chord.rootSharp == 1) {
      _rootSharpSelection[0] = true;
    } else if (_chord.rootSharp == -1) {
      _rootSharpSelection[1] = true;
    }
    if (_chord.rootTension > -1) _numberSelection[_chord.rootTension] = true;
    if (_chord.minor.isNotEmpty) _minorMajorSelection[0] = true;
    if (_chord.major.isNotEmpty) _minorMajorSelection[1] = true;
    if (_chord.minorTension > -1) _numberSelection[_chord.minorTension] = true;
    if (_chord.majorTension > -1) _numberSelection[_chord.majorTension] = true;
    if (_chord.tensionSharp == 1) _tensionSharpSelection[0] = true;
    else if (_chord.tensionSharp == -1) _tensionSharpSelection[1] = true;
    if (_chord.tension > -1) _numberSelection[_chord.tension] = true;
    if (_chord.asdaTension > -1) _numberSelection[_chord.asdaTension] = true;
    if (_chord.base > -1) _rootSelection[_chord.base] = true;
    _baseSharpSelection[0] = !isRootInput;
    if (_chord.baseSharp == 1) _baseSharpSelection[1] = true;
    else if (_chord.baseSharp == -1) _baseSharpSelection[2] = true;
    if (_chord.asda == "add")
      _asdaSelection[0] = true;
    else if (_chord.asda == "sus")
      _asdaSelection[1] = true;
    else if (_chord.asda == "dim")
      _asdaSelection[2] = true;
    else if (_chord.asda == "aug") _asdaSelection[3] = true;
  }
}
