import 'package:hive/hive.dart';

class Chapter extends HiveObject {
  Chapter({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.favorite = false,
    this.pinned = false,
    this.lastOpenedAt,
    this.bookmarkOffset = 0,
  });

  String id;
  String subjectId;
  String title;
  String content;
  bool favorite;
  bool pinned;
  DateTime createdAt;
  DateTime updatedAt;
  DateTime? lastOpenedAt;
  double bookmarkOffset;

  Chapter copyWith({
    String? id,
    String? subjectId,
    String? title,
    String? content,
    bool? favorite,
    bool? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastOpenedAt,
    double? bookmarkOffset,
  }) {
    return Chapter(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      content: content ?? this.content,
      favorite: favorite ?? this.favorite,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      bookmarkOffset: bookmarkOffset ?? this.bookmarkOffset,
    );
  }
}

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 2;

  @override
  Chapter read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    for (var i = 0, n = reader.readByte(); i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Chapter(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      title: fields[2] as String,
      content: fields[3] as String,
      favorite: fields[4] as bool? ?? false,
      pinned: fields[5] as bool? ?? false,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      lastOpenedAt: fields[8] as DateTime?,
      bookmarkOffset: fields[9] as double? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.favorite)
      ..writeByte(5)
      ..write(obj.pinned)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.lastOpenedAt)
      ..writeByte(9)
      ..write(obj.bookmarkOffset);
  }
}
