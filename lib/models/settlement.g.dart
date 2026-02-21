// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettlementAdapter extends TypeAdapter<Settlement> {
  @override
  final int typeId = 3;

  @override
  Settlement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settlement(
      id: fields[0] as String,
      fromParticipantId: fields[1] as String,
      toParticipantId: fields[2] as String,
      amount: fields[3] as double,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Settlement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fromParticipantId)
      ..writeByte(2)
      ..write(obj.toParticipantId)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
