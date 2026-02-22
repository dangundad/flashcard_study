// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flash_deck.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashDeckAdapter extends TypeAdapter<FlashDeck> {
  @override
  final typeId = 0;

  @override
  FlashDeck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashDeck(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, FlashDeck obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashDeckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
