import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool biometric = false;
  bool pinSet = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await Storage.getJson(
      'security',
      (o) => o as Map<String, dynamic>? ?? {},
    );
    setState(() {
      biometric = b?['biometric'] ?? false;
      pinSet = b?['pinSet'] ?? false;
    });
  }

  Future<void> _save() async {
    await Storage.setJson('security', {
      'biometric': biometric,
      'pinSet': pinSet,
    });
  }

  Future<void> _changePassword() async {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    final confirmC = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Change password'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldC,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Old password'),
                  validator: (v) => (v?.isEmpty ?? true) ? 'Required' : null,
                ),
                TextFormField(
                  controller: newC,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) =>
                      (v?.length ?? 0) < 6 ? 'Minimum 6 chars' : null,
                ),
                TextFormField(
                  controller: confirmC,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm'),
                  validator: (v) => v != newC.text ? 'Does not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      // TODO: securely change password via backend; DO NOT store plain password locally
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password changed (mock)')));
    }
  }

  Future<void> _setPin() async {
    final pinC = TextEditingController();
    final confirmC = TextEditingController();
    final key = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Set 4-digit PIN'),
          content: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: pinC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'PIN'),
                  validator: (v) =>
                      (v?.length ?? 0) != 4 ? 'Enter 4 digits' : null,
                ),
                TextFormField(
                  controller: confirmC,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Confirm PIN'),
                  validator: (v) => v != pinC.text ? 'Does not match' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (key.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (ok == true) {
      pinSet = true;
      await _save();
      // SECURITY: store PIN in secure storage in production
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('PIN set (mock)')));
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Settings')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            ListTile(
              title: const Text('Change password'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _changePassword,
            ),
            const Divider(),
            ListTile(
              title: const Text('Set / Change 4-digit PIN'),
              subtitle: Text(pinSet ? 'PIN set' : 'No PIN'),
              onTap: _setPin,
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Use biometrics'),
              subtitle: const Text('Unlock using fingerprint/face (mock)'),
              value: biometric,
              onChanged: (v) async {
                biometric = v;
                await _save();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
