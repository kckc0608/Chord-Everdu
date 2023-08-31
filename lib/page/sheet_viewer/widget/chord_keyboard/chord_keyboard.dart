import './chord_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:chord_everdu/data_class/chord.dart';
import 'package:chord_everdu/data_class/sheet.dart';

class ChordKeyboard extends StatefulWidget {
  const ChordKeyboard({Key? key,}) : super(key: key);

  static const typeRoot = 1;
  static const typeASDA = 2;
  static const typeBase = 3;
  static const typeTens = 4;

  @override
  _ChordKeyboardState createState() => _ChordKeyboardState();
}

class _ChordKeyboardState extends State<ChordKeyboard> {
  late int _songKey;
  String? nowInput; // 현재 입력 중인 부분 체크
  bool isRootInput = true;

  // currentCell 이 null 이 아닐 때 이 위젯이 생성 되기 때문에, 코드는 항상 존재함.
  late Chord _chord;
  late int _selectedCellIndex;
  late int _selectedBlockIndex;

  List<List<bool>> _rootAndBaseSelection = [[false], [false], [false], [false], [false], [false], [false]];
  List<bool> _asdaSelection = [false, false, false, false];
  List<bool> _minorSelection = [false];
  List<bool> _seventhSelection = [false, false];
  List<List<bool>> _numberSelection = [[false], [false], [false], [false], [false], [false], [false]];
  List<bool> _rootSharpSelection = [false, false];
  List<bool> _tensionSharpSelection = [false, false];
  List<bool> _baseSharpSelection = [false, false, false];

