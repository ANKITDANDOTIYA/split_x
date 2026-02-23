//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
//
// import '../../models/group.dart';
// import '../../models/expense.dart';
// import '../../models/participant.dart';
// import '../../services/group_service.dart';
// import '../../screens/expense_detail_screen.dart';
// import '../../screens/summary_screen.dart';
// import '../../widgets/expense_tile.dart';
//
// class ExpensesTab extends StatelessWidget {
//   final String groupId;
//
//   const ExpensesTab({
//     super.key,
//     required this.groupId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final service = context.watch<GroupService>();
//
//     /// 🔥 ALWAYS FETCH LATEST GROUP FROM PROVIDER
//     final group = service.groups.firstWhere(
//           (g) => g.id == groupId,
//       orElse: () => throw Exception("Group not found"),
//     );
//
//     /// 🔥 TOTAL SPENDING (ONLY REAL EXPENSES)
//     double total = group.expenses.fold(
//       0.0,
//           (sum, e) => sum + e.amount,
//     );
//
//     /// ================= EMPTY STATE =================
//     if (group.expenses.isEmpty && group.settlements.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.receipt_long_rounded,
//                 size: 48,
//                 color: Colors.grey[400],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               "No transactions yet",
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                 color: Colors.grey[500],
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     /// ================= MERGE EXPENSES + SETTLEMENTS =================
//     final List<_TransactionWrapper> allTransactions = [];
//
//     for (var e in group.expenses) {
//       allTransactions.add(_TransactionWrapper.expense(e));
//     }
//
//     for (var s in group.settlements) {
//       allTransactions.add(_TransactionWrapper.settlement(s));
//     }
//
//     /// SORT BY DATE DESC
//     allTransactions.sort((a, b) => b.date.compareTo(a.date));
//
//     /// GROUP BY DATE
//     final Map<String, List<_TransactionWrapper>> grouped = {};
//
//     for (var t in allTransactions) {
//       final key = DateFormat("yyyyMMdd").format(t.date);
//       grouped.putIfAbsent(key, () => []);
//       grouped[key]!.add(t);
//     }
//
//     final sortedKeys = grouped.keys.toList()
//       ..sort((a, b) => b.compareTo(a));
//
//     return Column(
//       children: [
//         _TotalSpendingCard(
//           total: total,
//           transactionCount: allTransactions.length,
//           groupId: groupId,
//         ),
//
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             itemCount: sortedKeys.length + 1,
//             itemBuilder: (context, index) {
//               if (index == sortedKeys.length) {
//                 return const SizedBox(height: 80);
//               }
//
//               final key = sortedKeys[index];
//               final items = grouped[key]!;
//               final date = items.first.date;
//
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 12,
//                       horizontal: 8,
//                     ),
//                     child: Text(
//                       _formatDateHeader(date),
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ),
//
//                   ...items.map((transaction) {
//                     if (transaction.isSettlement) {
//                       final from = group.participants.firstWhere(
//                             (p) => p.id == transaction.settlement!.fromParticipantId,
//                       );
//
//                       final to = group.participants.firstWhere(
//                             (p) => p.id == transaction.settlement!.toParticipantId,
//                       );
//
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: _SettlementTile(
//                           fromName: from.name,
//                           toName: to.name,
//                           amount: transaction.settlement!.amount,
//                           date: transaction.date,
//                         ),
//                       );
//                     }
//
//                     /// NORMAL EXPENSE
//                     final expense = transaction.expense!;
//                     final payer = group.participants.firstWhere(
//                           (p) => p.id == expense.payerId,
//                       orElse: () =>
//                           Participant(id: 'unknown', name: 'Unknown'),
//                     );
//
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 12),
//                       child: ExpenseTile(
//                         expense: expense,
//                         payerName: payer.name,
//                         onDelete: () =>
//                             service.deleteExpense(group, expense.id),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => ExpenseDetailScreen(
//                                 expense: expense,
//                                 group: group,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   }),
//                 ],
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
//
//   static String _formatDateHeader(DateTime date) {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final dateOnly = DateTime(date.year, date.month, date.day);
//
//     if (dateOnly == today) return "TODAY";
//     if (dateOnly == yesterday) return "YESTERDAY";
//     return DateFormat("MMMM d").format(date).toUpperCase();
//   }
// }
//
//
// /// ================= TRANSACTION WRAPPER =================
// class _TransactionWrapper {
//   final Expense? expense;
//   final dynamic settlement;
//   final DateTime date;
//
//   _TransactionWrapper.expense(this.expense)
//       : settlement = null,
//         date = expense!.date;
//
//   _TransactionWrapper.settlement(this.settlement)
//       : expense = null,
//         date = settlement.date;
//
//   bool get isSettlement => settlement != null;
// }
//
// /// ================= SETTLEMENT TILE =================
// class _SettlementTile extends StatelessWidget {
//   final String fromName;
//   final String toName;
//   final double amount;
//   final DateTime date;
//
//   const _SettlementTile({
//     required this.fromName,
//     required this.toName,
//     required this.amount,
//     required this.date,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.green.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.swap_horiz, color: Colors.green),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               "$fromName paid ₹${amount.toStringAsFixed(2)} to $toName",
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// /// ================= TOTAL CARD =================
// class _TotalSpendingCard extends StatelessWidget {
//   final double total;
//   final int transactionCount;
//   final String groupId;
//
//   const _TotalSpendingCard({
//     required this.total,
//     required this.transactionCount,
//     required this.groupId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 180,
//       margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF005041), Color(0xFF00796B)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(32),
//       ),
//       child: Stack(
//         children: [
//           // Decorative Circle
//           Positioned(
//             right: -20,
//             top: -20,
//             child: Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.1),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Positioned(
//             left: -30,
//             bottom: -30,
//             child: Container(
//               width: 150,
//               height: 150,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.05),
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     "Total Spending",
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                   InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => SummaryScreen(groupId: groupId),
//                         ),
//                       );
//                     },
//                     child: const Text(
//                       "Settle Up →",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const Spacer(),
//               Text(
//                 "₹${total.toStringAsFixed(2)}",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 42,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "$transactionCount transactions",
//                 style: TextStyle(color: Colors.white.withOpacity(0.6)),
//               ),
//             ],
//           ),
//         ],
//       )
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// import '../../models/group.dart';
import '../../models/expense.dart';
import '../../models/participant.dart';
import '../../services/group_service.dart';
import '../../screens/expense_detail_screen.dart';
import '../../screens/summary_screen.dart';
import '../../widgets/expense_tile.dart';

