// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/group.dart';
// import '../services/group_service.dart';
// import '../widgets/settle_up_bottom_sheet.dart';
//
// class SummaryScreen extends StatelessWidget {
//   final Group group;
//   const SummaryScreen({super.key, required this.group});
//
//   @override
//   Widget build(BuildContext context) {
//     // Watch service for updates if expenses change elsewhere, though typically we just view this.
//     final service = Provider.of<GroupService>(context);
//     final settlements = service.getSettlements(group);
//     final balances = service.getNetBalances(group);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Balances & Settlement")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "How to settle up:",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (settlements.isEmpty)
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 20),
//                 child: Center(
//                   child: Text(
//                     "Everyone is settled up! \nNo debts.",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 16, color: Colors.grey),
//                   ),
//                 ),
//               )
//             else
//               ...settlements.map(
//                 (s) => Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: ListTile(
//                     leading: const Icon(
//                       Icons.monetization_on,
//                       color: Colors.green,
//                     ),
//                     title: Text(
//                       s,
//                       style: const TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//               ),
//
//             const Divider(height: 48, thickness: 2),
//
//             const Text(
//               "Net Balances:",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "(Positive = Owed to them, Negative = They owe)",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//             if (group.participants.isEmpty)
//               const Text("No participants.")
//             else
//               ...group.participants.map((p) {
//                 final balance = balances[p.id] ?? 0.0;
//                 final isPositive = balance >= 0;
//                 final color = isPositive ? Colors.green : Colors.red;
//                 return ListTile(
//                   contentPadding: EdgeInsets.zero,
//                   title: Text(p.name),
//                   trailing: Text(
//                     "${isPositive ? '+' : ''}₹${balance.toStringAsFixed(2)}",
//                     style: TextStyle(
//                       color: color,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                 );
//               }),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/group.dart';
// import '../models/participant.dart';
// import '../services/group_service.dart';
// import '../widgets/settle_up_bottom_sheet.dart';
//
// class SummaryScreen extends StatelessWidget {
//   final Group group;
//   const SummaryScreen({super.key, required this.group});
//
//   @override
//   Widget build(BuildContext context) {
//     final service = Provider.of<GroupService>(context, listen: true);
//
//     final balances = service.getNetBalances(group);
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Balances & Settlement")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "How to settle up:",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             /// ================= SETTLEMENT SUGGESTIONS =================
//             ..._buildSettlementCards(
//               context: context,
//               group: group,
//               balances: balances,
//             ),
//
//             const Divider(height: 48, thickness: 2),
//
//             /// ================= NET BALANCES =================
//             const Text(
//               "Net Balances:",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.teal,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               "(Positive = Owed to them, Negative = They owe)",
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//             const SizedBox(height: 16),
//
//             ...group.participants.map((p) {
//               final balance = balances[p.id] ?? 0.0;
//               final isPositive = balance >= 0;
//               final color = isPositive ? Colors.green : Colors.red;
//
//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 title: Text(p.name),
//                 trailing: Text(
//                   "${isPositive ? '+' : ''}₹${balance.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     color: color,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// ================= LOGIC KE SAATH UI (SEPARATE FUNCTION) =================
//   static List<Widget> _buildSettlementCards({
//     required BuildContext context,
//     required Group group,
//     required Map<String, double> balances,
//   }) {
//     final debtors = balances.entries.where((e) => e.value < -0.01).toList();
//     final creditors = balances.entries.where((e) => e.value > 0.01).toList();
//
//     if (debtors.isEmpty || creditors.isEmpty) {
//       return const [
//         Center(
//           child: Padding(
//             padding: EdgeInsets.symmetric(vertical: 24),
//             child: Text(
//               "Everyone is settled up 🎉",
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//           ),
//         ),
//       ];
//     }
//
//     List<Widget> widgets = [];
//
//     int i = 0;
//     int j = 0;
//
//     while (i < debtors.length && j < creditors.length) {
//       final debtorEntry = debtors[i];
//       final creditorEntry = creditors[j];
//
//       final debtor = group.participants.firstWhere(
//             (p) => p.id == debtorEntry.key,
//         orElse: () => Participant(id: '', name: 'Unknown'),
//       );
//       final creditor = group.participants.firstWhere(
//             (p) => p.id == creditorEntry.key,
//         orElse: () => Participant(id: '', name: 'Unknown'),
//       );
//
//       final amount = (-debtorEntry.value < creditorEntry.value)
//           ? -debtorEntry.value
//           : creditorEntry.value;
//
//       widgets.add(
//         Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           child: ListTile(
//             leading: const Icon(Icons.currency_rupee, color: Colors.green),
//             title: Text(
//               "${debtor.name} owes ${creditor.name}",
//               style: const TextStyle(fontWeight: FontWeight.w600),
//             ),
//             subtitle: Text("₹${amount.toStringAsFixed(2)}"),
//             trailing: ElevatedButton(
//               child: const Text("Settle"),
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   builder: (_) => SettleUpBottomSheet(
//                     group: group,
//                     fromParticipant: debtor,
//                     toParticipant: creditor,
//
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       );
//
//       // update remaining amounts
//       debtors[i] = MapEntry(debtorEntry.key, debtorEntry.value + amount);
//       creditors[j] = MapEntry(creditorEntry.key, creditorEntry.value - amount);
//
//       if (debtors[i].value.abs() < 0.01) i++;
//       if (creditors[j].value.abs() < 0.01) j++;
//     }
//
//     return widgets;
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
// import '../models/participant.dart';
import '../services/group_service.dart';
import '../widgets/settle_up_bottom_sheet.dart';