  @override
  Widget build(BuildContext context) {
    _selectedBlockIndex = context.select((Sheet s) => s.selectedBlockIndex);
    _selectedCellIndex = context.select((Sheet s) => s.selectedCellIndex);
    if (_selectedBlockIndex > -1 && _selectedCellIndex > -1) {
      if (context.read<Sheet>().chords[_selectedBlockIndex][_selectedCellIndex] == null) {
        _chord = Chord();
      } else {
        _chord = context.read<Sheet>().chords[_selectedBlockIndex][_selectedCellIndex]!;
      }
    } else {
      _chord = Chord();
    }
    setButtonWithChord();

    var logger = Logger();

    // TODO : 현재 코드 조합에 따라 now Input 설정
    logger.i(_chord);
    Logger().i(context.read<Sheet>().inputMode);

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
      color: Colors.blue[200],
      child: Column(
        children: [
          buildRowRootAndBase(context),
          buildRowMiddle(),
          buildRowTension(),
          buildRowSharpFlat(),
        ],
      ),
    );
  }

  Widget buildRowRootAndBase(BuildContext context) {
    int songKey = context.read<Sheet>().sheetInfo.songKey;
    int sheetKey = context.watch<Sheet>().sheetKey;
    List<List<String>> rootButtonTextList = List.generate(7, (index) => [Chord(root: index).toStringChord(key: (songKey + sheetKey) % 12)]);
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) => ChordToggleButton(
            buttonTextList: rootButtonTextList[index],
            isSelected: _rootAndBaseSelection[index],
            type: (_chord.base == index) ? ChordKeyboard.typeBase : ChordKeyboard.typeRoot,
            onPressed: (_) {
              setState(() {
                if (index == _chord.root) {
                  context.read<Sheet>().inputMode = InputMode.root;
                  _rootAndBaseSelection[index][0] = false;
                  _chord = Chord();
                  context.read<Sheet>().updateChord(
                      _selectedBlockIndex, _selectedCellIndex, _chord);
                  return;
                }

                if (index == _chord.base) {
                  context.read<Sheet>().inputMode = InputMode.base;
                }

                if (context.read<Sheet>().inputMode != InputMode.base && context.read<Sheet>().inputMode != InputMode.root) {
                  context.read<Sheet>().inputMode = (index == _chord.base) ? InputMode.base : InputMode.root;
                }

                switch (context.read<Sheet>().inputMode) {
                  case InputMode.base:
                    if (_chord.base > -1) {
                      _rootAndBaseSelection[_chord.base][0] = false;
                    }
                    _rootAndBaseSelection[index][0] = true;
                    _chord.base = index;
                    break;
                  case InputMode.root:
                    if (_chord.root > -1) {
                      _rootAndBaseSelection[_chord.root][0] = false;
                      _chord.root = -1;
                    }
                    switch (index) {
                      case 0:
                      case 3:
                      case 4:
                        _chord.minor = '';
                        _chord.tensionSharp = 0;
                        _chord.tension = -1;
                        _chord.seventh = '';
                        break;
                      case 1:
                      case 2:
                      case 5:
                        _chord.minor = 'm';
                        _chord.seventh = '7';
                        _chord.tensionSharp = 0;
                        _chord.tension = -1;
                        break;
                      case 6:
                        _chord.minor = 'm';
                        _chord.tensionSharp = -1;
                        _chord.tension = 2;
                        _chord.seventh = '7';
                        break;
                    }
                    _rootAndBaseSelection[index][0] = true;
                    _chord.root = index;
                    context.read<Sheet>().inputMode = InputMode.root;
                    break;
                  default:
                    throw Exception("input 모드가 잘못 되었습니다.");
                }
                context.read<Sheet>().updateChord(
                    _selectedBlockIndex, _selectedCellIndex, _chord);
              });
            })
        ),
      )
    );
  }
  //
  Expanded buildRowMiddle() {
    const List<String> asdaTensionList = ['add', 'sus', 'dim', 'aug'];
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ChordToggleButton(
            buttonTextList: asdaTensionList,
            isSelected: _asdaSelection,
            type: ChordKeyboard.typeASDA,
            onPressed: (index) {
              setState(() {
                context.read<Sheet>().inputMode = InputMode.asda;
                if (_chord.asda.isNotEmpty) {
                  _asdaSelection[asdaTensionList.indexOf(_chord.asda)] = false;
                }
                if (index != asdaTensionList.indexOf(_chord.asda)) {
                  _asdaSelection[index] = true;
                  _chord.asda = asdaTensionList[index];
                  if (index == 0) {
                    _chord.asdaTension = 0;
                  } else if (index == 1) {
                    _chord.asdaTension = 1;
                  }
                } else {
                  _chord.asda = "";
                  _chord.asdaTension = -1;
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
          ChordToggleButton(
            buttonTextList: const ['m'],
            isSelected: _minorSelection,
            onPressed: (index) {
              setState(() {
                _minorSelection[0] = !_minorSelection[0];
                if (_minorSelection[0] == true) {
                  _chord.minor = 'm';
                } else {
                  _chord.minor = '';
                }
                /// TODO : major tension 과 minor tension 을 굳이 나눌 필요가 있는지 고민해보기
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
          // 7 입력
          // asda input 인 상황에서, 루트 텐션 / mM 텐션이 7이 아니거나, asda 텐션이 7인 경우
          ChordToggleButton(
            buttonTextList: const ['M', '7'],
            isSelected: _seventhSelection,
            onPressed: (index) {
              setState(() {
                if (index == 0) {
                  if (_seventhSelection[0] == true) {
                    _seventhSelection[0] = false;
                    _chord.seventh = '7';
                  } else {
                    _seventhSelection[0] = true;
                    _seventhSelection[1] = true;
                    _chord.seventh = 'M7';
                  }
                } else { // index == 1
                  if (_seventhSelection[1] == true) {
                    _seventhSelection[0] = false;
                    _seventhSelection[1] = false;
                    _chord.seventh = '';
                  } else {
                    _seventhSelection[1] = true;
                    _chord.seventh = '7';
                  }
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
        ],
      ),
    );
  }
  //
  Expanded buildRowTension() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) =>
            ChordToggleButton(
              buttonTextList: [global.tensionList[index]],
              isSelected: _numberSelection[index],
              type: index == _chord.asdaTension
                  ? ChordKeyboard.typeASDA
                  : index == _chord.tension
                  ? ChordKeyboard.typeTens
                  : ChordKeyboard.typeRoot,
              onPressed: (_) {
                setState(() {
                  _numberSelection[index][0] = !_numberSelection[index][0];
                  switch (context.read<Sheet>().inputMode) {
                    case InputMode.root:
                      _chord.rootTension = _numberSelection[index][0] == true ? index : -1;
                      break;
                    case InputMode.asda:
                      _chord.asdaTension = _numberSelection[index][0] == true ? index : -1;
                      break;
                    case InputMode.tension:
                      if (_numberSelection[index][0]) {
                        _chord.tension = index;
                      } else {
                        _chord.tension = -1;
                        _chord.tensionSharp = 0;
                      }
                      break;
                    default:
                      break;
                  }
                  context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
                });},
            )),
      ));
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
              setState(() {
                _rootSharpSelection[index] = !_rootSharpSelection[index];
                if (_rootSharpSelection[0] && _rootSharpSelection[1]) {
                  _rootSharpSelection[0] = false;
                  _rootSharpSelection[1] = false;
                  _rootSharpSelection[index] = true;
                }
                if (_rootSharpSelection[0] == true) {
                  _chord.rootSharp = 1;
                } else if (_rootSharpSelection[1] == true) {
                  _chord.rootSharp = -1;
                } else {
                  _chord.rootSharp = 0;
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
          ChordToggleButton(
            buttonTextList: const ['#', 'b'],
            isSelected: _tensionSharpSelection,
            type: ChordKeyboard.typeTens,
            onPressed: (index) {
              setState(() {
                context.read<Sheet>().inputMode = InputMode.tension;
                _tensionSharpSelection[index] = !_tensionSharpSelection[index];
                if (_tensionSharpSelection[0] && _tensionSharpSelection[1]) {
                  _tensionSharpSelection[0] = false;
                  _tensionSharpSelection[1] = false;
                  _tensionSharpSelection[index] = true;
                }
                if (_tensionSharpSelection[0] == true) {
                  _chord.tensionSharp = 1;
                } else if (_tensionSharpSelection[1] == true) {
                  _chord.tensionSharp = -1;
                } else {
                  _chord.tensionSharp = 0;
                }
                if (_chord.tension == -1) {
                  _chord.tension = 4;
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            } ,
          ),
          ChordToggleButton(
            buttonTextList: const ['/', '#', 'b'],
            isSelected: _baseSharpSelection,
            type: ChordKeyboard.typeBase,
            onPressed: (index) {
              setState(() {
                _baseSharpSelection[index] = !_baseSharpSelection[index];
                if (_baseSharpSelection[1] && _baseSharpSelection[2]) {
                  _baseSharpSelection[1] = false;
                  _baseSharpSelection[2] = false;
                  _baseSharpSelection[index] = true;
                }
                if (_baseSharpSelection[0] == true) {
                  context.read<Sheet>().inputMode = InputMode.base;
                  if (_chord.root > -1) {
                    _chord.base = (_chord.root + 2) % 7;
                  }
                } else {
                  context.read<Sheet>().inputMode = InputMode.root;
                  _chord.base = -1;
                  _chord.baseSharp = 0;
                  _baseSharpSelection[1] = false;
                  _baseSharpSelection[2] = false;
                }

                if (_baseSharpSelection[1] == true) {
                  _chord.baseSharp = 1;
                } else if (_baseSharpSelection[2] == true) {
                  _chord.baseSharp = -1;
                } else {
                  _chord.baseSharp = 0;
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
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
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(const Size(40.0, 35.0)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.black),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
            side: const BorderSide(color: Colors.black, width: 1.5),
          )),
        ),
        child: Text(
          text,
          //touchChord?.toStringChord(songKey: _songKey) ?? text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void setButtonWithChord() {
    _rootAndBaseSelection = [[false], [false], [false], [false], [false], [false], [false]];
    _minorSelection = [false];
    _seventhSelection = [false, false];
    _asdaSelection = [false, false, false, false];
    _rootSharpSelection = [false, false];
    _tensionSharpSelection = [false, false];
    _baseSharpSelection = [false, false, false];
    _numberSelection = [[false], [false], [false], [false], [false], [false], [false]];

    if (_chord.root > -1) _rootAndBaseSelection[_chord.root][0] = true;
    if (_chord.rootSharp == 1) {
      _rootSharpSelection[0] = true;
    } else if (_chord.rootSharp == -1) {
      _rootSharpSelection[1] = true;
    }
    if (_chord.rootTension == 7) {
      _seventhSelection[0] = true;
    } else if (_chord.rootTension > -1) {
      _numberSelection[_chord.rootTension][0] = true;
    }
    if (_chord.minor.isNotEmpty) _minorSelection[0] = true;
    if (_chord.seventh.isNotEmpty) {
      if (_chord.seventh[0] == 'M') {
        _seventhSelection[0] = true;
        _seventhSelection[1] = true;
      } else if (_chord.seventh[0] == '7') {
        _seventhSelection[1] = true;
      }
    }
    if (_chord.tensionSharp == 1) {
      _tensionSharpSelection[0] = true;
    } else if (_chord.tensionSharp == -1) {
      _tensionSharpSelection[1] = true;
    }
    if (_chord.tension > -1) _numberSelection[_chord.tension][0] = true;
    if (_chord.asdaTension > -1) _numberSelection[_chord.asdaTension][0] = true;
    if (_chord.base > -1) {
      _rootAndBaseSelection[_chord.base][0] = true;
      _baseSharpSelection[0] = true;
    }
    if (_chord.baseSharp == 1) {
      _baseSharpSelection[1] = true;
    } else if (_chord.baseSharp == -1) {
      _baseSharpSelection[2] = true;
    }
    if (_chord.asda == "add") {
      _asdaSelection[0] = true;
    } else if (_chord.asda == "sus") {
      _asdaSelection[1] = true;
    } else if (_chord.asda == "dim") {
      _asdaSelection[2] = true;
    } else if (_chord.asda == "aug") {
      _asdaSelection[3] = true;
    }
  }
}
