import 'package:chord_everdu/environment/global.dart' as global;

class Chord {
  int root,
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

  String toStringChord({int songKey = 0}) {
    String chord = "";
    if (root > -1) {
      int rootKey =
          (songKey + global.indexToKeyOffset[root] + rootSharp + 12) % 12;
      if (rootKey == 1 || rootKey == 3 || rootKey == 6 || rootKey == 8 || rootKey == 10) {
        if (rootSharp == 1)
          chord += global.keyList[rootKey][0];
        else if (rootSharp == -1)
          chord += global.keyList[rootKey][1];
        else
          chord += global.keyList[rootKey][global.keyWithSharpOrFlat[songKey]]; // TODO : 각 key 별로 #/b 선택방법 (임시방편)
      } else {
        chord += global.keyList[rootKey];
      }

      if (rootTension > -1) chord += global.tensionList[rootTension];

      chord += minor;
      if (minorTension > -1) chord += global.tensionList[minorTension];

      chord += major;
      if (majorTension > -1) chord += global.tensionList[majorTension];

      if (tensionSharp == 1)
        chord += '#';
      else if (tensionSharp == -1) chord += "b";

      if (tension > -1) chord += global.tensionList[tension];

      chord += asda;
      if (asdaTension > -1) chord += global.tensionList[asdaTension];
    }

    if (base > -1) {
      chord += "/";
      int baseKey = (songKey + global.indexToKeyOffset[base] + baseSharp + 12) % 12;
      if (baseKey == 1 || baseKey == 3 || baseKey == 6 || baseKey == 8 || baseKey == 10) {
        if (baseSharp == 1)
          chord += global.keyList[baseKey][0];
        else if (baseSharp == -1)
          chord += global.keyList[baseKey][1];
        else
          chord += global.keyList[baseKey][global.keyWithSharpOrFlat[songKey]]; // TODO : #/b선택
      } else {
        chord += global.keyList[baseKey];
      }
    }
    return chord;
  }

  Map<String, dynamic> toJson() {
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
}
