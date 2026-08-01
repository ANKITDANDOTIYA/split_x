import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense.dart';
import '../services/group_service.dart';
import '../widgets/category_helper.dart';

class AnalyticsScreen extends StatefulWidget {
  final String groupId;

  const AnalyticsScreen({super.key, required this.groupId});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedRange = 'Monthly'; // 'Weekly', 'Monthly', 'Yearly'

  List<Expense> _getFilteredExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);
    late DateTime startDate;

    switch (_selectedRange) {
      case 'Weekly':
        startDate = today.subtract(const Duration(days: 7));
        break;
      case 'Monthly':
        startDate = today.subtract(const Duration(days: 30));
        break;
      case 'Yearly':
        startDate = today.subtract(const Duration(days: 365));
        break;
      default:
        startDate = today.subtract(const Duration(days: 30));
    }

    return expenses.where((e) => e.date.isAfter(startDate)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color primaryGreen = const Color.fromARGB(255, 43, 136, 116);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          "Spending Analytics",
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
      body: Consumer<GroupService>(
        builder: (context, service, _) {
          final group = service.groups.firstWhere(
            (g) => g.id == widget.groupId,
          );

          final filteredExpenses = _getFilteredExpenses(group.expenses);
          final double totalAmount = filteredExpenses.fold(0.0, (sum, e) => sum + e.amount);

          // Calculate category sums
          final Map<String, double> categorySums = {};
          for (var cat in CategoryHelper.categories) {
            categorySums[cat] = 0.0;
          }
          for (var e in filteredExpenses) {
            final cat = e.categoryName;
            categorySums[cat] = (categorySums[cat] ?? 0.0) + e.amount;
          }

          // Filter out categories with zero spending and sort descending
          final activeCategories = categorySums.entries
              .where((entry) => entry.value > 0)
              .toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          return Column(
            children: [
              // Date Range Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: ['Weekly', 'Monthly', 'Yearly'].map((range) {
                      final isSelected = _selectedRange == range;
                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _selectedRange = range),
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? primaryGreen : Colors.white)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: isSelected && !isDark
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              range,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? (isDark ? Colors.white : primaryGreen)
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey[100]?.withOpacity(isDark ? 0.05 : 1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pie_chart_outline_rounded,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              "No expenses in this period",
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Try switching the date range or add new expenses.",
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Total Spending Card
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [const Color(0xFF004D40), const Color(0xFF00796B)]
                                      : [const Color(0xFF1B5E4F), const Color(0xFF2E7D32)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Total Spending",
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "₹${totalAmount.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${filteredExpenses.length} transactions in this period",
                                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Chart Card
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "Category Distribution",
                                    style: GoogleFonts.outfit(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 180,
                                    child: PieChart(
                                      PieChartData(
                                        sectionsSpace: 2,
                                        centerSpaceRadius: 40,
                                        sections: activeCategories.map((entry) {
                                          final cat = entry.key;
                                          final val = entry.value;
                                          final percentage = (val / totalAmount) * 100;
                                          final color = CategoryHelper.getColor(cat);
                                          return PieChartSectionData(
                                            color: color,
                                            value: val,
                                            title: "${percentage.toStringAsFixed(0)}%",
                                            radius: 50,
                                            titleStyle: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Category Breakdown Title
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                "Category Breakdown",
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Category Breakdown List
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Column(
                                children: activeCategories.map((entry) {
                                  final cat = entry.key;
                                  final amount = entry.value;
                                  final pct = (amount / totalAmount) * 100;
                                  final color = CategoryHelper.getColor(cat);
                                  final icon = CategoryHelper.getIcon(cat);
                                  final isLast = cat == activeCategories.last.key;

                                  return Column(
                                    children: [
                                      ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        leading: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(icon, color: color, size: 22),
                                        ),
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            Text(
                                              "₹${amount.toStringAsFixed(2)}",
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        subtitle: Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: LinearProgressIndicator(
                                                  value: pct / 100,
                                                  backgroundColor: Colors.grey.withOpacity(0.1),
                                                  color: color,
                                                  minHeight: 6,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "${pct.toStringAsFixed(1)}% of total",
                                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                                              ),
                                            ],
                                          ),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
