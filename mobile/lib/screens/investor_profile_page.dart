import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';

class InvestorProfilePage extends StatefulWidget {
  const InvestorProfilePage({super.key});

  @override
  State<InvestorProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<InvestorProfilePage> {
  bool _editingName = false;
  final TextEditingController _nameController = TextEditingController();

  void _openSettingsModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account & Security',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change password'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              title: const Text('Enable 2FA'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: () {
                Navigator.pop(context); // Close the modal first
                _signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        final displayName = user?['name'] ?? 'User';
        final displayLocation = user?['location'] ?? 'Location';
        final avatar = user?['avatar'];
        final verified = user?['verified'] ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1115),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  // simple edit avatar flow: show dialog to change initials/name
                  showDialog(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Edit profile picture'),
                      content: const Text(
                        'This demo allows only initials/avatar placeholder.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFF12171C),
                  backgroundImage: avatar != null ? NetworkImage(avatar) : null,
                  child: avatar == null
                      ? Text(
                          _initials(displayName),
                          style: const TextStyle(
                            color: Color(0xFF0F9D58),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _editingName
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _nameController,
                                        style: const TextStyle(
                                          color: Color(0xFFE6EEF3),
                                          fontSize: 18,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          setState(() => _editingName = false),
                                      icon: const Icon(
                                        Icons.check,
                                        color: Color(0xFF0F9D58),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          color: Color(0xFFE6EEF3),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          setState(() => _editingName = true),
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                        color: Color(0xFF9AA5AD),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12171C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.show_chart,
                                color: const Color(0xFF0F9D58),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Investor',
                                style: const TextStyle(
                                  color: Color(0xFFB7C2C8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (verified)
                                const Icon(
                                  Icons.verified,
                                  color: Color(0xFF66FFA6),
                                  size: 16,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          displayLocation,
                          style: const TextStyle(color: Color(0xFF9AA5AD)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_outlined,
                      color: Color(0xFF9AA5AD),
                    ),
                    onPressed: () async {
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.refreshInvestorData();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data refreshed successfully'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    splashRadius: 22,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF9AA5AD),
                    ),
                    onPressed: _openSettingsModal,
                    splashRadius: 22,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _quickStats() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        final totalInvestment = user?['totalInvestment']?.toDouble();
        final walletBalance = user?['walletBalance']?.toDouble();

        final cards = [
          {
            'title': 'Portfolio',
            'value': totalInvestment != null
                ? '₹${(totalInvestment / 100000).toStringAsFixed(1)}L'
                : '₹0L',
          },
          {'title': 'Active Tickets', 'value': '6'},
          {
            'title': 'Wallet Balance',
            'value': walletBalance != null
                ? '₹${walletBalance.toStringAsFixed(0)}'
                : '₹0',
          },
        ];

        return SizedBox(
          height: 108,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemBuilder: (c, i) {
              final item = cards[i];
              return Container(
                width: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12171C),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!,
                          style: const TextStyle(
                            color: Color(0xFF9AA5AD),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['value']!,
                          style: const TextStyle(
                            color: Color(0xFFE6EEF3),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.chevron_right,
                        color: const Color(0xFF9AA5AD),
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemCount: cards.length,
          ),
        );
      },
    );
  }

  Widget _sectionTile(
    String title, {
    String? subtitle,
    VoidCallback? onTap,
    IconData? leading,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: leading != null
          ? Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF12171C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leading, color: const Color(0xFF0F9D58)),
            )
          : null,
      title: Text(title, style: const TextStyle(color: Color(0xFFE6EEF3))),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Color(0xFF9AA5AD)))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF9AA5AD)),
      onTap: onTap,
      minLeadingWidth: 6,
      horizontalTitleGap: 8,
      dense: true,
    );
  }

  Widget _buildGroupedSections() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        final displayLocation = user?['location'] ?? 'Location';
        final verified = user?['verified'] ?? false;

        return Column(
          children: [
            // Account
            _groupCard(
              title: 'Account',
              children: [
                _sectionTile(
                  'Edit profile',
                  onTap: () {},
                  leading: Icons.person_outline,
                ),
                _sectionTile(
                  'Contact info',
                  onTap: () {},
                  leading: Icons.phone_android_outlined,
                ),
                _sectionTile(
                  'Location & City',
                  subtitle: displayLocation,
                  onTap: () {},
                  leading: Icons.location_on_outlined,
                ),
                _sectionTile(
                  'Dashboard Settings',
                  subtitle: 'Open Market',
                  onTap: () {},
                  leading: Icons.sync_alt,
                ),
              ],
            ),

            // Verification & Documents
            _groupCard(
              title: 'Verification & Documents',
              children: [
                _sectionTile(
                  'KYC Status',
                  subtitle: verified ? 'Verified — 2025-08-29' : 'Not started',
                  onTap: () {},
                  leading: Icons.fact_check_outlined,
                ),
                _sectionTile(
                  'Upload Documents',
                  onTap: () {},
                  leading: Icons.upload_file_outlined,
                ),
                _sectionTile(
                  'Signed Agreements',
                  onTap: () {},
                  leading: Icons.picture_as_pdf_outlined,
                ),
              ],
            ),

            // Payments & Payouts
            _groupCard(
              title: 'Payments & Payouts',
              children: [
                _sectionTile(
                  'Linked Bank Accounts',
                  onTap: () {},
                  leading: Icons.account_balance_outlined,
                ),
                _sectionTile(
                  'Payout Settings',
                  onTap: () {},
                  leading: Icons.settings,
                ),
                _sectionTile(
                  'Transaction History',
                  onTap: () {},
                  leading: Icons.history,
                ),
              ],
            ),

            // Security & Sessions
            _groupCard(
              title: 'Security & Sessions',
              children: [
                _sectionTile(
                  'Change Password',
                  onTap: () {},
                  leading: Icons.lock_outline,
                ),
                _sectionTile(
                  'Active Sessions',
                  onTap: () {},
                  leading: Icons.devices_other_outlined,
                ),
                _sectionTile(
                  'App Lock / Biometrics',
                  onTap: () {},
                  leading: Icons.fingerprint,
                ),
                _sectionTile(
                  'Delete Account',
                  onTap: () => _confirmDelete(),
                  leading: Icons.delete_outline,
                ),
              ],
            ),

            // Notifications
            _groupCard(
              title: 'Notifications & Preferences',
              children: [
                _sectionTile(
                  'Push & Email Preferences',
                  onTap: () {},
                  leading: Icons.notifications_active_outlined,
                ),
                _sectionTile(
                  'Language & Region',
                  onTap: () {},
                  leading: Icons.language,
                ),
                _sectionTile(
                  'Theme',
                  subtitle: 'Dark (system)',
                  onTap: () {},
                  leading: Icons.palette_outlined,
                ),
              ],
            ),

            // Activity
            _groupCard(
              title: 'Activity & History',
              children: [
                _sectionTile(
                  'My Investments',
                  onTap: () {},
                  leading: Icons.insights_outlined,
                ),
                _sectionTile(
                  'Repayment Calendar',
                  onTap: () {},
                  leading: Icons.calendar_today_outlined,
                ),
                _sectionTile(
                  'Saved shops / Watchlist',
                  onTap: () {},
                  leading: Icons.bookmark_outline,
                ),
              ],
            ),

            // Help & Legal
            _groupCard(
              title: 'Help & Legal',
              children: [
                _sectionTile(
                  'Contact support',
                  onTap: () {},
                  leading: Icons.support_agent_outlined,
                ),
                _sectionTile(
                  'FAQ / How it works',
                  onTap: () {},
                  leading: Icons.help_outline,
                ),
                _sectionTile(
                  'Terms & Privacy',
                  onTap: () {},
                  leading: Icons.description_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _groupCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF12171C),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF9AA5AD),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFF0F1720)),
          ...children,
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Signing out...'),
            ],
          ),
        ),
      );

      try {
        // Call sign out from AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signOut();

        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
        }

        // Navigate to welcome screen with fade animation
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  WelcomeScreen(onContinue: (_) {}),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
              transitionDuration: const Duration(milliseconds: 500),
            ),
            (route) => false, // Remove all previous routes
          );
        }
      } catch (e) {
        // Dismiss loading dialog
        if (mounted) {
          Navigator.of(context).pop(); // Dismiss loading dialog
        }

        // Show error if sign out fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This is irreversible. To proceed you will receive an email OTP.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Cancel'),
          ),
          ElevatedButton(onPressed: () {}, child: const Text('Proceed')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1115),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileHeaderDelegate(child: _buildHeader()),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _quickStats(),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 8)),
            SliverToBoxAdapter(child: _buildGroupedSections()),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _ProfileHeaderDelegate({required this.child});

  @override
  double get minExtent => 120;

  @override
  double get maxExtent => 160;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.transparent, child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}
