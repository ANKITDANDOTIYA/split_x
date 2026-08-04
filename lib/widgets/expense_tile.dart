import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import 'category_helper.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final String payerName;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.payerName,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final catIcon = CategoryHelper.getIcon(expense.categoryName);
    final catColor = CategoryHelper.getColor(expense.categoryName);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: isDesktop ? 0.15 : 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: isDesktop ? Theme.of(context).primaryColor.withValues(alpha: 0.04) : null,
          onLongPress: onDelete != null
            ? () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Expense?"),
                    content: Text("Are you sure you want to delete '${expense.title}'?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onDelete!();
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text("Delete"),
                      ),
                    ],
                  ),
                );
              }
            : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(isDesktop ? 20.0 : 16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isDesktop ? 14 : 12),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    catIcon,
                    color: catColor,
                    size: isDesktop ? 28 : 24,
                  ),
                ),
                SizedBox(width: isDesktop ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 18 : 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Paid by $payerName • ${expense.categoryName} • ${DateFormat.MMMd().format(expense.date)}",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isDesktop ? 14 : 13,
                        ),
                      ),

                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "₹${expense.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isDesktop ? 18 : 16,
                        color: const Color(0xFF00695C), // Consistent Dark Teal
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
