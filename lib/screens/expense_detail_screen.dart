import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/participant.dart';
import '../services/group_service.dart';
import '../widgets/category_helper.dart';
import 'add_expense_screen.dart';

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

    final groupService = context.watch<GroupService>();
    final currentGroup = groupService.groups.firstWhere(
      (g) => g.id == group.id,
      orElse: () => group,
    );

    final currentExpense = currentGroup.expenses.firstWhere(
      (e) => e.id == expense.id,
      orElse: () => expense,
    );

    final payer = currentGroup.participants.firstWhere(
      (p) => p.id == currentExpense.payerId,
      orElse: () => Participant(id: '?', name: 'Unknown'),
    );

    final catIcon = CategoryHelper.getIcon(currentExpense.categoryName);
    final catColor = CategoryHelper.getColor(currentExpense.categoryName);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Expense Details", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            tooltip: "Edit Expense",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddExpenseScreen(
                    group: currentGroup,
                    expenseToEdit: currentExpense,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 50),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: catColor.withValues(alpha: 0.1),
                        child: Icon(catIcon, size: 35, color: catColor),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        currentExpense.title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        DateFormat.yMMMMd().format(currentExpense.date),
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                      if (currentExpense.updatedAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Edited ${DateFormat.MMMd().add_jm().format(currentExpense.updatedAt!)}",
                          style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 25),
                      Text(
                        "₹${currentExpense.amount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: primaryGreen,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 25),

                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 10,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: primaryGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: primaryGreen,
                                  child: Text(
                                    payer.name.isNotEmpty ? payer.name[0].toUpperCase() : '?',
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "Paid by ${payer.name}",
                                  style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: catColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: catColor.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(catIcon, color: catColor, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  currentExpense.categoryName,
                                  style: TextStyle(color: catColor, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (currentExpense.notes != null && currentExpense.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: 25),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.sticky_note_2_outlined, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Notes",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentExpense.notes!,
                                style: const TextStyle(fontSize: 14, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 35),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Split breakdown (${currentExpense.splitType.name.toUpperCase()})",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 15),

                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: currentExpense.involvedParticipantIds.map((id) {
                      final person = currentGroup.participants.firstWhere(
                        (p) => p.id == id,
                        orElse: () => Participant(id: '?', name: 'Unknown'),
                      );

                      double displayAmount = 0;
                      if (currentExpense.splitType == SplitType.equal) {
                        displayAmount = currentExpense.amount / currentExpense.involvedParticipantIds.length;
                      } else {
                        displayAmount = currentExpense.customValues?[id] ?? 0;
                      }

                      bool isLast = id == currentExpense.involvedParticipantIds.last;

                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            leading: CircleAvatar(
                              backgroundColor: primaryGreen.withValues(alpha: 0.1),
                              child: Text(
                                person.name.isNotEmpty ? person.name[0] : '?',
                                style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(
                              person.id == currentExpense.payerId ? "Paid for self" : "Owes ${payer.name}",
                              style: TextStyle(
                                color: person.id == currentExpense.payerId ? Colors.green : Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              "₹${displayAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ),
                          if (!isLast) Divider(height: 1, indent: 70, color: Colors.grey.withValues(alpha: 0.1)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}