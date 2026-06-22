import 'package:hive/hive.dart';

class Subject extends HiveObject {
  Subject({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.position = 0,
    this.iconIndex = 0,
  });

  String id;
  String title;
  DateTime createdAt;
  DateTime updatedAt;
  int position;
  int iconIndex;

  Subject copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? position,
    int? iconIndex,
  }) {
    return Subject(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      position: position ?? this.position,
      iconIndex: iconIndex ?? this.iconIndex,
    );
  }
}

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 1;

  @override
  Subject read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    for (var i = 0, n = reader.readByte(); i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Subject(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      updatedAt: fields[3] as DateTime,
      position: fields[4] as int? ?? 0,
      iconIndex: fields[5] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.updatedAt)
      ..writeByte(4)
      ..write(obj.position)
      ..writeByte(5)
      ..write(obj.iconIndex);
  }
}
