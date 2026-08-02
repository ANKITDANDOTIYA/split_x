import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../widgets/category_helper.dart';

class AddExpenseScreen extends StatefulWidget {
  final Group group;
  final Expense? expenseToEdit;

  const AddExpenseScreen({
    super.key,
    required this.group,
    this.expenseToEdit,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  // Split & Payer Logic
  SplitType _selectedSplitType = SplitType.equal;
  final Map<String, TextEditingController> _splitControllers = {};
  String? _selectedPayerId;
  String _selectedCategory = 'Others';
  late DateTime _selectedDate;
  late Set<String> _selectedParticipantIds;

  bool get isEditing => widget.expenseToEdit != null;

  // Custom Green Color
  final Color primaryGreen = const Color(0xFF1B5E4F);

  @override
  void initState() {
    super.initState();

    final expense = widget.expenseToEdit;

    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = expense.amount == 0 ? '' : expense.amount.toString();
      _notesController.text = expense.notes ?? '';
      _selectedCategory = expense.categoryName;
      _selectedPayerId = expense.payerId;
      _selectedSplitType = expense.splitType;
      _selectedDate = expense.date;
      _selectedParticipantIds = Set<String>.from(expense.involvedParticipantIds);
    } else {
      _selectedDate = DateTime.now();
      _selectedParticipantIds = Set<String>.from(widget.group.participants.map((p) => p.id));
      if (widget.group.participants.isNotEmpty) {
        _selectedPayerId = widget.group.participants.first.id;
      }
    }

    for (var p in widget.group.participants) {
      double initialVal = expense?.customValues?[p.id] ?? 0;
      _splitControllers[p.id] = TextEditingController(
        text: expense != null && expense.splitType != SplitType.equal
            ? (initialVal == 0 ? '0' : initialVal.toString())
            : '0',
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    for (var c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final baseTheme = Theme.of(context);
        return Theme(
          data: baseTheme.copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: primaryGreen,
                    onPrimary: Colors.white,
                    surface: const Color(0xFF1E1E1E),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: primaryGreen,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black87,
                  ),
            dialogBackgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: primaryGreen,
              headerForegroundColor: Colors.white,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDate.hour,
          _selectedDate.minute,
        );
      });
    }
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPayerId == null) {
      _showSnackBar("Please select who paid!");
      return;
    }

    if (_selectedParticipantIds.isEmpty) {
      _showSnackBar("Please select at least one participant!");
      return;
    }

    double totalAmount = double.tryParse(_amountController.text) ?? 0;
    if (totalAmount <= 0) {
      _showSnackBar("Please enter a valid total amount!");
      return;
    }

    double currentSum = 0;
    Map<String, double> customValues = {};

    for (var id in _selectedParticipantIds) {
      final controller = _splitControllers[id];
      double val = double.tryParse(controller?.text ?? '0') ?? 0;
      currentSum += val;
      customValues[id] = val;
    }

    if (_selectedSplitType == SplitType.percentage && (currentSum - 100).abs() > 0.1) {
      _showSnackBar("Total percentage must equal 100%! (Current: ${currentSum.toStringAsFixed(1)}%)");
      return;
    }

    if (_selectedSplitType == SplitType.exact && (currentSum - totalAmount).abs() > 0.1) {
      _showSnackBar("Total fixed amounts must equal ₹$totalAmount! (Current: ₹${currentSum.toStringAsFixed(2)})");
      return;
    }

    final groupService = Provider.of<GroupService>(context, listen: false);