class ExpensesTab extends StatelessWidget {
  final String groupId;

  const ExpensesTab({
    super.key,
    required this.groupId,
  });

  @override
  Widget build(BuildContext context) {
    final service = context.watch<GroupService>();

    /// 🔥 ALWAYS FETCH LATEST GROUP FROM PROVIDER
    final group = service.groups.firstWhere(
          (g) => g.id == groupId,
      orElse: () => throw Exception("Group not found"),
    );

    /// 🔥 TOTAL SPENDING (ONLY REAL EXPENSES)
    double total = group.expenses.fold(
      0.0,
          (sum, e) => sum + e.amount,
    );

    /// ================= EMPTY STATE =================
    if (group.expenses.isEmpty && group.settlements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No transactions yet",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    /// ================= MERGE EXPENSES + SETTLEMENTS =================
    final List<_TransactionWrapper> allTransactions = [];

    for (var e in group.expenses) {
      allTransactions.add(_TransactionWrapper.expense(e));
    }

    for (var s in group.settlements) {
      allTransactions.add(_TransactionWrapper.settlement(s));
    }

    /// SORT BY DATE DESC
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    /// GROUP BY DATE
    final Map<String, List<_TransactionWrapper>> grouped = {};

    for (var t in allTransactions) {
      final key = DateFormat("yyyyMMdd").format(t.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(t);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        _TotalSpendingCard(
           expenses: group.expenses,
          groupId: groupId,
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sortedKeys.length + 1,
            itemBuilder: (context, index) {
              if (index == sortedKeys.length) {
                return const SizedBox(height: 80);
              }

              final key = sortedKeys[index];
              final items = grouped[key]!;
              final date = items.first.date;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    child: Text(
                      _formatDateHeader(date),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  ...items.map((transaction) {
                    if (transaction.isSettlement) {
                      final from = group.participants.firstWhere(
                            (p) => p.id == transaction.settlement!.fromParticipantId,
                      );

                      final to = group.participants.firstWhere(
                            (p) => p.id == transaction.settlement!.toParticipantId,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SettlementTile(
                          fromName: from.name,
                          toName: to.name,
                          amount: transaction.settlement!.amount,
                          date: transaction.date,
                        ),
                      );
                    }

                    /// NORMAL EXPENSE
                    final expense = transaction.expense!;
                    final payer = group.participants.firstWhere(
                          (p) => p.id == expense.payerId,
                      orElse: () =>
                          Participant(id: 'unknown', name: 'Unknown'),
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ExpenseTile(
                        expense: expense,
                        payerName: payer.name,
                        onDelete: () =>
                            service.deleteExpense(group, expense.id),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExpenseDetailScreen(
                                expense: expense,
                                group: group,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return "TODAY";
    if (dateOnly == yesterday) return "YESTERDAY";
    return DateFormat("MMMM d").format(date).toUpperCase();
  }
}


/// ================= TRANSACTION WRAPPER =================
class _TransactionWrapper {
  final Expense? expense;
  final dynamic settlement;
  final DateTime date;

  _TransactionWrapper.expense(this.expense)
      : settlement = null,
        date = expense!.date;

  _TransactionWrapper.settlement(this.settlement)
      : expense = null,
        date = settlement.date;

  bool get isSettlement => settlement != null;
}

/// ================= SETTLEMENT TILE =================
class _SettlementTile extends StatelessWidget {
  final String fromName;
  final String toName;
  final double amount;
  final DateTime date;

  const _SettlementTile({
    required this.fromName,
    required this.toName,
    required this.amount,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "$fromName paid ₹${amount.toStringAsFixed(2)} to $toName",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= TOTAL CARD =================
class _TotalSpendingCard extends StatefulWidget {
  final List<Expense> expenses;
  final String groupId;

  const _TotalSpendingCard({
    required this.expenses,
    required this.groupId,
  });

  @override
  State<_TotalSpendingCard> createState() => _TotalSpendingCardState();
}

class _TotalSpendingCardState extends State<_TotalSpendingCard> {
  late DateTime selectedMonth;

  @override
  void initState() {
    super.initState();

    // 🔥 Important: no time part
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
  }

  double _getMonthTotal(DateTime month) {
    return widget.expenses
        .where((e) =>
    e.date.month == month.month &&
        e.date.year == month.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final currentMonthTotal = _getMonthTotal(selectedMonth);

    final previousMonth =
    DateTime(selectedMonth.year, selectedMonth.month - 1);

    final previousMonthTotal = _getMonthTotal(previousMonth);
    final previousMonthName =
    DateFormat("MMMM").format(previousMonth);

    final difference = currentMonthTotal - previousMonthTotal;
    final isIncrease = difference >= 0;


    String comparisonText;
    IconData comparisonIcon;
    Color comparisonColor;

    if (difference == 0) {
      comparisonText = "Same as $previousMonthName";
      comparisonIcon = Icons.remove;
      comparisonColor = Colors.white70;
    } else if (difference > 0) {
      comparisonText =
      "₹${difference.abs().toStringAsFixed(0)} more than $previousMonthName";
      comparisonIcon = Icons.arrow_upward;
      comparisonColor = Colors.redAccent;
    } else {
      comparisonText =
      "₹${difference.abs().toStringAsFixed(0)} less than $previousMonthName";
      comparisonIcon = Icons.arrow_downward;
      comparisonColor = Colors.lightGreenAccent;
    }

    return Container(
      // height: 200,
      constraints: const BoxConstraints(minHeight: 200),

      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005041), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Stack(
        children: [

          /// Decorative circles
          Positioned( right: -20, top: -20, child: Container( width: 100, height: 100, decoration: BoxDecoration( color: Colors.white.withOpacity(0.1), shape: BoxShape.circle, ), ), ), Positioned( left: -30, bottom: -30, child: Container( width: 150, height: 150, decoration: BoxDecoration( color: Colors.white.withOpacity(0.05), shape: BoxShape.circle, ), ), ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ================= TOP ROW =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    "Total Spending",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  /// 🔥 Month Dropdown
                  DropdownButton<DateTime>(
                    value: selectedMonth,
                    dropdownColor: const Color(0xFF005041),
                    underline: const SizedBox(),
                    iconEnabledColor: Colors.white,
                    style: const TextStyle(color: Colors.white),
                    items: List.generate(6, (index) {
                      final month = DateTime(
                        DateTime.now().year,
                        DateTime.now().month - index,
                      );
                      return DropdownMenuItem(
                        value: month,
                        child: Text(
                          DateFormat("MMMM yyyy").format(month),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedMonth = value);
                      }
                    },
                  ),
                ],
              ),

              // const SizedBox(height: 20),

              /// ================= TOTAL =================
              Text(
                "₹${currentMonthTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              /// ================= MONTH COMPARISON =================
              Row(
                children: [
                  Icon(
                    comparisonIcon,
                    color: comparisonColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      comparisonText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SummaryScreen(groupId: widget.groupId),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Settle Up →",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),


            ],
          ),
        ],
      ),
    );
  }
}
