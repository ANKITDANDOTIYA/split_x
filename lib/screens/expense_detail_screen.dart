import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/participant.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;
  final Group group;

  const ExpenseDetailScreen({
    super.key,
    required this.expense,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
     
    final Color primaryGreen = const Color.fromARGB(255, 43, 136, 116);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final payer = group.participants.firstWhere(
      (p) => p.id == expense.payerId,
      orElse: () => Participant(id: '?', name: 'Unknown'),
    );

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Expense Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 50),
        child: Column(
          children: [
             
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Icon(Icons.receipt_long_rounded, size: 35, color: primaryGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    expense.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat.yMMMMd().format(expense.date),
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "₹${expense.amount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: primaryGreen,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: primaryGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: primaryGreen,
                          child: Text(payer.name[0].toUpperCase(), 
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        const SizedBox(width: 10),
                        Text("Paid by ${payer.name}", 
                          style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 35),

             
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Split breakdown (${expense.splitType.name.toUpperCase()})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 15),

            Container(
              // padding: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: expense.involvedParticipantIds.map((id) {
                  final person = group.participants.firstWhere(
                    (p) => p.id == id,
                    orElse: () => Participant(id: '?', name: 'Unknown'),
                  );

                  //  CUSTOM LOGIC: Check if split is custom or equal
                  double displayAmount = 0;
                  if (expense.splitType == SplitType.equal) {
                    displayAmount = expense.amount / expense.involvedParticipantIds.length;
                  } else {
                    // Custom values (Percentage/Exact) se amount uthao
                    displayAmount = expense.customValues?[id] ?? 0;
                  }

                  bool isLast = id == expense.involvedParticipantIds.last;

                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: primaryGreen.withOpacity(0.1),
                          child: Text(person.name[0], style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          person.id == expense.payerId ? "Paid for self" : "Owes ${payer.name}",
                          style: TextStyle(
                            color: person.id == expense.payerId ? Colors.green : Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                        trailing: Text(
                          "₹${displayAmount.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
                      if (!isLast) Divider(height: 1, indent: 70, color: Colors.grey.withOpacity(0.1)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
  