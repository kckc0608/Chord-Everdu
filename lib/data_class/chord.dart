import 'package:chord_everdu/environment/global.dart' as global;

enum ChordAnalyzeMode {
  root, rootSharp, rootTension,
  minor, minorTension, major, majorTension,
  tensionSharp, tension,
  asda, asdaTension,
  base, baseSharp
}
class Chord {
  int root, // 해당 song key 에서 상대적인 위치 (계이름 기준이다.)
      rootSharp,
      rootTension,
      minorTension,
      majorTension,
      tension,
      tensionSharp,
      asdaTension,
      base,
      baseSharp;
  String minor, major, asda;

  Chord(
      {this.root = -1,
        this.rootSharp = 0,
        this.rootTension = -1,
        this.minor = "",
        this.minorTension = -1,
        this.major = "",
        this.majorTension = -1,
        this.tensionSharp = 0,
        this.tension = -1,
        this.asda = "",
        this.asdaTension = -1,
        this.base = -1,
        this.baseSharp = 0});

  Chord.fromMap(Map<String, dynamic> chordMap)
      : root = chordMap["root"],
        rootSharp = chordMap["rootSharp"],
        rootTension = chordMap["rootTension"],
        minor = chordMap["minor"],
        minorTension = chordMap["minorTension"],
        major = chordMap["major"],
        majorTension = chordMap["majorTension"],
        tensionSharp = chordMap["tensionSharp"],
        tension = chordMap["tension"],
        asda = chordMap["asda"],
        asdaTension = chordMap["asdaTension"],
        base = chordMap["base"],
        baseSharp = chordMap["baseSharp"];

  factory Chord.fromString(String chordString, {int songKey = 0}) {
    assert(chordString.isNotEmpty);

    int key = 0;
    int baseKey = -10;
    String rootTension = "";
    String minor = "";
    String major = "";
    String minorTension = "";
    String majorTension = "";
    String tensionSharp = "";
    String tension = "";
    String asda = "";
    String asdaTension = "";

    ChordAnalyzeMode mode = ChordAnalyzeMode.root;
    int index = 0;
    while (index < chordString.length) {
      switch (mode) {
        case ChordAnalyzeMode.root:
          if (chordString[index] == 'C') {
            key = 0;
          } else if (chordString[index] == 'D') {
            key = 2;
          } else if (chordString[index] == 'E') {
            key = 4;
          } else if (chordString[index] == 'F') {
            key = 5;
          } else if (chordString[index] == 'G') {
            key = 7;
          } else if (chordString[index] == 'A') {
            key = 9;
          } else if (chordString[index] == 'B') {
            key = 11;
          } else {
            throw Exception("root value is wrong. root should be upper case A to G");
          }
          mode = ChordAnalyzeMode.rootSharp;
          index += 1;
          break;
        case ChordAnalyzeMode.rootSharp:
          if (chordString[index] == '#') {
            key += 1;
            index += 1;
          } else if (chordString[index] == 'b') {
            key -= 1;
            index += 1;
          }
          mode = ChordAnalyzeMode.rootTension;
          break;
        case ChordAnalyzeMode.rootTension:
          if (chordString[index].contains(RegExp(r'[24569]'))) {
            rootTension = chordString[index];
            index += 1;
          } else if (chordString[index] == '1') {
            rootTension = chordString.substring(index, index+2);
            index += 2;
          }
          mode = ChordAnalyzeMode.minor;
          break;
        case ChordAnalyzeMode.minor:
          if (chordString[index] == 'm') {
            minor = "m";
            index += 1;
          }
          mode = ChordAnalyzeMode.minorTension;
          break;
        case ChordAnalyzeMode.minorTension:
          if (chordString[index] == '7') {
            minorTension = '7';
            index += 1;
          }
          mode = ChordAnalyzeMode.major;
          break;
        case ChordAnalyzeMode.major:
          if (chordString[index] == 'M') {
            minor = "M";
            index += 1;
          }
          mode = ChordAnalyzeMode.majorTension;
          break;
        case ChordAnalyzeMode.majorTension:
          if (chordString[index] == '7') {
            majorTension = '7';
            index += 1;
          }
          mode = ChordAnalyzeMode.tensionSharp;
          break;
        case ChordAnalyzeMode.tensionSharp:
          if (chordString[index].contains(RegExp(r'[#b]'))) {
            tensionSharp = chordString[index];
            index += 1;
          }
          mode = ChordAnalyzeMode.tension;
          break;
        case ChordAnalyzeMode.tension:
          if (chordString[index].contains(RegExp(r'[24569]'))) {
            tension = chordString[index];
            index += 1;
          } else if (chordString[index] == '1') {
            tension = chordString.substring(index, index+2);
            index += 2;
          }
          mode = ChordAnalyzeMode.asda;
          break;
        case ChordAnalyzeMode.asda:
          if (chordString.length > index + 2 &&
              chordString.substring(index, index+3).contains(RegExp(r'add|sus|dim|aug'))) {
            asda = chordString.substring(index, index+3);
            index += 3;
          }
          mode = ChordAnalyzeMode.asdaTension;
          break;
        case ChordAnalyzeMode.asdaTension:
          if (chordString[index].contains(RegExp(r'[24569]'))) {
            asdaTension = chordString[index];
            index += 1;
          } else if (chordString[index] == '1') {
            asdaTension = chordString.substring(index, index+2);
            index += 2;
          }
          mode = ChordAnalyzeMode.base;
          break;
        case ChordAnalyzeMode.base:
          if (chordString[index] == '/' && index + 1 < chordString.length) {
            if (chordString[index+1] == 'C') {
              baseKey = 0;
            } else if (chordString[index+1] == 'D') {
              baseKey = 2;
            } else if (chordString[index+1] == 'E') {
              baseKey = 4;
            } else if (chordString[index+1] == 'F') {
              baseKey = 5;
            } else if (chordString[index+1] == 'G') {
              baseKey = 7;
            } else if (chordString[index+1] == 'A') {
              baseKey = 9;
            } else if (chordString[index+1] == 'B') {
              baseKey = 11;
            } else {
              throw Exception("base chord value is wrong. base should be upper case A to G");
            }
            if (index + 2 < chordString.length) {
              if (chordString[index+2] == '#') {
                baseKey += 1;
              } else if (chordString[index+2] == 'b') {
                baseKey -= 1;
              }
            }
          }
          index += 3;
        default:
          break;
      }
    }

    // 3. Change To 계이름
    if (key < 0) {
      key += 12;
    }

    int keyOffset = key - songKey;
    if (keyOffset < 0) {
      keyOffset += 12;
    }

    int root = global.indexToKeyOffset.indexOf(keyOffset);
    int rootSharp = 0;
    if (root == -1) {
      keyOffset -= 1;
      rootSharp = 1; // 일단은 다 #으로 넣어봄.
      root = global.indexToKeyOffset.indexOf(keyOffset);
    }

    int base = -1;
    int baseSharp = 0;
    if (baseKey > -1) {
      int baseKeyOffset = baseKey - songKey;
      if (baseKeyOffset < 0) {
        baseKeyOffset += 12;
      }
      base = global.indexToKeyOffset.indexOf(baseKeyOffset);
      if (base == -1) {
        baseKeyOffset -= 1;
        baseSharp = 1; // 일단은 다 #으로 넣어봄.
        base = global.indexToKeyOffset.indexOf(baseKeyOffset);
      }
    }

    Chord chord = Chord(
      root: root,
      rootSharp: rootSharp,
      minor: minor,
      major: major,
      asda: asda,
      asdaTension: global.tensionList.indexOf(asdaTension),
      majorTension: global.tensionList.indexOf(majorTension),
      minorTension: global.tensionList.indexOf(minorTension),
      rootTension: global.tensionList.indexOf(rootTension),
      tension: global.tensionList.indexOf(tension),
      tensionSharp: tensionSharp == '#' ? 1 : tensionSharp == 'b' ? -1 : 0,
      base: base,
      baseSharp: baseSharp,
    );

    return chord;
  }

