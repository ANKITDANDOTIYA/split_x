import 'package:hive/hive.dart';

part 'expense.g.dart';

// SplitType Enum: Ise bhi register karna zaroori hai
@HiveType(typeId: 4)
enum SplitType {
  @HiveField(0)
  equal,
  @HiveField(1)
  percentage,
  @HiveField(2)
  exact
}

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

  // 🔥 NAYA FIELD (Index 6): Default 'equal' rakha hai purane data ke liye
  @HiveField(6)
  final SplitType splitType;

  // 🔥 NAYA FIELD (Index 7): Har bande ka alag share store karne ke liye
  @HiveField(7)
  final Map<String, double>? customValues;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.payerId,
    required this.involvedParticipantIds,
    required this.date,
    this.splitType = SplitType.equal, // Purane expenses automatically 'equal' ban jayenge
    this.customValues,
  });
}