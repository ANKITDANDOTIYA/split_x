import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/group.dart';
import '../../models/participant.dart';
import '../../services/group_service.dart';
import '../dialogs/edit_participant_dialog.dart';

class ParticipantsTab extends StatelessWidget {
  final Group group;

  const ParticipantsTab({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    if (group.participants.isEmpty) {
      return const Center(child: Text("No participants yet."));
    }

    return ListView.separated(
      key: const PageStorageKey<String>('people'),
      padding: const EdgeInsets.all(16),
      itemCount: group.participants.length,
      separatorBuilder: (ctx, idx) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        final person = group.participants[index];
        final isLast = index == group.participants.length - 1;

        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 8,
              ),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor:
                Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  person.name.isNotEmpty
                      ? person.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onPrimaryContainer,
                  ),
                ),
              ),
              title: Text(
                person.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              subtitle: person.hasContactInfo
                  ? Text(
                person.displayInfo,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              )
                  : null,
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                onSelected: (value) {
                  if (value == 'edit') {
                    showEditParticipantDialog(
                      context: context,
                      group: group,
                      participant: person,
                    );
                  } else if (value == 'delete') {
                    _confirmDeleteParticipant(
                      context,
                      group,
                      person,
                    );
                  }
                },
                itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Name'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child:
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ),
            if (isLast) const SizedBox(height: 80), // FAB padding
          ],
        );
      },
    );
  }

  void _confirmDeleteParticipant(
      BuildContext context,
      Group group,
      Participant person,
      ) async {
    final error = await context
        .read<GroupService>()
        .deleteParticipant(group, person.id);

    if (error != null && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }
}



// Widget _buildParticipantsTab(GroupService service,Group group) {
//   if ( group.participants.isEmpty) {
//     return const Center(child: Text("No participants yet."));
//   }
//
//   return ListView.separated(
//     key: const PageStorageKey<String>('people'),
//     padding: const EdgeInsets.all(16),
//     itemCount:  group.participants.length,
//     separatorBuilder: (ctx, idx) =>
//         Divider(height: 1, color: Colors.grey[200]),
//     itemBuilder: (context, index) {
//       final person =  group.participants[index];
//       bool isLast = index ==  group.participants.length - 1;
//
//       return Column(
//         children: [
//           ListTile(
//             contentPadding: const EdgeInsets.symmetric(
//               vertical: 8,
//               horizontal: 8,
//             ),
//             leading: CircleAvatar(
//               radius: 24,
//               backgroundColor: Theme.of(context).colorScheme.primaryContainer,
//               child: Text(
//                 person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Theme.of(context).colorScheme.onPrimaryContainer,
//                 ),
//               ),
//             ),
//             title: Text(
//               person.name,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 16,
//               ),
//             ),
//             subtitle: person.hasContactInfo
//                 ? Text(
//               person.displayInfo,
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             )
//                 : null,
//             trailing: PopupMenuButton<String>(
//               icon: Icon(Icons.more_vert, color: Colors.grey[600]),
//               onSelected: (value) {
//                 if (value == 'edit') {
//                   showEditParticipantDialog(
//                     context: context,
//                     group: group,
//                     participant:  group.participants[index],
//                   );
//                   ;
//                 } else if (value == 'delete') {
//                   _confirmDeleteParticipant(context, person,group);
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                 const PopupMenuItem<String>(
//                   value: 'edit',
//                   child: Text('Edit Name'),
//                 ),
//                 const PopupMenuItem<String>(
//                   value: 'delete',
//                   child: Text('Delete', style: TextStyle(color: Colors.red)),
//                 ),
//               ],
//             ),
//           ),
//           if (isLast) const SizedBox(height: 80), // Padding for FAB
//         ],
//       );
//     },
//   );
// }
