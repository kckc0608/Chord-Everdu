import 'package:flutter/material.dart';
import 'package:chord_everdu/page_NewSheet.dart';
import 'custom_data_structure.dart';
import 'global.dart' as global;

class ChordKeyboard extends StatefulWidget {
  const ChordKeyboard({Key? key, required this.onButtonTap}) : super(key: key);

  final VoidCallback onButtonTap;

  @override
  _ChordKeyboardState createState() => _ChordKeyboardState();
}

class _ChordKeyboardState extends State<ChordKeyboard> {
  int _songKey = 0;
  int _sharp = 0; // #을 붙일지 b을 붙일지 결정, 0일때 #

  List<List<bool>> _rootSelection = [[false], [false], [false], [false], [false], [false], [false]];
  List<bool> _middleSelection1 = [false, false];
  List<bool> _middleSelection2 = [false, false, false, false];
  List<bool> _rootAddSelection = [false, false];
  List<bool> _middleAddSelection = [false, false];
  List<bool> _baseAddSelection = [false, false, false];
  List<List<bool>> _numberSelection = [[false], [false], [false], [false], [false], [false], [false], [false]];

  TextStyle _toggleTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.bold);

  String? nowInput; // 현재 입력중인 부분체크
  bool isRootInput = true;

  Chord? chord;

  @override
  Widget build(BuildContext context) {
    NewSheetState? parent = context.findAncestorStateOfType<NewSheetState>();
    _songKey = parent!.songKey;
    chord = parent.currentChord;
    print("Now Input is " + nowInput.toString());

    //if (chord!["root"] > -1) _rootSelection[chord!["root"]][0] = true;

    return Container(
      height: 360,
      color: Colors.blue[200],
      child: Column(
        children: [
          buildRowRecentChord(),
          buildRowRoot(),
          buildRowMiddle(),
          buildRowTension(),
          buildRowSharpFlat(),
        ],
      ),
    );
  }

  Widget buildRowRecentChord() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {},
              child: Text("CM7"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.black,
                  ),
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {},
              child: Text("Am7"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.black,
                  ),
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {},
              child: Text("F"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.black,
                  ),
                )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {},
              child: Text("G7"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                  side: BorderSide(
                    color: Colors.black,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRowRoot() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          int _key = indexToKey(index);

          bool isInSharp = (_key == 1 || _key == 3 || _key == 6 || _key == 8 || _key == 10);
          // #, b이 들어가는 노트인 경우
            if (_key == chord!.root) { // 현재 루트를 입력하는 상태인 경우
              return buildToggleButton(
                isInSharp ? [global.keyList[_key][_sharp]] : [global.keyList[_key]],
                _rootSelection[index],
                _onPressedRoot(index, _key, type: 1),
                type: 1,
              );
            }
            else if (_key == chord!.base) {
              return buildToggleButton(
                isInSharp ? [global.keyList[_key][_sharp]] : [global.keyList[_key]],
                _rootSelection[index],
                _onPressedRoot(index, _key, type: 3),
                type: 3,
              );
            }
            else {
              return buildToggleButton(
                isInSharp ? [global.keyList[_key][_sharp]] : [global.keyList[_key]],
                _rootSelection[index],
                _onPressedRoot(index, _key, type: isRootInput ? 1 : 3),
                type: isRootInput ? 1 : 3,
              );
            }
        }),
      ),
    );
  }

  Expanded buildRowMiddle() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildToggleButton(['add', 'sus', 'dim', 'aug'], _middleSelection2, (index) {
            setState(() {
              for (int buttonIndex = 0; buttonIndex < 4; buttonIndex++) {
                if (buttonIndex == index) {
                  _middleSelection2[buttonIndex] = !_middleSelection2[buttonIndex];
                  if (_middleSelection2[buttonIndex]) {
                    nowInput = "asda";
                    switch (index) {
                      case 0:
                        chord!.asda = "add";
                        break;
                      case 1:
                        chord!.asda = "sus";
                        break;
                      case 2:
                        chord!.asda = "dim";
                        // 마이너/메이저/루트텐션/asda텐션 해제
                        chord!.minor = "";
                        _middleSelection1[0] = false;
                        if (chord!.minorTension > -1) _numberSelection[chord!.minorTension][0] = false;
                        chord!.major = "";
                        _middleSelection1[1] = false;
                        if (chord!.majorTension > -1) _numberSelection[chord!.majorTension][0] = false;
                        if (chord!.rootTension > -1) _numberSelection[chord!.rootTension][0] = false;
                        chord!.minorTension = -1;
                        chord!.majorTension = -1;
                        chord!.rootTension = -1;
                        if (chord!.asdaTension > -1) _numberSelection[chord!.asdaTension][0] = false;
                        // 디폴트로 7에 텐션 넣어주고, 7을 해제할 수 있도록, 하지만 다른 텐션은 넣을 수 없도록 설정.
                        chord!.asdaTension = 7;
                        _numberSelection[7][0] = true;
                        nowInput = null;
                        break;
                      case 3:
                        chord!.asda = "aug";
                        // 마이너/메이저/루트텐션/asda텐션 해제
                        chord!.minor = "";
                        _middleSelection1[0] = false;
                        if (chord!.minorTension > -1) _numberSelection[chord!.minorTension][0] = false;
                        chord!.major = "";
                        _middleSelection1[1] = false;
                        if (chord!.majorTension > -1) _numberSelection[chord!.majorTension][0] = false;
                        if (chord!.rootTension > -1) _numberSelection[chord!.rootTension][0] = false;
                        chord!.minorTension = -1;
                        chord!.majorTension = -1;
                        chord!.rootTension = -1;
                        if (chord!.asdaTension > -1) _numberSelection[chord!.asdaTension][0] = false;
                        // 디폴트로 7에 텐션 넣어주고, 7을 해제할 수 있도록, 하지만 다른 텐션은 넣을 수 없도록 설정.
                        chord!.asdaTension = 7;
                        _numberSelection[7][0] = true;
                        nowInput = null;
                        break;
                    }
                  }
                  else {
                    chord!.asda = "";
                    if (chord!.asdaTension > -1) _numberSelection[chord!.asdaTension][0] = false;
                    chord!.asdaTension = -1;
                    nowInput = null;
                  }
                }
                else
                  _middleSelection2[buttonIndex] = false;
              }
              widget.onButtonTap.call();
            });
          }, type: 2),
          buildToggleButton(['m', 'M'],  _middleSelection1, (index) {
            setState(() {
              _middleSelection1[index] = !_middleSelection1[index];
              if (_middleSelection1[0]) {
                chord!.minor = "m";
                // dim / aug 해제 및 딸려있는 텐션이 있다면 같이 해제
                if (chord!.asda == "dim" || chord!.asda == "aug") {
                  if (chord!.asdaTension > -1) {
                    _numberSelection[chord!.asdaTension][0] = false;
                    chord!.asdaTension = -1;
                  }
                  chord!.asda = "";
                  _middleSelection2[2] = false;
                  _middleSelection2[3] = false;
                }
                // 설정
                if (_middleSelection1[1]) {
                  // dim / aug 해제 및 딸려있는 텐션이 있다면 같이 해제
                  if (chord!.asda == "dim" || chord!.asda == "aug") {
                    if (chord!.asdaTension > -1) {
                      _numberSelection[chord!.asdaTension][0] = false;
                      chord!.asdaTension = -1;
                    }
                    chord!.asda = "";
                    _middleSelection2[2] = false;
                    _middleSelection2[3] = false;
                  }
                  chord!.major = "M";
                  nowInput = "M";
                }
                else {
                  chord!.major = "";
                  nowInput = "m";
                }
              }
              else {
                chord!.minor = "";
                if (_middleSelection1[1]) {
                  // dim / aug 해제 및 딸려있는 텐션이 있다면 같이 해제
                  if (chord!.asda == "dim" || chord!.asda == "aug") {
                    if (chord!.asdaTension > -1) {
                      _numberSelection[chord!.asdaTension][0] = false;
                      chord!.asdaTension = -1;
                    }
                    chord!.asda = "";
                    _middleSelection2[2] = false;
                    _middleSelection2[3] = false;
                  }
                  chord!.major = "M";
                  nowInput = "M";
                }
                else {
                  chord!.major = "";
                  nowInput = null;
                }
              }
            widget.onButtonTap.call();
            });
          }),
          (nowInput == "asda" && ((chord!.rootTension != 7) && (chord!.minorTension != 7) && (chord!.majorTension != 7)) || chord!.asdaTension == 7) ?
          buildToggleButton([global.tensionList[7]],  _numberSelection[7], (i) {
            setState(() {
              _numberSelection[7][0] = !_numberSelection[7][0];
              if (_numberSelection[7][0]) {
                if (chord!.asdaTension > -1) {
                  _numberSelection[chord!.asdaTension][0] = false;
                  chord!.asdaTension = -1;
                }
                if (nowInput == "asda") chord!.asdaTension = 7;
              }
              else
                chord!.asdaTension = -1;
              widget.onButtonTap.call();
            });
          }, type: 2) : buildToggleButton([global.tensionList[7]],  _numberSelection[7], (i) {
            setState(() {
              _numberSelection[7][0] = !_numberSelection[7][0];
              if (_numberSelection[7][0]) {
                // 기존 값 모두 초기화
                if (chord!.rootTension > -1) {
                  _numberSelection[chord!.rootTension][0] = false;
                  chord!.rootTension = -1;
                }
                else if (chord!.minorTension > -1) {
                  _numberSelection[chord!.minorTension][0] = false;
                  chord!.minorTension = -1;
                }
                else if (chord!.majorTension > -1) {
                  _numberSelection[chord!.majorTension][0] = false;
                  chord!.majorTension = -1;
                }
                // nowInput에 맞게 값 재세팅
                if (nowInput == "root") chord!.rootTension = 7;
                else if (nowInput == "m") chord!.minorTension = 7;
                else if (nowInput == "M") chord!.majorTension = 7;
              }
              else {
                chord!.rootTension = -1; chord!.minorTension = -1; chord!.majorTension = -1;
              }
              widget.onButtonTap.call();
            });
          }, type: 1),
        ],
      ),
    );
  }

  Expanded buildRowTension() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          int _type = 4;
          // now input에 따라 비활성화 된 버튼의 활성화 색을 결정
          if (nowInput == "tension" || nowInput == null)
            _type = 4;
          else if (nowInput == "asda")
            _type = 2;
          else if (nowInput == "root" || nowInput == "m" || nowInput == "M")
            _type = 1;

          if (index == chord!.tension) _type = 4;
          else if (index == chord!.asdaTension) _type = 2;
          else if (index == chord!.rootTension || index == chord!.minorTension || index == chord!.majorTension) _type = 1;

          if (_type == 1) {
            return buildToggleButton([global.tensionList[index]], _numberSelection[index], (i) {
              setState(() {
                _numberSelection[index][0] = !_numberSelection[index][0];
                if (_numberSelection[index][0]) {
                  // 기존 값 모두 초기화
                  if (chord!.rootTension > -1) {
                    _numberSelection[chord!.rootTension][0] = false;
                    chord!.rootTension = -1;
                  }
                  else if (chord!.minorTension > -1) {
                    _numberSelection[chord!.minorTension][0] = false;
                    chord!.minorTension = -1;
                  }
                  else if (chord!.majorTension > -1) {
                    _numberSelection[chord!.majorTension][0] = false;
                    chord!.majorTension = -1;
                  }
                  // nowInput에 맞게 값 재세팅
                  if (nowInput == "root") chord!.rootTension = index;
                  else if (nowInput == "m") chord!.minorTension = index;
                  else if (nowInput == "M") chord!.majorTension = index;
                }
                else {
                  chord!.rootTension = -1; chord!.minorTension = -1; chord!.majorTension = -1;
                }
                widget.onButtonTap.call();
              });
            }, type: _type);
          }
          if (_type == 2) {
            return buildToggleButton([global.tensionList[index]], _numberSelection[index], (i) {
              setState(() {
                _numberSelection[index][0] = !_numberSelection[index][0];
                if (_numberSelection[index][0]) {
                  if (chord!.asdaTension > -1) {
                    _numberSelection[chord!.asdaTension][0] = false;
                    chord!.asdaTension = -1;
                  }
                  if (nowInput == "asda") chord!.asdaTension = index;
                }
                else
                  chord!.asdaTension = -1;
                widget.onButtonTap.call();
              });
            }, type: _type);
          }
          // type 4
          return buildToggleButton([global.tensionList[index]], _numberSelection[index], (i) {
            setState(() {
              _numberSelection[index][0] = !_numberSelection[index][0];
              if (_numberSelection[index][0]) {
                if (chord!.tension > -1) {
                  _numberSelection[chord!.tension][0] = false;
                  chord!.tension = -1;
                }
                if (nowInput == "tension" || nowInput == null) chord!.tension = index;
              }
              else
                chord!.tension = -1;
              widget.onButtonTap.call();
            });
          }, type: _type);
        }),
      ),
    );
  }

  Expanded buildRowSharpFlat() {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildToggleButton(['#', 'b'], _rootAddSelection, (index) {
            setState(() {
              if (index == 0) _rootAddSelection[1] = false;
              else _rootAddSelection[0] = false;
              _rootAddSelection[index] = !_rootAddSelection[index];

              if (_rootAddSelection[0]) chord!.rootSharp = 1;
              else if (_rootAddSelection[1]) chord!.rootSharp = -1;
              else chord!.rootSharp = 0;
              widget.onButtonTap.call();
            });
          }),
          buildToggleButton(['#', 'b'], _middleAddSelection, (index) {
            setState(() {
              if (index == 0) _middleAddSelection[1] = false;
              else _middleAddSelection[0] = false;
              _middleAddSelection[index] = !_middleAddSelection[index];

              if (_middleAddSelection[0]) {
                chord!.tensionSharp = 1;
                nowInput = "tension";
              }
              else if (_middleAddSelection[1]) {
                chord!.tensionSharp = -1;
                nowInput = "tension";
              }
              else {
                chord!.tensionSharp = 0;
              }
              widget.onButtonTap.call();
            });
          }, type: 4),
          buildToggleButton(['/', '#', 'b'], _baseAddSelection, (index) {
            setState(() {
              if (index == 0) {isRootInput = _baseAddSelection[index];}
              if (index == 1) {_baseAddSelection[2] = false;}
              else if (index == 2) {_baseAddSelection[1] = false;}
              _baseAddSelection[index] = !_baseAddSelection[index];

              if (_baseAddSelection[1]) chord!.baseSharp = 1;
              else if (_baseAddSelection[2]) chord!.baseSharp = -1;
              else chord!.baseSharp = 0;
              widget.onButtonTap.call();
            });
          }, type: 3),
        ],
      ),
    );
  }

  Widget buildToggleButton(List<String> keyList, List<bool> _isSelected, ValueSetter<int>? _onPressed, {int type = 1}) {
    if (keyList.length != _isSelected.length)
      throw FormatException("keyList's length must be same with _isSelected's length.");

    Color? setFillColor() {
      if (type == 1) {
        return Colors.blue[300];
      }
      else if (type == 2) {
        return Colors.green[300];
      }
      else if (type == 3) {
        return Colors.amber[300];
      }
      else if (type ==4) {
        return Colors.deepOrange[300];
      }
    }

    Color? setSelectedBorderColor() {
      if (type == 1) {
        return Colors.blue[600];
      }
      else if (type == 2) {
        return Colors.green[600];
      }
      else if (type == 3) {
        return Colors.amber[600];
      }
      else if (type == 4) {
        return Colors.deepOrange[600];
      }
    }

    return ToggleButtons(
      constraints: BoxConstraints(minWidth: 52, minHeight: 52),
      borderWidth: 2.0,
      color: Colors.black38,
      borderColor: Colors.black12,
      selectedColor: Colors.black,
      selectedBorderColor: setSelectedBorderColor(),
      fillColor: setFillColor(),
      children: List.generate(keyList.length, (int index) => Text(keyList[index], style: _toggleTextStyle)),
      isSelected: _isSelected,
      onPressed: _onPressed,
    );
  }

  ValueSetter<int> _onPressedRoot(int index, int selectedKey, {int type = 1}) { //type 은 현재 선택한 버튼의 타입.
    return (i) {
      setState(() {
        for (int buttonIndex = 0; buttonIndex < 7; buttonIndex++) {
          if (buttonIndex == index) { // 현재 체크하는 버튼이 선택한 버튼일 때
            _rootSelection[index][0] = !_rootSelection[index][0];
            if (_rootSelection[index][0]) { // 비활성화 -> 활성화
              if (type == 1) { // 루트 코드를 활성화
                chord!.root = selectedKey;
                nowInput = "root";
              }
              else { // 베이스 코드를 활성화
                chord!.base = selectedKey;
              }
            }
            else { // 활성화 -> 비활성화
              if (type == 1) { // 루트코드 비활성화
                chord!.root = -1;
              }
              else { // 베이스 코드 비활성화
                chord!.base = -1;
                _baseAddSelection[1] = false; // 베이스 # 비활성화
                _baseAddSelection[2] = false; // 베이스 b 비활성화
              }
              nowInput = null;
            }
          }
          else { // 현재 체크하는 버튼이 선택한 버튼이 아닌 나머지 버튼들 중 하나 일 때
            if (isRootInput && indexToKey(buttonIndex) == chord!.base) { // 루트를 입력중인데, 선택하지 않은 버튼이 base의 코드로 사용중이면
              continue;
            }
            if (!isRootInput && indexToKey(buttonIndex) == chord!.root) {
              continue;
            }
            _rootSelection[buttonIndex][0] = false;
          }
        }
        widget.onButtonTap.call();
      });
    };
  }

  int indexToKey (int index) {
    int _note = _songKey;
    if      (index == 1) _note += (index+1);
    else if (index == 2) _note += (index+2);
    else if (index == 3) _note += (index+2);
    else if (index == 4) _note += (index+3);
    else if (index == 5) _note += (index+4);
    else if (index == 6) _note += (index+5);
    _note %= 12;
    return _note;
  }
}
