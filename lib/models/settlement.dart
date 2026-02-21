import 'package:hive/hive.dart';

part 'settlement.g.dart';

@HiveType(typeId: 3)
class Settlement {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fromParticipantId;

  @HiveField(2)
  final String toParticipantId;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final DateTime date;

  Settlement({
    required this.id,
    required this.fromParticipantId,
    required this.toParticipantId,
    required this.amount,
    required this.date,
  });
}
