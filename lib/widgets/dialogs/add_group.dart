// import 'package:flutter/material.dart' show ElevatedButton, Navigator, TextButton, Colors, Icons, CircleAvatar, Theme, showModalBottomSheet, TextField, InputDecoration, SnackBar, TextCapitalization, ScaffoldMessenger;
// import 'package:flutter/widgets.dart';
// import 'package:provider/provider.dart';
// import 'package:split_expenses/services/auth_service.dart';
// import 'package:split_expenses/services/group_service.dart';
//
//
//
// void _showAddGroupDialog(BuildContext context) {
//   final controller = TextEditingController();
//   final focusNode = FocusNode();
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//     ),
//     builder: (context) {
//       return AnimatedPadding(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//
//         // ✅ keyboard-aware padding (ONLY this)
//         padding: EdgeInsets.only(
//           bottom: MediaQuery.of(context).viewInsets.bottom,
//         ),
//
//         child: SafeArea(
//           top: false,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Handle
//                 Container(
//                   width: 40,
//                   height: 4,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[400],
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//
//                 Text(
//                   "Create new group",
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
//
//                 TextField(
//                   controller: controller,
//                   focusNode: focusNode,
//                   autofocus: false, // ✅ now safe
//                   textCapitalization: TextCapitalization.sentences,
//                   decoration: const InputDecoration(
//                     labelText: "Group name",
//                     prefixIcon: Icon(Icons.group_add_outlined),
//                   ),
//                 ),
//
//                 const SizedBox(height: 24),
//
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size.fromHeight(48),
//                   ),
//                   onPressed: () {
//                     final name = controller.text.trim();
//                     if (name.isEmpty) return;
//
//                     Provider.of<GroupService>(
//                       context,
//                       listen: false,
//                     ).createGroup(name);
//
//                     Navigator.pop(context);
//
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text("Group created successfully"),
//                       ),
//                     );
//                   },
//                   child: const Text("Create Group"),
//                 ),
//
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/group_service.dart';

Future<void> showAddGroupBottomSheet(BuildContext context) {
  final TextEditingController controller = TextEditingController();

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  "Create new group",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: "Group name",
                    prefixIcon: Icon(Icons.group_add_outlined),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;

                    Provider.of<GroupService>(
                      context,
                      listen: false,
                    ).createGroup(name);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Group created successfully"),
                      ),
                    );
                  },
                  child: const Text("Create Group"),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
