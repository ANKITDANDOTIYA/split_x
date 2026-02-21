import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/participant.dart';
import '../models/settlement.dart';

class SettlementHistoryTile extends StatelessWidget {
  final Settlement settlement;
  final Group group;

  const SettlementHistoryTile({
    super.key,
    required this.settlement,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    final from = group.participants.firstWhere(
          (p) => p.id == settlement.fromParticipantId,
      orElse: () => Participant(id: '', name: 'Unknown'),
    );

    final to = group.participants.firstWhere(
          (p) => p.id == settlement.toParticipantId,
      orElse: () => Participant(id: '', name: 'Unknown'),
    );

    return ListTile(
      leading: const Icon(Icons.check_circle, color: Colors.green),
      title: Text(
        "${from.name} paid ₹${settlement.amount.toStringAsFixed(2)} to ${to.name}",
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        "${settlement.date.day}/${settlement.date.month}/${settlement.date.year}",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
