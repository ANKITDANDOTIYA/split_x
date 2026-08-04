
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:split_expenses/services/auth_service.dart';
import '../services/group_service.dart';
// import '../services/auth_service.dart';
import '../models/group.dart';
import 'group_detail_screen.dart';
import 'profile_screen.dart';
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
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
                        colors: isDark
                            ? [
                                theme.colorScheme.primary.withValues(alpha: 0.2),
                                theme.colorScheme.surface,
                              ]
                            : [
                                theme.colorScheme.primary.withValues(alpha: 0.12),
                                theme.scaffoldBackgroundColor,
                              ],
                      ),
                    ),
                  ),
                ),

                // 🆕 Styled action buttons
                actions: [
                  // PROFILE BUTTON
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: "User Profile",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.person_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  // ADD GROUP BUTTON
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: "Add group",
                      onPressed: () => showAddGroupBottomSheet(context),
                      icon: Icon(
                        Icons.add_rounded,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),

                  // MORE OPTIONS MENU
                  PopupMenuButton<String>(
                    tooltip: "More options",
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (value) {
                      if (value == 'profile') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      } else if (value == 'logout') {
                        showLogoutBottomSheet(context);
                      }
                    },
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'profile',
                        child: Row(
                          children: const [
                            Icon(Icons.person_outline_rounded, color: Colors.blueAccent),
                            SizedBox(width: 10),
                            Text(
                              "My Profile",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          color: isDark ? Colors.grey[700] : Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No groups yet",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Create one to start splitting bills",
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
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
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isDesktop = screenWidth >= 900;

                    if (isDesktop) {
                      final crossAxisCount = screenWidth > 1200 ? 3 : 2;
                      return SliverToBoxAdapter(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1200),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: screenWidth > 1200 ? 2.8 : 2.5,
                                  crossAxisSpacing: 20,
                                  mainAxisSpacing: 20,
                                ),
                                itemCount: service.groups.length,
                                itemBuilder: (context, index) {
                                  final group = service.groups[index];
                                  return _buildGroupCard(
                                    context,
                                    group,
                                    index,
                                    service,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    // Mobile Layout (UNTOUCHED)
                    return SliverPadding(
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
                    );
                  },
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.grey.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          hoverColor: MediaQuery.of(context).size.width >= 900
              ? theme.colorScheme.primary.withValues(alpha: 0.04)
              : null,
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
                    color: isDark
                        ? theme.colorScheme.primary.withValues(alpha: 0.2)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      group.name.isNotEmpty ? group.name[0].toUpperCase() : '?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${group.expenses.length} expenses • ${group.participants.length} people",
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🆕 STATUS BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: group.expenses.isEmpty
                              ? Colors.amber.withValues(alpha: isDark ? 0.2 : 0.15)
                              : const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          group.expenses.isEmpty
                              ? "No expenses"
                              : "Active",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: group.expenses.isEmpty
                                ? (isDark ? Colors.amber[300] : const Color(0xFFD97706))
                                : (isDark ? Colors.green[300] : const Color(0xFF059669)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  DateFormat.MMMd().format(group.createdAt),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
