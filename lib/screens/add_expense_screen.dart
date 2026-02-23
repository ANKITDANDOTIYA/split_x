//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/expense.dart';
// import '../models/group.dart';
// import '../services/group_service.dart';
// import '../services/auth_service.dart';
//
// class AddExpenseScreen extends StatefulWidget {
//   final Group group;
//
//   const AddExpenseScreen({super.key, required this.group});
//
//   @override
//   State<AddExpenseScreen> createState() => _AddExpenseScreenState();
// }
//
// class _AddExpenseScreenState extends State<AddExpenseScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _amountController = TextEditingController();
//
//   // Split & Payer Logic
//   SplitType _selectedSplitType = SplitType.equal;
//   final Map<String, TextEditingController> _splitControllers = {};
//   String? _selectedPayerId; // 👈 Payer store karne ke liye
//
//   @override
//   void initState() {
//     super.initState();
//     // Default payer group ka pehla banda rakho
//     if (widget.group.participants.isNotEmpty) {
//       _selectedPayerId = widget.group.participants.first.id;
//     }
//     for (var p in widget.group.participants) {
//       _splitControllers[p.id] = TextEditingController(text: '0');
//     }
//   }
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _amountController.dispose();
//     for (var c in _splitControllers.values) {
//       c.dispose();
//     }
//     super.dispose();
//   }
//
//   void _saveExpense() {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedPayerId == null) {
//       _showSnackBar("Please select who paid!");
//       return;
//     }
//
//     double totalAmount = double.tryParse(_amountController.text) ?? 0;
//     double currentSum = 0;
//     Map<String, double> customValues = {};
//
//     _splitControllers.forEach((id, controller) {
//       double val = double.tryParse(controller.text) ?? 0;
//       currentSum += val;
//       customValues[id] = val;
//     });
//
//     if (_selectedSplitType == SplitType.percentage && currentSum != 100) {
//       _showSnackBar("Total percentage 100% honi chahiye! (Abhi: $currentSum%)");
//       return;
//     }
//     if (_selectedSplitType == SplitType.exact && (currentSum - totalAmount).abs() > 0.1) {
//       _showSnackBar("Total ₹$totalAmount hona chahiye! (Abhi: ₹$currentSum)");
//       return;
//     }
//
//     final groupService = Provider.of<GroupService>(context, listen: false);
//
//     groupService.addExpense(
//       widget.group,
//       _titleController.text,
//       totalAmount,
//       _selectedPayerId!, // 👈 Ab dropdown wala payer jayega
//       widget.group.participants.map((p) => p.id).toList(),
//       splitType: _selectedSplitType,
//       customValues: _selectedSplitType == SplitType.equal ? null : customValues,
//     );
//
//     Navigator.pop(context);
//   }
//
//   void _showSnackBar(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Add New Expense")),
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: "Description (e.g. Dinner)"),
//                 validator: (v) => v!.isEmpty ? "Enter a title" : null,
//               ),
//               const SizedBox(height: 10),
//               TextFormField(
//                 controller: _amountController,
//                 decoration: const InputDecoration(labelText: "Total Amount", prefixText: "₹ "),
//                 keyboardType: TextInputType.number,
//                 validator: (v) => v!.isEmpty ? "Enter amount" : null,
//               ),
//               const SizedBox(height: 20),
//
//               // 🟢 WHO PAID DROPDOWN
//               const Text("Who paid?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//
// // DropdownMenu use kar rahe hain jo rectangle issue fix karega
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   return DropdownMenu<String>(
//                     width: constraints.maxWidth, // Screen ki poori width lega
//                     initialSelection: _selectedPayerId,
//
//                     // 🟢 List ki styling
//                     menuStyle: MenuStyle(
//                       backgroundColor: WidgetStateProperty.all(Theme.of(context).cardColor),
//                       shape: WidgetStateProperty.all(
//                         RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                       ),
//                       elevation: WidgetStateProperty.all(10),
//                     ),
//
//                     // 🟢 Input box ki styling (Image jaisi)
//                     inputDecorationTheme: InputDecorationTheme(
//                       filled: true,
//                       fillColor: Theme.of(context).brightness == Brightness.light
//                           ? const Color(0xFFF1F3F4)
//                           : Colors.white.withOpacity(0.05),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
//                     ),
//
//                     onSelected: (String? value) {
//                       setState(() => _selectedPayerId = value);
//                     },
//
//                     dropdownMenuEntries: widget.group.participants.map((p) {
//                       return DropdownMenuEntry<String>(
//                         value: p.id,
//                         label: p.name,
//                         leadingIcon: CircleAvatar(
//                           radius: 12,
//                           backgroundColor: const Color(0xFF1B5E4F).withOpacity(0.1),
//                           child: Text(p.name[0].toUpperCase(),
//                               style: const TextStyle(fontSize: 10, color: Color(0xFF1B5E4F))),
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 25),
//               const Text("How to split?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//               const SizedBox(height: 10),
//
//               Center(
//                 child: SegmentedButton<SplitType>(
//                   segments: const [
//                     ButtonSegment(value: SplitType.equal, label: Text("Equally"), icon: Icon(Icons.group)),
//                     ButtonSegment(value: SplitType.percentage, label: Text("%"), icon: Icon(Icons.percent)),
//                     ButtonSegment(value: SplitType.exact, label: Text("Fixed"), icon: Icon(Icons.currency_rupee)),
//                   ],
//                   selected: {_selectedSplitType},
//                   onSelectionChanged: (val) => setState(() => _selectedSplitType = val.first),
//                 ),
//               ),
//
//               const SizedBox(height: 20),
//               const Divider(),
//
//               if (_selectedSplitType == SplitType.equal)
//                 const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20),
//                   child: Center(child: Text("Bill will be split equally among all members.")),
//                 )
//               else
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: widget.group.participants.length,
//                   itemBuilder: (context, index) {
//                     final p = widget.group.participants[index];
//                     return ListTile(
//                       title: Text(p.name),
//                       trailing: SizedBox(
//                         width: 100,
//                         child: TextField(
//                           controller: _splitControllers[p.id],
//                           keyboardType: TextInputType.number,
//                           decoration: InputDecoration(
//                             suffixText: _selectedSplitType == SplitType.percentage ? "%" : "₹",
//                             isDense: true,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//
//               const SizedBox(height: 30),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _saveExpense,
//                   style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
//                   child: const Text("SAVE EXPENSE", style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/group.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final Group group;

  const AddExpenseScreen({super.key, required this.group});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  // Split & Payer Logic
  SplitType _selectedSplitType = SplitType.equal;
  final Map<String, TextEditingController> _splitControllers = {};
  String? _selectedPayerId;

  // Custom Green Color from your image
  final Color primaryGreen = const Color(0xFF1B5E4F);

  @override
  void initState() {
    super.initState();
    if (widget.group.participants.isNotEmpty) {
      _selectedPayerId = widget.group.participants.first.id;
    }
    for (var p in widget.group.participants) {
      _splitControllers[p.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    for (var c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveExpense() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPayerId == null) {
      _showSnackBar("Please select who paid!");
      return;
    }

    double totalAmount = double.tryParse(_amountController.text) ?? 0;
    double currentSum = 0;
    Map<String, double> customValues = {};

    _splitControllers.forEach((id, controller) {
      double val = double.tryParse(controller.text) ?? 0;
      currentSum += val;
      customValues[id] = val;
    });

    if (_selectedSplitType == SplitType.percentage && currentSum != 100) {
      _showSnackBar("Total percentage 100% honi chahiye! (Abhi: $currentSum%)");
      return;
    }
    if (_selectedSplitType == SplitType.exact && (currentSum - totalAmount).abs() > 0.1) {
      _showSnackBar("Total ₹$totalAmount hona chahiye! (Abhi: ₹$currentSum)");
      return;
    }

    final groupService = Provider.of<GroupService>(context, listen: false);

    groupService.addExpense(
      widget.group,
      _titleController.text,
      totalAmount,
      _selectedPayerId!,
      widget.group.participants.map((p) => p.id).toList(),
      splitType: _selectedSplitType,
      customValues: _selectedSplitType == SplitType.equal ? null : customValues,
    );

    Navigator.pop(context);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    bool isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Expense", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Description (e.g. Dinner)"),
                validator: (v) => v!.isEmpty ? "Enter a title" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Total Amount", prefixText: "₹ "),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Enter amount" : null,
              ),
              const SizedBox(height: 20),

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
                          child: Text(p.name[0].toUpperCase(),
                              style: TextStyle(fontSize: 10, color: primaryGreen)),
                        ),
                      );
                    }).toList(),
                  );
                },
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
                  child: Center(child: Text("Bill will be split equally among all members.")),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.group.participants.length,
                  itemBuilder: (context, index) {
                    final p = widget.group.participants[index];
                    return ListTile(
                      title: Text(p.name),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          controller: _splitControllers[p.id], // Specific user ka controller
                          textAlign: TextAlign.right,
                          keyboardType: TextInputType.number,

                          // 🟢 YE HAI LOGIC: Sirf isi field ka 0 hatega jispe tap hua hai
                          onTap: () {
                            if (_splitControllers[p.id]!.text == '0') {
                              setState(() {
                                _splitControllers[p.id]!.text = '';
                              });
                            }
                          },

                          // 🟢 Optional: Agar user khali chhod de toh wapas 0 ho jaye (taaki calculation na tute)
                          onChanged: (value) {
                            setState(() {}); // Calculation update karne ke liye
                          },

                          decoration: InputDecoration(
                            // Rupaye aage aur Percentage peeche wala logic
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
                  child: const Text("SAVE EXPENSE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}