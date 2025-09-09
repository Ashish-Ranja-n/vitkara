import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, bool> settings = {
    'new_investment': true,
    'payment_received': true,
    'payouts': true,
    'system': false,
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await Storage.getJson(
      'notification_settings',
      (o) => o as Map<String, dynamic>? ?? {},
    );
    setState(() {
      if (s != null) settings = s.map((k, v) => MapEntry(k, v == true));
    });
  }

  Future<void> _save() async {
    await Storage.setJson('notification_settings', settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('New Investment'),
              value: settings['new_investment'] ?? true,
              onChanged: (v) => setState(() => settings['new_investment'] = v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Payment Received'),
              value: settings['payment_received'] ?? true,
              onChanged: (v) =>
                  setState(() => settings['payment_received'] = v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Payouts'),
              value: settings['payouts'] ?? true,
              onChanged: (v) => setState(() => settings['payouts'] = v),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('System messages'),
              value: settings['system'] ?? false,
              onChanged: (v) => setState(() => settings['system'] = v),
            ),
            const Spacer(),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
