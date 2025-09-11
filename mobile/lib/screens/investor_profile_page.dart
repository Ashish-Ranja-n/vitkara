import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _name = 'John Doe';
  final bool _verified = true;
  final String _city = 'Delhi';
  String _defaultDashboard = 'Open Market';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _defaultDashboard = prefs.getString('default_dashboard') ?? 'Open Market';
      _name = prefs.getString('profile_name') ?? _name;
      _nameController.text = _name;
    });
  }

  Future<void> _setDefaultDashboard(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_dashboard', value);
    setState(() => _defaultDashboard = value);
  }

  Future<void> _saveName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text.trim());
    setState(() {
      _name = _nameController.text.trim();
      _editingName = false;
    });
  }

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
              child: Text(
                _initials(_name),
                style: const TextStyle(
                  color: Color(0xFF0F9D58),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
                                  onPressed: _saveName,
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
                                    _name,
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
                            style: const TextStyle(color: Color(0xFFB7C2C8)),
                          ),
                          const SizedBox(width: 8),
                          if (_verified)
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
                      style: TextStyle(color: Colors.white.withOpacity(0.3)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _city,
                      style: const TextStyle(color: Color(0xFF9AA5AD)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF9AA5AD)),
            onPressed: _openSettingsModal,
            splashRadius: 22,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _quickStats() {
    final cards = [
      {'title': 'Portfolio', 'value': '₹1.2L'},
      {'title': 'Active Tickets', 'value': '6'},
      {'title': 'Daily Payouts', 'value': '₹1,800'},
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
              subtitle: _city,
              onTap: () {},
              leading: Icons.location_on_outlined,
            ),
            _sectionTile(
              'Default dashboard',
              subtitle: _defaultDashboard,
              onTap: () => _showDefaultDashboardChooser(),
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
              subtitle: _verified ? 'Verified — 2025-08-29' : 'Not started',
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

  void _showDefaultDashboardChooser() {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Open Market'),
              value: 'Open Market',
              groupValue: _defaultDashboard,
              onChanged: (v) {
                if (v != null) {
                  _setDefaultDashboard(v);
                  Navigator.pop(c);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Raise Fund'),
              value: 'Raise Fund',
              groupValue: _defaultDashboard,
              onChanged: (v) {
                if (v != null) {
                  _setDefaultDashboard(v);
                  Navigator.pop(c);
                }
              },
            ),
          ],
        ),
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
      try {
        // Call sign out from AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.signOut();

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
