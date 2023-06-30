import 'package:chord_everdu/data_class/chord.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Map<int, List<String>> chordData = {
    0: [
      "C", "C7", "Cm", "Cm7", "C7add2", "Cm7sus4", "C/E", "C/G", "C/F",
      "Fsus4/E"
    ],
    2: [
      "D", "D/F#",
    ]
  };
  group('chord', () {
    for (int songKey in chordData.keys) {
      for (String chord in chordData[songKey]!) {
        Chord testChord = Chord.fromString(chord, songKey: songKey);
        test('test: ', () {
          expect(testChord.toStringChord(sheetKey: songKey), equals(chord));
        });
      }
    }
  });
}