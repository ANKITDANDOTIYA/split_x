// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 1;

  @override
  Expense read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Expense(
      id: fields[0] as String,
      title: fields[1] as String,
      amount: fields[2] as double,
      payerId: fields[3] as String,
      involvedParticipantIds: (fields[4] as List).cast<String>(),
      date: fields[5] as DateTime,
      splitType: fields[6] as SplitType,
      customValues: (fields[7] as Map?)?.cast<String, double>(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.payerId)
      ..writeByte(4)
      ..write(obj.involvedParticipantIds)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.splitType)
      ..writeByte(7)
      ..write(obj.customValues);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SplitTypeAdapter extends TypeAdapter<SplitType> {
  @override
  final int typeId = 4;

  @override
  SplitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SplitType.equal;
      case 1:
        return SplitType.percentage;
      case 2:
        return SplitType.exact;
      default:
        return SplitType.equal;
    }
  }

  @override
  void write(BinaryWriter writer, SplitType obj) {
    switch (obj) {
      case SplitType.equal:
        writer.writeByte(0);
        break;
      case SplitType.percentage:
        writer.writeByte(1);
        break;
      case SplitType.exact:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SplitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
