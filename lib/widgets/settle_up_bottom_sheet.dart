//
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../models/group.dart';
// import '../models/participant.dart';
// import '../services/group_service.dart';
//
// class SettleUpBottomSheet extends StatefulWidget {
//   final Group group;
//   final Participant fromParticipant;
//   final Participant toParticipant;
//
//   const SettleUpBottomSheet({
//     super.key,
//     required this.group,
//     required this.fromParticipant,
//     required this.toParticipant,
//   });
//
//   @override
//   State<SettleUpBottomSheet> createState() => _SettleUpBottomSheetState();
// }
//
// class _SettleUpBottomSheetState extends State<SettleUpBottomSheet> {
//   final TextEditingController _amountController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     final service = Provider.of<GroupService>(context, listen: false);
//
//     return Padding(
//       padding: EdgeInsets.only(
//         left: 20,
//         right: 20,
//         top: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 45,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           const Text(
//             "Settle Up",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//
//           const SizedBox(height: 16),
//
//           Text(
//             "${widget.fromParticipant.name} will pay",
//             style: const TextStyle(color: Colors.grey),
//           ),
//
//           const SizedBox(height: 12),
//
//           TextField(
//             controller: _amountController,
//             keyboardType: TextInputType.number,
//             decoration: const InputDecoration(
//               prefixText: "₹ ",
//               labelText: "Amount",
//               border: OutlineInputBorder(borderRadius: BorderRadius.all),
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           Text(
//             "to ${widget.toParticipant.name}",
//             style: const TextStyle(color: Colors.grey),
//           ),
//
//           const SizedBox(height: 24),
//
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final amount =
//                     double.tryParse(_amountController.text);
//
//                     if (amount == null || amount <= 0) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Enter a valid amount"),
//                         ),
//                       );
//                       return;
//                     }
//
//                     await service.settleUp(
//                       group: widget.group,
//                       fromParticipantId: widget.fromParticipant.id,
//                       toParticipantId: widget.toParticipant.id,
//                       amount: amount,
//                     );
//
//                     Navigator.pop(context);
//                   },
//                   child: const Text("Confirm"),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/group.dart';
import '../models/participant.dart';
import '../services/group_service.dart';

class SettleUpBottomSheet extends StatefulWidget {
  final Group group;
  final Participant fromParticipant;
  final Participant toParticipant;

  const SettleUpBottomSheet({
    super.key,
    required this.group,
    required this.fromParticipant,
    required this.toParticipant,
  });

  @override
  State<SettleUpBottomSheet> createState() => _SettleUpBottomSheetState();
}

class _SettleUpBottomSheetState extends State<SettleUpBottomSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<GroupService>(context, listen: false);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 45,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 42,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Text(
            "Settle Up",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // From → To info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _AvatarChip(name: widget.fromParticipant.name),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              _AvatarChip(name: widget.toParticipant.name),
            ],
          ),

          const SizedBox(height: 24),

          // Amount field (highlighted)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                prefixText: "₹ ",
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                hintText: "0.00",
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    // backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    final amount =
                    double.tryParse(_amountController.text);

                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Enter a valid amount"),
                        ),
                      );
                      return;
                    }

                    await service.settleUp(
                      group: widget.group,
                      fromParticipantId: widget.fromParticipant.id,
                      toParticipantId: widget.toParticipant.id,
                      amount: amount,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Confirm Payment",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarChip extends StatelessWidget {
  final String name;

  const _AvatarChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.blueGrey.shade100,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