  String toStringChord({int songKey = 0}) {
    String chord = "";
    if (root > -1) {
      int rootKey =
          (songKey + global.indexToKeyOffset[root] + rootSharp + 12) % 12;
      if (rootKey == 1 || rootKey == 3 || rootKey == 6 || rootKey == 8 || rootKey == 10) {
        if (rootSharp == 1) {
          chord += global.chordKeyList[rootKey][0];
        } else if (rootSharp == -1) {
          chord += global.chordKeyList[rootKey][1];
        } else {
          /// 현재 키에 따라서 #, b을 적절하게 고르도록 했는데, b,# 이 둘다 가능할 경우 #을 표시하도록 하고 있음.
          chord += global.chordKeyList[rootKey][global.keyWithSharpOrFlat[songKey]];
        }
      } else {
        chord += global.chordKeyList[rootKey];
      }

      if (rootTension > -1) chord += global.tensionList[rootTension];

      chord += minor;
      if (minorTension > -1) chord += global.tensionList[minorTension];

      chord += major;
      if (majorTension > -1) chord += global.tensionList[majorTension];

      if (tensionSharp == 1) {
        chord += '#';
      } else if (tensionSharp == -1) {
        chord += "b";
      }

      if (tension > -1) chord += global.tensionList[tension];

      chord += asda;
      if (asdaTension > -1) chord += global.tensionList[asdaTension];
    }

    if (base > -1) {
      chord += "/";
      int baseKey = (songKey + global.indexToKeyOffset[base] + baseSharp + 12) % 12;
      if (baseKey == 1 || baseKey == 3 || baseKey == 6 || baseKey == 8 || baseKey == 10) {
        if (baseSharp == 1)
          chord += global.chordKeyList[baseKey][0];
        else if (baseSharp == -1)
          chord += global.chordKeyList[baseKey][1];
        else /// 현재 키에 따라서 #, b을 적절하게 고르도록 했는데, b,# 이 둘다 가능할 경우 #을 표시하도록 하고 있음.
          chord += global.chordKeyList[baseKey][global.keyWithSharpOrFlat[songKey]];
      } else {
        chord += global.chordKeyList[baseKey];
      }
    }
    return chord;
  }

  Map<String, dynamic> toMap() {
    return {
      "root": root,
      "rootSharp": rootSharp,
      "rootTension": rootTension,
      "minor": minor,
      "minorTension": minorTension,
      "major": major,
      "majorTension": majorTension,
      "tensionSharp": tensionSharp,
      "tension": tension,
      "asda": asda,
      "asdaTension": asdaTension,
      "base": base,
      "baseSharp": baseSharp,
    };
  }

  bool isEmpty() {
    return (root == -1 && base == -1);
  }

  void setByMap(Map<String, dynamic> chordMap) {
    root = chordMap["root"];
    rootSharp = chordMap["rootSharp"];
    rootTension = chordMap["rootTension"];
    minor = chordMap["minor"];
    minorTension = chordMap["minorTension"];
    major = chordMap["major"];
    majorTension = chordMap["majorTension"];
    tensionSharp = chordMap["tensionSharp"];
    tension = chordMap["tension"];
    asda = chordMap["asda"];
    asdaTension = chordMap["asdaTension"];
    base = chordMap["base"];
    baseSharp = chordMap["baseSharp"];
  }

  @override
  String toString() {
    return toStringChord();
  }
}