class SummaryScreen extends StatelessWidget {
  final String groupId; // 🔥 IMPORTANT CHANGE

  const SummaryScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Consumer<GroupService>(
      builder: (context, service, _) {
        // 🔥 ALWAYS GET LATEST GROUP FROM PROVIDER
        final group = service.groups.firstWhere(
              (g) => g.id == groupId,
        );

        final balances = service.getNetBalances(group);

        return Scaffold(
          appBar: AppBar(title: const Text("Balances & Settlement")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "How to settle up:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),

                ..._buildSettlementCards(
                  context: context,
                  group: group,
                  balances: balances,
                ),

                const Divider(height: 48, thickness: 2),

                const Text(
                  "Net Balances:",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),

                ...group.participants.map((p) {
                  final bal = balances[p.id] ?? 0.0;
                  return ListTile(
                    title: Text(p.name),
                    trailing: Text(
                      "${bal >= 0 ? '+' : ''}₹${bal.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: bal >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  static List<Widget> _buildSettlementCards({
    required BuildContext context,
    required Group group,
    required Map<String, double> balances,
  }) {
    final debtors = balances.entries
        .where((e) => e.value < -0.01)
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    final creditors = balances.entries
        .where((e) => e.value > 0.01)
        .map((e) => MapEntry(e.key, e.value))
        .toList();

    if (debtors.isEmpty || creditors.isEmpty) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text("Everyone is settled up 🎉"),
          ),
        ),
      ];
    }

    List<Widget> widgets = [];
    int i = 0, j = 0;

    while (i < debtors.length && j < creditors.length) {
      final d = debtors[i];
      final c = creditors[j];

      final debtor = group.participants.firstWhere((p) => p.id == d.key);
      final creditor = group.participants.firstWhere((p) => p.id == c.key);

      final amount =
      (-d.value < c.value) ? -d.value : c.value;

      widgets.add(
        Card(
          child: ListTile(
            title: Text("${debtor.name} owes ${creditor.name}"),
            subtitle: Text("₹${amount.toStringAsFixed(2)}"),
            trailing: ElevatedButton(
              child: const Text("Settle"),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => SettleUpBottomSheet(
                    group: group,
                    fromParticipant: debtor,
                    toParticipant: creditor,
                  ),
                );
              },
            ),
          ),
        ),
      );

      debtors[i] = MapEntry(d.key, d.value + amount);
      creditors[j] = MapEntry(c.key, c.value - amount);

      if (debtors[i].value.abs() < 0.01) i++;
      if (creditors[j].value.abs() < 0.01) j++;
    }

    return widgets;
  }
}
