import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../services/group_service.dart';
import '../services/auth_service.dart';
import '../widgets/profile/profile_header.dart';
import '../widgets/profile/profile_tile.dart';
import '../widgets/profile/profile_dialogs.dart';
import '../widgets/theme_selection_dialog.dart';
import '../widgets/dialogs/logout_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    _profileProvider = ProfileProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupService = Provider.of<GroupService>(context, listen: false);
      _profileProvider.loadProfileData(groupService.groups);
    });
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupService = Provider.of<GroupService>(context);

    return ChangeNotifierProvider<ProfileProvider>.value(
      value: _profileProvider,
      child: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "User Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: "Refresh Profile",
                  onPressed: () => provider.refresh(groupService.groups),
                ),
              ],
            ),
            body: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => provider.refresh(groupService.groups),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Profile Header
                              ProfileHeader(
                                name: provider.displayName,
                                email: provider.email,
                                isVerified: provider.isEmailVerified,
                                photoUrl: provider.photoUrl,
                                memberSince: provider.memberSince,
                                onEditName: () => _handleEditName(context, provider),
                                onChangePhoto: () => _handleChangePhoto(context, provider),
                                onResendVerification: () =>
                                    _handleResendVerification(context, provider),
                              ),

                              const SizedBox(height: 24),

                              // 2. Profile Statistics Section
                              _buildStatisticsGrid(context, provider),

                              const SizedBox(height: 28),

                              // 3. Account Section
                              _buildSectionTitle(context, "ACCOUNT INFORMATION"),
                              const SizedBox(height: 8),
                              ProfileTile(
                                leadingIcon: Icons.person_outline_rounded,
                                title: "Name",
                                subtitle: provider.displayName,
                                trailing: const Icon(Icons.edit_outlined, size: 20),
                                onTap: () => _handleEditName(context, provider),
                              ),
                              ProfileTile(
                                leadingIcon: Icons.email_outlined,
                                title: "Email",
                                subtitle: provider.email,
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 18),
                                  tooltip: "Copy Email",
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: provider.email));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Email copied to clipboard"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              ProfileTile(
                                leadingIcon: provider.isEmailVerified
                                    ? Icons.verified_user_outlined
                                    : Icons.mark_email_unread_outlined,
                                iconColor: provider.isEmailVerified ? Colors.green : Colors.orange,
                                title: "Email Verification",
                                subtitle: provider.isEmailVerified
                                    ? "Verified account"
                                    : "Not verified (Tap to resend verification)",
                                trailing: provider.isEmailVerified
                                    ? const Icon(Icons.check_circle_rounded, color: Colors.green)
                                    : TextButton(
                                        onPressed: () =>
                                            _handleResendVerification(context, provider),
                                        child: const Text("Resend"),
                                      ),
                                onTap: provider.isEmailVerified
                                    ? null
                                    : () => _handleResendVerification(context, provider),
                              ),
                              ProfileTile(
                                leadingIcon: Icons.lock_reset_rounded,
                                title: "Change Password",
                                subtitle: "Update your account security password",
                                onTap: () => _handleChangePassword(context, provider),
                              ),
                              if (provider.memberSince != null)
                                ProfileTile(
                                  leadingIcon: Icons.calendar_month_outlined,
                                  title: "Member Since",
                                  subtitle: DateFormat.yMMMMd().format(provider.memberSince!),
                                ),

                              const SizedBox(height: 28),

                              // 4. App Section
                              _buildSectionTitle(context, "APP INFORMATION"),
                              const SizedBox(height: 8),
                              ProfileTile(
                                leadingIcon: Icons.info_outline_rounded,
                                title: "Version",
                                subtitle: "1.0.0+1 (Build 1)",
                              ),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return ProfileTile(
                                    leadingIcon: Icons.palette_outlined,
                                    title: "Theme Mode",
                                    subtitle: "${themeProvider.themeModeName} (Tap to change)",
                                    onTap: () => ThemeSelectionDialog.show(context),
                                  );
                                },
                              ),
                              ProfileTile(
                                leadingIcon: Icons.privacy_tip_outlined,
                                title: "Privacy Policy",
                                subtitle: "Read how your data is handled",
                                onTap: () => _showPrivacyPolicy(context),
                              ),
                              ProfileTile(
                                leadingIcon: Icons.description_outlined,
                                title: "Terms & Conditions",
                                subtitle: "View app terms of service",
                                onTap: () => _showTermsAndConditions(context),
                              ),
                              ProfileTile(
                                leadingIcon: Icons.groups_3_outlined,
                                title: "About Split Expenses",
                                subtitle: "Easily track, split bills & settle up expenses",
                                onTap: () => _showAboutApp(context),
                              ),

                              const SizedBox(height: 28),

                              // 5. Logout Tile
                              ProfileTile(
                                leadingIcon: Icons.logout_rounded,
                                title: "Logout",
                                subtitle: "Sign out of your account",
                                isDestructive: true,
                                onTap: () => showLogoutBottomSheet(context),
                              ),

                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context, ProfileProvider provider) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isWide ? 1.4 : 1.5,
          children: [
            _buildStatCard(
              context,
              icon: Icons.groups_rounded,
              color: Colors.blue,
              title: "Groups",
              value: provider.totalGroupsJoined.toString(),
            ),
            _buildStatCard(
              context,
              icon: Icons.receipt_long_rounded,
              color: Colors.purple,
              title: "Expenses",
              value: provider.totalExpensesCreated.toString(),
            ),
            _buildStatCard(
              context,
              icon: Icons.account_balance_wallet_rounded,
              color: Colors.green,
              title: "Total Paid",
              value: currencyFormat.format(provider.totalAmountPaid),
            ),
            _buildStatCard(
              context,
              icon: Icons.handshake_rounded,
              color: Colors.orange,
              title: "Settlements",
              value: provider.totalSettlementsMade.toString(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Handlers ---

  Future<void> _handleEditName(BuildContext context, ProfileProvider provider) async {
    final groupService = Provider.of<GroupService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final newName = await ProfileDialogs.showEditNameDialog(context, provider.displayName);
    if (newName != null && newName.isNotEmpty) {
      final success = await provider.updateName(
        newName,
        groupService: groupService,
        authService: authService,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Profile name updated successfully!" : (provider.errorMessage ?? "Failed to update name"),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangePhoto(BuildContext context, ProfileProvider provider) async {
    final groupService = Provider.of<GroupService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final photoUrl = await ProfileDialogs.showAvatarPickerSheet(context, provider.photoUrl);
    if (photoUrl != null) {
      final success = await provider.updatePhotoUrl(
        photoUrl,
        groupService: groupService,
        authService: authService,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? "Profile picture updated!" : (provider.errorMessage ?? "Failed to update photo"),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleChangePassword(BuildContext context, ProfileProvider provider) async {
    final newPassword = await ProfileDialogs.showChangePasswordDialog(context);
    if (newPassword != null && newPassword.isNotEmpty) {
      final success = await provider.changePassword(newPassword);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Password changed successfully!"
                : (provider.errorMessage ?? "Failed to change password."),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _handleResendVerification(BuildContext context, ProfileProvider provider) async {
    final success = await provider.resendVerificationEmail();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Verification email sent! Please check your inbox."
              : (provider.errorMessage ?? "Failed to send verification email."),
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    ProfileDialogs.showInfoModal(
      context,
      "Privacy Policy",
      "Your privacy is important to us. SplitX uses secure Firebase Cloud Authentication and encrypted Firestore storage to sync your group bill data.\n\n"
      "1. Data Collection: We store your name, email, and expense details strictly to perform bill splitting and group calculations.\n"
      "2. Data Security: All network communication is protected with SSL/TLS encryption.\n"
      "3. Third Parties: We do not sell or share your personal data with third-party advertisers.",
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    ProfileDialogs.showInfoModal(
      context,
      "Terms & Conditions",
      "By using SplitX, you agree to these terms:\n\n"
      "1. Responsible Use: You agree to keep accurate expense records and maintain your account credentials securely.\n"
      "2. Calculations: While we strive for absolute accuracy in bill splitting calculations, users should double-check custom split ratios.\n"
      "3. Account Integrity: Users are responsible for any activities originating from their account.",
    );
  }

  void _showAboutApp(BuildContext context) {
    ProfileDialogs.showInfoModal(
      context,
      "About SplitX",
      "SplitX (Smart Expense Manager)\nVersion 1.0.0+1\n\n"
      "Designed to effortlessly manage shared expenses with friends, family, and roommates.\n\n"
      "Features:\n"
      "• Equal & Custom Percentage/Exact Bill Splitting\n"
      "• Real-time Firebase Sync & Hive Local Cache\n"
      "• Automatic Settlement Tracking & Analytics\n"
      "• Modern Material 3 User Interface",
    );
  }
}
