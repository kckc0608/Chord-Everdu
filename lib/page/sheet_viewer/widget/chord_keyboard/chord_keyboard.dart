import './chord_toggle_button.dart';
import 'package:flutter/material.dart';
import 'package:chord_everdu/environment/global.dart' as global;
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:chord_everdu/data_class/chord.dart';
import 'package:chord_everdu/data_class/sheet.dart';

enum InputMode {root, asda, base, tension}
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
  InputMode inputMode = InputMode.root;

  // currentCell 이 null 이 아닐 때 이 위젯이 생성 되기 때문에, 코드는 항상 존재함.
  late Chord _chord;
  late int _selectedCellIndex;
  late int _selectedBlockIndex;

  List<List<bool>> _rootAndBaseSelection = [[false], [false], [false], [false], [false], [false], [false]];
  List<bool> _asdaSelection = [false, false, false, false];
  List<bool> _minorMajorSelection = [false, false];
  List<bool> _seventhSelection = [false];
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
    // TODO : block 을 터치해서 포커스를 껐을 때 셀 포커스가 해제됐음에도 키보드 포커스가 그대로인 문제 수정 필요
    logger.i(_chord);
    logger.i(inputMode);

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
    const List<List<String>> rootButtonTextList = [
      ['C'], ['D'], ['E'], ['F'], ['G'], ['A'], ['B']
    ];
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
                  inputMode = InputMode.root;
                  return;
                }

                if (index == _chord.base) {
                  inputMode = InputMode.base;
                }

                if (inputMode != InputMode.base && inputMode != InputMode.root) {
                    inputMode = (index == _chord.base) ? InputMode.base : InputMode.root;
                }

                switch (inputMode) {
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
                    }
                    _rootAndBaseSelection[index][0] = true;
                    _chord.root = index;
                    inputMode = InputMode.root;
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
                inputMode = InputMode.asda;
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
            buttonTextList: const ['m', 'M'],
            isSelected: _minorMajorSelection,
            onPressed: (index) {
              setState(() {
                _minorMajorSelection[index] = !_minorMajorSelection[index];
                if (_minorMajorSelection[0] == true) {
                  _chord.minor = 'm';
                } else {
                  _chord.minor = '';
                }

                if (_minorMajorSelection[1] == true) {
                  /// root 코드에 바로 7 넣고 나서 M 누르면 7 뒤에 M 가 생김 ( root tension 에서 Major tension 으로 옮겨야함 )
                  _chord.major = 'M';
                } else {
                  _chord.major = '';
                }
                context.read<Sheet>().updateChord(_selectedBlockIndex, _selectedCellIndex, _chord);
              });
            },
          ),
          // 7 입력
          // asda input 인 상황에서, 루트 텐션 / mM 텐션이 7이 아니거나, asda 텐션이 7인 경우
          ChordToggleButton(
            buttonTextList: const ['7'],
            isSelected: _seventhSelection,
            onPressed: (index) {
              setState(() {
                _seventhSelection[0] = !_seventhSelection[0];
                if (_seventhSelection[0] == true) {
                  if (_chord.major.isNotEmpty) {
                    _chord.majorTension = 7;
                  } else if (_chord.minor.isNotEmpty) {
                    _chord.minorTension = 7;
                  } else {
                    _chord.rootTension = 7;
                  }
                } else {
                  _chord.majorTension = -1;
                  _chord.minorTension = -1;
                  _chord.rootTension = -1;
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
                  switch (inputMode) {
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
                inputMode = InputMode.tension;
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
                if (_tensionSharpSelection[1] && _tensionSharpSelection[2]) {
                  _tensionSharpSelection[1] = false;
                  _tensionSharpSelection[2] = false;
                  _tensionSharpSelection[index] = true;
                }
                if (_baseSharpSelection[0] == true) {
                  inputMode = InputMode.base;
                  if (_chord.root > -1) {
                    _chord.base = (_chord.root + 2) % 7;
                  }
                } else {
                  inputMode = InputMode.root;
                  _chord.base = -1;
                  _chord.baseSharp = 0;
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
    _minorMajorSelection = [false, false];
    _seventhSelection = [false];
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
    if (_chord.minor.isNotEmpty) _minorMajorSelection[0] = true;
    if (_chord.major.isNotEmpty) _minorMajorSelection[1] = true;
    if (_chord.minorTension == 7) {
      _seventhSelection[0] = true;
    } else if (_chord.minorTension > -1) {
      _numberSelection[_chord.minorTension][0] = true;
    }
    if (_chord.majorTension == 7) {
      _seventhSelection[0] = true;
    } else if (_chord.majorTension > -1) {
      _numberSelection[_chord.majorTension][0] = true;
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
