import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../models/participant.dart';
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

  int _getPeriodDays() {
    switch (_selectedRange) {
      case 'Weekly':
        return 7;
      case 'Monthly':
        return 30;
      case 'Yearly':
        return 365;
      default:
        return 30;
    }
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
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.pop(context),
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<GroupService>(
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
                                        color: Colors.black.withValues(alpha: 0.05),
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
                                color: Colors.grey[100]?.withValues(alpha: isDark ? 0.05 : 1),
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
                              "Add more expenses to unlock deep insights.",
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
                            // Total Spending Card (EXISTING)
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
                                    color: Colors.black.withValues(alpha: 0.08),
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
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // ==========================================
                            // 1. SMART INSIGHT CARDS (NEW)
                            // ==========================================
                            _buildSmartInsightGrid(context, group, filteredExpenses, totalAmount, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 7. MONTH COMPARISON CARD (NEW)
                            // ==========================================
                            _buildMonthComparisonCard(context, group.expenses, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // Chart Card (EXISTING)
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
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

                            // ==========================================
                            // 2. DAILY SPENDING TREND LINE CHART (NEW)
                            // ==========================================
                            _buildDailySpendingTrendCard(context, filteredExpenses, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 5. RECENT INSIGHTS (NEW)
                            // ==========================================
                            _buildRecentInsightsSection(context, group, filteredExpenses, totalAmount, activeCategories, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 6. CATEGORY HIGHLIGHTS (NEW)
                            // ==========================================
                            _buildCategoryHighlightsSection(context, filteredExpenses, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 4. TOP SPENDERS (NEW)
                            // ==========================================
                            _buildTopSpendersCard(context, group, filteredExpenses, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // ==========================================
                            // 3. TOP 5 EXPENSES (NEW)
                            // ==========================================
                            _buildTop5ExpensesCard(context, group, filteredExpenses, isDark, primaryGreen),
                            const SizedBox(height: 24),

                            // Category Breakdown Title (EXISTING)
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

                            // Category Breakdown List (EXISTING)
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
                                            color: color.withValues(alpha: 0.1),
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
                                                  backgroundColor: Colors.grey.withValues(alpha: 0.1),
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
            ],
          );
        },
      ),
    ),
    );
  }

  // =========================================================================
  // 1. SMART INSIGHT CARDS GRID
  // =========================================================================
  Widget _buildSmartInsightGrid(
    BuildContext context,
    Group group,
    List<Expense> filteredExpenses,
    double totalAmount,
    bool isDark,
    Color primaryGreen,
  ) {
    final periodDays = _getPeriodDays();
    final double avgDaily = periodDays > 0 ? totalAmount / periodDays : 0.0;

    // Highest Spender
    final Map<String, double> spenderTotals = {};
    for (var e in filteredExpenses) {
      spenderTotals[e.payerId] = (spenderTotals[e.payerId] ?? 0.0) + e.amount;
    }
    String topSpenderName = "N/A";
    double topSpenderAmount = 0.0;
    if (spenderTotals.isNotEmpty) {
      final topEntry = spenderTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      topSpenderAmount = topEntry.value;
      topSpenderName = group.participants
          .firstWhere((p) => p.id == topEntry.key, orElse: () => Participant(id: '', name: 'Unknown'))
          .name;
    }

    // Biggest Expense
    Expense? biggestExpense;
    if (filteredExpenses.isNotEmpty) {
      biggestExpense = filteredExpenses.reduce((a, b) => a.amount > b.amount ? a : b);
    }

    // Most Expensive Day
    final Map<String, double> dailyTotals = {};
    final Map<String, DateTime> dateMap = {};
    for (var e in filteredExpenses) {
      final dateKey = DateFormat('yyyy-MM-dd').format(e.date);
      dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0.0) + e.amount;
      dateMap[dateKey] = e.date;
    }
    String mostExpensiveDayText = "N/A";
    double mostExpensiveDayAmount = 0.0;
    if (dailyTotals.isNotEmpty) {
      final topDayEntry = dailyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
      mostExpensiveDayAmount = topDayEntry.value;
      final dt = dateMap[topDayEntry.key];
      if (dt != null) {
        mostExpensiveDayText = DateFormat('MMM d').format(dt);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
          children: [
            // Total Expenses
            _buildStatCard(
              context,
              title: "Total Expenses",
              value: "${filteredExpenses.length} Expenses",
              subtitle: "In selected period",
              icon: Icons.receipt_long_rounded,
              color: Colors.blueAccent,
              isDark: isDark,
            ),

            // Highest Spender
            _buildStatCard(
              context,
              title: "Highest Spender",
              value: topSpenderName,
              subtitle: "Paid ₹${topSpenderAmount.toStringAsFixed(0)}",
              icon: Icons.person_pin_rounded,
              color: Colors.deepOrangeAccent,
              isDark: isDark,
            ),

            // Biggest Expense
            _buildStatCard(
              context,
              title: "Biggest Expense",
              value: biggestExpense != null ? "₹${biggestExpense.amount.toStringAsFixed(0)}" : "N/A",
              subtitle: biggestExpense != null ? biggestExpense.title : "No expenses",
              icon: Icons.local_fire_department_rounded,
              color: Colors.amber[800]!,
              isDark: isDark,
            ),

            // Most Expensive Day
            _buildStatCard(
              context,
              title: "Peak Day",
              value: mostExpensiveDayText,
              subtitle: "Spent ₹${mostExpensiveDayAmount.toStringAsFixed(0)}",
              icon: Icons.calendar_today_rounded,
              color: Colors.purpleAccent,
              isDark: isDark,
            ),

            // Average Daily Spending
            _buildStatCard(
              context,
              title: "Daily Average",
              value: "₹${avgDaily.toStringAsFixed(0)}/day",
              subtitle: "Over $periodDays days",
              icon: Icons.show_chart_rounded,
              color: primaryGreen,
              isDark: isDark,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 2. DAILY SPENDING TREND LINE CHART
  // =========================================================================
  Widget _buildDailySpendingTrendCard(
    BuildContext context,
    List<Expense> filteredExpenses,
    bool isDark,
    Color primaryGreen,
  ) {
    if (filteredExpenses.isEmpty) return const SizedBox();

    // Group expenses by date
    final Map<DateTime, double> dailyMap = {};
    final now = DateTime.now();
    final int days = _getPeriodDays();

    for (int i = days - 1; i >= 0; i--) {
      final d = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      dailyMap[d] = 0.0;
    }

    for (var e in filteredExpenses) {
      final key = DateTime(e.date.year, e.date.month, e.date.day);
      if (dailyMap.containsKey(key)) {
        dailyMap[key] = (dailyMap[key] ?? 0.0) + e.amount;
      }
    }

    final entries = dailyMap.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final List<FlSpot> spots = [];
    double maxY = 100;

    for (int i = 0; i < entries.length; i++) {
      final val = entries[i].value;
      if (val > maxY) maxY = val;
      spots.add(FlSpot(i.toDouble(), val));
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Daily Spending Trend",
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedRange,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) {
                        if (val == 0) return const SizedBox();
                        return Text(
                          "₹${val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toInt()}",
                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (entries.length / 4).clamp(1, 30).toDouble(),
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < entries.length) {
                          final dt = entries[idx].key;
                          return Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              DateFormat('d/M').format(dt),
                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (entries.length - 1).toDouble(),
                minY: 0,
                maxY: maxY * 1.15,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: primaryGreen,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: spots.length <= 14,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: primaryGreen,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: primaryGreen.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 3. TOP 5 EXPENSES CARD
  // =========================================================================
  Widget _buildTop5ExpensesCard(
    BuildContext context,
    Group group,
    List<Expense> filteredExpenses,
    bool isDark,
    Color primaryGreen,
  ) {
    final sorted = List<Expense>.from(filteredExpenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final top5 = sorted.take(5).toList();
    if (top5.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top 5 Largest Expenses",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: top5.map((expense) {
              final payer = group.participants.firstWhere(
                (p) => p.id == expense.payerId,
                orElse: () => Participant(id: '?', name: 'Unknown'),
              );
              final color = CategoryHelper.getColor(expense.categoryName);
              final icon = CategoryHelper.getIcon(expense.categoryName);
              final isLast = expense.id == top5.last.id;

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    title: Text(
                      expense.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Text(
                      "Paid by ${payer.name} • ${DateFormat.MMMd().format(expense.date)}",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: Text(
                      "₹${expense.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 4. TOP SPENDERS RANKINGS
  // =========================================================================
  Widget _buildTopSpendersCard(
    BuildContext context,
    Group group,
    List<Expense> filteredExpenses,
    bool isDark,
    Color primaryGreen,
  ) {
    final Map<String, double> spenderMap = {};
    for (var p in group.participants) {
      spenderMap[p.id] = 0.0;
    }
    for (var e in filteredExpenses) {
      spenderMap[e.payerId] = (spenderMap[e.payerId] ?? 0.0) + e.amount;
    }

    final sortedEntries = spenderMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final medals = ["🥇", "🥈", "🥉"];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Top Members by Amount Paid",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(sortedEntries.length, (index) {
              final entry = sortedEntries[index];
              final person = group.participants.firstWhere(
                (p) => p.id == entry.key,
                orElse: () => Participant(id: '?', name: 'Unknown'),
              );
              final isLast = index == sortedEntries.length - 1;
              final medal = index < 3 ? medals[index] : "#${index + 1}";

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        medal,
                        style: TextStyle(
                          fontSize: index < 3 ? 18 : 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      person.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${filteredExpenses.where((e) => e.payerId == person.id).length} payments",
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                    trailing: Text(
                      "₹${entry.value.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: Colors.grey.withValues(alpha: 0.1)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 5. RECENT INSIGHTS DYNAMIC CARDS
  // =========================================================================
  Widget _buildRecentInsightsSection(
    BuildContext context,
    Group group,
    List<Expense> filteredExpenses,
    double totalAmount,
    List<MapEntry<String, double>> activeCategories,
    bool isDark,
    Color primaryGreen,
  ) {
    if (filteredExpenses.isEmpty) return const SizedBox();

    final List<Map<String, String>> insights = [];

    // Category Insight 1
    if (activeCategories.isNotEmpty) {
      final topCat = activeCategories.first;
      final pct = (topCat.value / totalAmount) * 100;
      insights.add({
        "title": "Category Focus",
        "desc": "${topCat.key} accounts for ${pct.toStringAsFixed(0)}% of your spending.",
        "type": "pie",
      });
    }

    // Category Insight 2
    if (activeCategories.length >= 2) {
      final secondCat = activeCategories[1];
      insights.add({
        "title": "Second Largest Category",
        "desc": "${secondCat.key} is your second largest category at ₹${secondCat.value.toStringAsFixed(0)}.",
        "type": "tag",
      });
    }

    // Average Expense
    final avgExpense = totalAmount / filteredExpenses.length;
    insights.add({
      "title": "Average Expense",
      "desc": "Your average expense in this period is ₹${avgExpense.toStringAsFixed(0)}.",
      "type": "calc",
    });

    // Biggest Expense
    final biggest = filteredExpenses.reduce((a, b) => a.amount > b.amount ? a : b);
    insights.add({
      "title": "Peak Spending",
      "desc": "Your biggest single expense was '${biggest.title}' (₹${biggest.amount.toStringAsFixed(0)}).",
      "type": "fire",
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            "Recent Insights",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Column(
          children: insights.map((item) {
            IconData icon = Icons.lightbulb_outline_rounded;
            Color iconColor = Colors.amber[700]!;
            if (item["type"] == "pie") {
              icon = Icons.pie_chart_outline_rounded;
              iconColor = primaryGreen;
            } else if (item["type"] == "calc") {
              icon = Icons.calculate_outlined;
              iconColor = Colors.blueAccent;
            } else if (item["type"] == "fire") {
              icon = Icons.local_fire_department_outlined;
              iconColor = Colors.deepOrange;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["title"]!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item["desc"]!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =========================================================================
  // 6. CATEGORY HIGHLIGHTS
  // =========================================================================
  Widget _buildCategoryHighlightsSection(
    BuildContext context,
    List<Expense> filteredExpenses,
    bool isDark,
    Color primaryGreen,
  ) {
    if (filteredExpenses.isEmpty) return const SizedBox();

    final Map<String, List<double>> categoryAmounts = {};
    for (var e in filteredExpenses) {
      categoryAmounts.putIfAbsent(e.categoryName, () => []).add(e.amount);
    }

    if (categoryAmounts.isEmpty) return const SizedBox();

    // Most Used Category (by count)
    final mostUsedEntry = categoryAmounts.entries.reduce((a, b) => a.value.length > b.value.length ? a : b);
    // Least Used Category (by count)
    final leastUsedEntry = categoryAmounts.entries.reduce((a, b) => a.value.length < b.value.length ? a : b);

    // Category Averages
    final Map<String, double> categoryAvg = {};
    categoryAmounts.forEach((cat, list) {
      categoryAvg[cat] = list.reduce((a, b) => a + b) / list.length;
    });

    final highestAvgEntry = categoryAvg.entries.reduce((a, b) => a.value > b.value ? a : b);
    final lowestAvgEntry = categoryAvg.entries.reduce((a, b) => a.value < b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Category Highlights",
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHighlightTile(
                  "Most Frequent",
                  mostUsedEntry.key,
                  "${mostUsedEntry.value.length} expenses",
                  CategoryHelper.getIcon(mostUsedEntry.key),
                  CategoryHelper.getColor(mostUsedEntry.key),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightTile(
                  "Least Frequent",
                  leastUsedEntry.key,
                  "${leastUsedEntry.value.length} expense",
                  CategoryHelper.getIcon(leastUsedEntry.key),
                  CategoryHelper.getColor(leastUsedEntry.key),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHighlightTile(
                  "Highest Avg Expense",
                  highestAvgEntry.key,
                  "₹${highestAvgEntry.value.toStringAsFixed(0)}/avg",
                  CategoryHelper.getIcon(highestAvgEntry.key),
                  CategoryHelper.getColor(highestAvgEntry.key),
                  isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightTile(
                  "Lowest Avg Expense",
                  lowestAvgEntry.key,
                  "₹${lowestAvgEntry.value.toStringAsFixed(0)}/avg",
                  CategoryHelper.getIcon(lowestAvgEntry.key),
                  CategoryHelper.getColor(lowestAvgEntry.key),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightTile(
    String label,
    String category,
    String detail,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            category,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // 7. MONTH COMPARISON CARD
  // =========================================================================
  Widget _buildMonthComparisonCard(
    BuildContext context,
    List<Expense> allExpenses,
    bool isDark,
    Color primaryGreen,
  ) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final previousMonth = DateTime(now.year, now.month - 1);

    final currentTotal = allExpenses
        .where((e) => e.date.year == currentMonth.year && e.date.month == currentMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    final previousTotal = allExpenses
        .where((e) => e.date.year == previousMonth.year && e.date.month == previousMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);

    double diffPct = 0;
    bool isIncrease = true;
    if (previousTotal > 0) {
      final diff = currentTotal - previousTotal;
      diffPct = (diff.abs() / previousTotal) * 100;
      isIncrease = diff >= 0;
    } else if (currentTotal > 0) {
      diffPct = 100;
      isIncrease = true;
    }

    final prevMonthName = DateFormat('MMMM').format(previousMonth);
    final curMonthName = DateFormat('MMMM').format(currentMonth);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isIncrease ? Colors.orange : Colors.green).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded,
              color: isIncrease ? Colors.orange[800] : Colors.green[800],
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Month Comparison ($curMonthName vs $prevMonthName)",
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      isIncrease ? "↑ ${diffPct.toStringAsFixed(1)}% Increase" : "↓ ${diffPct.toStringAsFixed(1)}% Decrease",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isIncrease ? Colors.orange[800] : Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${currentTotal.toStringAsFixed(0)} vs ₹${previousTotal.toStringAsFixed(0)} in $prevMonthName",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
