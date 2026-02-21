import 'package:hive/hive.dart';

part 'expense.g.dart';

@HiveType(typeId: 1)
class Expense {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final String payerId;

  @HiveField(4)
  final List<String> involvedParticipantIds;

  @HiveField(5)
  final DateTime date;

  // 🔥 NEW FIELD ADDED
  // 🔥 KYON? → Settlement ko normal expense se differentiate karne ke liye
  // @HiveField(6)
  // final bool isSettlement;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.involvedParticipantIds,
    required this.date,
    // this.isSettlement = false, // 🔥 default false
  });
}
