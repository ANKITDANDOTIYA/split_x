
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:split_expenses/services/auth_service.dart';
import '../services/group_service.dart';
// import '../services/auth_service.dart';
import '../models/group.dart';
import 'group_detail_screen.dart';
import '../widgets/dialogs/logout_dialog.dart';
import '../widgets/dialogs/delete_group_dialog.dart';
import '../widgets/dialogs/add_group.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 🆕 Animation controller for staggered cards
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    // ✅ Load groups once screen is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupService>(context, listen: false).loadGroups();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
    Provider.of<AuthService>(context, listen: false).updateFCMToken();
  });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }




  // ================= ADD GROUP DIALOG =================





  // ================= MAIN BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // ✅ Consumer listens to GroupService changes
      body: Consumer<GroupService>(
        builder: (context, service, child) {
          return CustomScrollView(
            slivers: [
              // ================= APP BAR (IMPROVED) =================
              SliverAppBar.large(
                stretch: true,
                pinned: true,
                floating: true,

                // 🆕 Better height for large title effect
                expandedHeight: 120,

                // 🆕 Flexible space with gradient + animation
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    "My Groups",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.fadeTitle,
                  ],

                  // 🆕 Subtle gradient background (looks premium)
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.15),
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                  ),
                ),

                // 🆕 Styled action buttons
                actions: [
                  // ADD GROUP BUTTON
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: "Add group",
          onPressed: () => showAddGroupBottomSheet(context),

          icon: const Icon(Icons.add_rounded),
                    ),
                  ),

                  // LOGOUT MENU
                  PopupMenuButton<String>(
                    tooltip: "More options",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      if (value == 'logout') showLogoutBottomSheet(context);
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: const [
                            Icon(Icons.logout_rounded, color: Colors.redAccent),
                            SizedBox(width: 10),
                            Text(
                              "Logout",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),
                ],
              ),


              // ================= LOADING =================
              if (service.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )

              // ================= EMPTY STATE =================
              else if (service.groups.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.groups_outlined,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No groups yet",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Create one to start splitting bills",
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
          onPressed: () => showAddGroupBottomSheet(context),

          icon: const Icon(Icons.add),
                          label: const Text("Create Group"),
                        ),
                      ],
                    ),
                  ),
                )

              // ================= GROUP LIST =================
              else
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final group = service.groups[index];
                        return _buildGroupCard(
                          context,
                          group,
                          index,
                          service,
                        );
                      },
                      childCount: service.groups.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ================= GROUP CARD =================
  Widget _buildGroupCard(
      BuildContext context,
      Group group,
      int index,
      GroupService service,
      ) {
    // 🆕 staggered animation
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        (index * 0.1).clamp(0.0, 1.0),
        1,
        curve: Curves.easeOut,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - animation.value)),
          child: Opacity(opacity: animation.value, child: child),
        );
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailScreen(groupId: group.id),
              ),
            );
          },



            onLongPress: () {
              showDeleteGroupBottomSheet(
                context: context,
                groupName: group.name,
                onDelete: () => service.deleteGroup(group.id),
              );
            },



            child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color:
                    Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      group.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        // color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${group.expenses.length} expenses • ${group.participants.length} people",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),

                      // 🆕 STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: group.expenses.isEmpty
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          group.expenses.isEmpty
                              ? "No expenses"
                              : "Active",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: group.expenses.isEmpty
                                ? Colors.orange
                                : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  DateFormat.MMMd().format(group.createdAt),
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