    if (isEditing) {
      final updatedExpense = Expense(
        id: widget.expenseToEdit!.id,
        title: _titleController.text.trim(),
        amount: totalAmount,
        payerId: _selectedPayerId!,
        involvedParticipantIds: _selectedParticipantIds.toList(),
        date: _selectedDate,
        splitType: _selectedSplitType,
        customValues: _selectedSplitType == SplitType.equal ? null : customValues,
        category: _selectedCategory,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      groupService.updateExpense(widget.group, updatedExpense);
      _showSnackBar("Expense updated successfully!");
    } else {
      groupService.addExpense(
        widget.group,
        _titleController.text.trim(),
        totalAmount,
        _selectedPayerId!,
        _selectedParticipantIds.toList(),
        splitType: _selectedSplitType,
        customValues: _selectedSplitType == SplitType.equal ? null : customValues,
        category: _selectedCategory,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        date: _selectedDate,
      );
      _showSnackBar("Expense saved successfully!");
    }

    Navigator.pop(context);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;

    final involvedParticipants = widget.group.participants
        .where((p) => _selectedParticipantIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Expense" : "Add New Expense",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Description (e.g. Dinner)",
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? "Enter a title" : null,
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: "Total Amount",
                  prefixText: "₹ ",
                  prefixIcon: Icon(Icons.currency_rupee),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter amount";
                  final numVal = double.tryParse(v);
                  if (numVal == null || numVal <= 0) return "Enter a valid amount > 0";
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Date Picker Field
              const Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: primaryGreen, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🏷️ Category Selection Dropdown
              const Text("Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    initialSelection: _selectedCategory,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(Theme.of(context).cardColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      elevation: WidgetStateProperty.all(10),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSelected: (String? value) {
                      if (value != null) {
                        setState(() => _selectedCategory = value);
                      }
                    },
                    dropdownMenuEntries: CategoryHelper.categories.map((cat) {
                      final icon = CategoryHelper.getIcon(cat);
                      final color = CategoryHelper.getColor(cat);
                      return DropdownMenuEntry<String>(
                        value: cat,
                        label: cat,
                        leadingIcon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 18, color: color),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Who Paid Dropdown
              const Text("Who paid?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  return DropdownMenu<String>(
                    width: constraints.maxWidth,
                    initialSelection: _selectedPayerId,
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(Theme.of(context).cardColor),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      elevation: WidgetStateProperty.all(10),
                    ),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSelected: (String? value) {
                      setState(() => _selectedPayerId = value);
                    },
                    dropdownMenuEntries: widget.group.participants.map((p) {
                      return DropdownMenuEntry<String>(
                        value: p.id,
                        label: p.name,
                        leadingIcon: CircleAvatar(
                          radius: 12,
                          backgroundColor: primaryGreen.withOpacity(0.1),
                          child: Text(p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 10, color: primaryGreen)),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Participants Multi-select Section
              const Text("Split with", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: widget.group.participants.map((p) {
                    final isSelected = _selectedParticipantIds.contains(p.id);
                    return CheckboxListTile(
                      activeColor: primaryGreen,
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedParticipantIds.add(p.id);
                          } else {
                            if (_selectedParticipantIds.length > 1) {
                              _selectedParticipantIds.remove(p.id);
                            } else {
                              _showSnackBar("At least one participant must be selected!");
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 25),
              const Text("How to split?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              Center(
                child: SegmentedButton<SplitType>(
                  segments: const [
                    ButtonSegment(value: SplitType.equal, label: Text("Equally"), icon: Icon(Icons.group)),
                    ButtonSegment(value: SplitType.percentage, label: Text("Perc"), icon: Icon(Icons.percent)),
                    ButtonSegment(value: SplitType.exact, label: Text("Fixed"), icon: Icon(Icons.currency_rupee)),
                  ],
                  selected: {_selectedSplitType},
                  onSelectionChanged: (val) => setState(() => _selectedSplitType = val.first),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),

              if (_selectedSplitType == SplitType.equal)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text("Bill will be split equally among selected members.")),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: involvedParticipants.length,
                  itemBuilder: (context, index) {
                    final p = involvedParticipants[index];
                    return ListTile(
                      title: Text(p.name),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _splitControllers[p.id],
                          textAlign: TextAlign.right,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onTap: () {
                            if (_splitControllers[p.id]?.text == '0') {
                              setState(() {
                                _splitControllers[p.id]!.text = '';
                              });
                            }
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            prefixText: _selectedSplitType == SplitType.percentage ? null : "₹ ",
                            suffixText: _selectedSplitType == SplitType.percentage ? "%" : null,
                            isDense: true,
                            filled: true,
                            fillColor: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          ),
                        ),
                      ),
                    );
                  },
                ),

              const SizedBox(height: 20),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Notes (Optional)",
                  hintText: "Add any additional details or notes...",
                  prefixIcon: const Icon(Icons.note_alt_outlined),
                  filled: true,
                  fillColor: isLight ? const Color(0xFFF1F3F4) : Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    isEditing ? "UPDATE EXPENSE" : "SAVE EXPENSE",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
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