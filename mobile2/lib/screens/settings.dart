import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/setting_row.dart';
import 'settings/bank_details.dart';
import 'settings/payout_settings.dart';
import 'settings/qr_management.dart';
import 'settings/kyc_documents.dart';
import 'settings/security_settings.dart';
import 'settings/notifications.dart';
import 'settings/support.dart';
import '../utils/storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic> profile = {};
  Map<String, dynamic> notificationSettings = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await Storage.getJson(
      'profile',
      (o) => o as Map<String, dynamic>? ?? {},
    );
    final n = await Storage.getJson(
      'notification_settings',
      (o) => o as Map<String, dynamic>? ?? {},
    );
    setState(() {
      profile =
          p ??
          {
            'shopName': "Ashish's Chai Point",
            'contact': '+91 98765 43210',
            'email': 'shop@example.com',
          };
      notificationSettings =
          n ??
          {
            'new_investment': true,
            'payment_received': true,
            'payouts': true,
            'system': false,
          };
    });
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(
      text: profile['shopName'] ?? '',
    );
    final contactController = TextEditingController(
      text: profile['contact'] ?? '',
    );
    final emailController = TextEditingController(text: profile['email'] ?? '');

    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Profile', style: AppTheme.headlineMedium),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Shop name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: 'Contact'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final newProfile = {
                    'shopName': nameController.text.trim(),
                    'contact': contactController.text.trim(),
                    'email': emailController.text.trim(),
                  };
                  await Storage.setJson('profile', newProfile);
                  // TODO: send profile updates to backend
                  Navigator.of(context).pop(true);
                },
                child: const Text('Save'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (res == true) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Storage.clearAll();
              // TODO: call backend logout / revoke tokens
              Navigator.of(context).pop(true);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (ok == true) {
      // navigate to welcome/intro screen
      Navigator.of(context).pushReplacementNamed('/welcome');
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'This will permanently delete your account. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final otp = await showDialog<String>(
      context: context,
      builder: (_) {
        final codeController = TextEditingController();
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter OTP sent to your phone to confirm.'),
              const SizedBox(height: 8),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(codeController.text),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (otp == '1234') {
      // SECURITY: real account deletion must be done server-side with proper auth
      await Storage.clearAll();
      // TODO: call backend delete account API
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account deleted')));
      Navigator.of(context).pushReplacementNamed('/welcome');
    } else if (otp != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        backgroundColor: AppTheme.pageBackground,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppTheme.pageBackground,
        ),
      ),
      backgroundColor: AppTheme.pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.tealLight,
                    child: Text(
                      (profile['shopName'] ?? 'A').toString().substring(0, 1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile['shopName'] ?? '',
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile['contact'] ?? '',
                          style: AppTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _editProfile,
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Business & Payments
            Text('Business & Payments', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  SettingRow(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Bank & Payouts',
                    subtitle: 'Manage linked bank accounts',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BankDetailsScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.schedule,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Payout Settings',
                    subtitle: 'Auto/manual schedule',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PayoutSettingsScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.qr_code,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'QR Management',
                    subtitle: 'Manage your QR code',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QRManagementScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.devices,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Soundbox / Device',
                    subtitle: 'Request or manage devices',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Feature requested: Contact support'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // KYC & Documents
            Text('KYC & Documents', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  SettingRow(
                    leading: const Icon(
                      Icons.document_scanner,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'KYC Status',
                    subtitle: 'Upload documents and verify',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const KYCDocumentsScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.description,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Agreements',
                    subtitle: 'View agreement PDFs',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Opening agreements (mock)'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications & Preferences
            Text('Notifications & Preferences', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  SettingRow(
                    leading: const Icon(
                      Icons.notifications,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Notification Settings',
                    subtitle: 'Manage push notifications',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.translate,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Language',
                    subtitle: 'English',
                    onTap: () async {
                      final lang = await showModalBottomSheet<String>(
                        context: context,
                        builder: (_) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('English'),
                              onTap: () => Navigator.of(context).pop('en'),
                            ),
                            ListTile(
                              title: const Text('हिंदी'),
                              onTap: () => Navigator.of(context).pop('hi'),
                            ),
                          ],
                        ),
                      );
                      if (lang != null) {
                        await Storage.setString('app_language', lang);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Language updated')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Security
            Text('Security', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  SettingRow(
                    leading: const Icon(
                      Icons.lock,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Security Settings',
                    subtitle: 'Change password, PIN, biometrics',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SecuritySettingsScreen(),
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.phonelink_lock,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Active Sessions',
                    subtitle: 'Manage sessions on other devices',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Active Sessions'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Chrome - Laptop'),
                              subtitle: const Text('Last active 3 days ago'),
                            ),
                            ListTile(
                              title: const Text('Android - Pixel 4'),
                              subtitle: const Text('Last active 2 hours ago'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                          TextButton(
                            onPressed: () {
                              /* sign out other devices mock */
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Signed out other devices'),
                                ),
                              );
                            },
                            child: const Text('Sign out'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Help & Legal
            Text('Help & Legal', style: AppTheme.headlineSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  SettingRow(
                    leading: const Icon(
                      Icons.support_agent,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Support',
                    subtitle: 'Call, chat or raise ticket',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.rule,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Terms & Privacy',
                    subtitle: 'View terms and privacy policy',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Terms & Privacy'),
                        content: const SingleChildScrollView(
                          child: Text('Terms and privacy text (mock)'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  SettingRow(
                    leading: const Icon(
                      Icons.star_rate,
                      color: AppTheme.primaryTeal,
                    ),
                    title: 'Rate & Feedback',
                    subtitle: 'Share your feedback',
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Feedback'),
                        content: TextField(
                          maxLines: 4,
                          decoration: const InputDecoration(
                            hintText: 'Write your feedback',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Send'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Danger
            Container(
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _logout,
                  ),
                  Divider(height: 1, color: Colors.grey[300]),
                  ListTile(
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: _deleteAccount,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
