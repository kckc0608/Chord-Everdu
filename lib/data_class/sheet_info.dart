import 'package:chord_everdu/data_class/tag_content.dart';

class SheetInfo {
  //final int userID;
  String title;
  int songKey;
  String singer;
  TagContent level;
  TagContent genre;

  SheetInfo({
    required this.title,
    required this.singer,
    required this.songKey,
    this.level = TagContent.noTag,
    this.genre = TagContent.noTag,
  });

  factory SheetInfo.fromMap(Map data) {
    return SheetInfo(
      title: data["title"], /// title 은 필수라서 없으면 에러가 나는게 맞음.
      singer: data["singer"] ?? "",
      songKey: data["song_key"] ?? 0,
      level: TagContent.values.byName(data["level"] ?? "noTag"),
      genre: TagContent.values.byName(data["genre"] ?? "noTag"),
    );
  }
}
