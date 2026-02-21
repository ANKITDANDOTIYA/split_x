import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/participant.dart';
import '../../models/group.dart';
import '../../services/group_service.dart';

Future<void> showEditParticipantDialog({
  required BuildContext context,
  required Group group,
  required Participant participant,
}) {
  final TextEditingController nameController =
  TextEditingController(text: participant.name);
  final TextEditingController emailController =
  TextEditingController(text: participant.email ?? '');
  final TextEditingController phoneController =
  TextEditingController(text: participant.phone ?? '');

  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Edit Participant"),

      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: "Name *",
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email (optional)",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone (optional)",
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
      ),

      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (nameController.text.trim().isEmpty) return;

            Provider.of<GroupService>(
              context,
              listen: false,
            ).updateParticipant(
              group,
              participant,
              newName: nameController.text.trim(),
              email: emailController.text.trim().isEmpty
                  ? null
                  : emailController.text.trim(),
              phone: phoneController.text.trim().isEmpty
                  ? null
                  : phoneController.text.trim(),
            );

            Navigator.pop(ctx);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Participant updated"),
              ),
            );
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
