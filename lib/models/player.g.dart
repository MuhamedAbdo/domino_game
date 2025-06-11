// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// ***************************************************************************
// TypeAdapter
// ***************************************************************************
class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      final fieldTag = reader.readByte();
      dynamic value;
      switch (fieldTag) {
        case 0:
          value = reader.readString();
          break;
        case 1:
          value = reader.readInt();
          break;
      }
      fields[fieldTag] = value;
    }
    return Player(
      name: fields[0] as String,
      score: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer.writeByte(2);
    writer.writeByte(0);
    writer.writeString(obj.name);
    writer.writeByte(1);
    writer.writeInt(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
