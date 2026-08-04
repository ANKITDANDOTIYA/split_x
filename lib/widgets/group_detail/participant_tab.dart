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

    final screenWidth = MediaQuery.of(context).size.width;

    // ================= DESKTOP LAYOUT (screenWidth >= 900) =================
    if (screenWidth >= 900) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final crossAxisCount = screenWidth > 1200 ? 3 : 2;

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GridView.builder(
            key: const PageStorageKey<String>('people_desktop_grid'),
            padding: const EdgeInsets.all(24),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 3.2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: group.participants.length,
            itemBuilder: (context, index) {
              final person = group.participants[index];

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    hoverColor: Theme.of(context).primaryColor.withValues(alpha: 0.04),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              person.name.isNotEmpty
                                  ? person.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  person.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (person.hasContactInfo) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    person.displayInfo,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
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
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    // ================= EXISTING MOBILE LAYOUT (UNTOUCHED) =================
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
