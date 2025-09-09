import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class PayoutSettingsScreen extends StatefulWidget {
  const PayoutSettingsScreen({super.key});

  @override
  State<PayoutSettingsScreen> createState() => _PayoutSettingsScreenState();
}

class _PayoutSettingsScreenState extends State<PayoutSettingsScreen> {
  bool autoPayout = false;
  String frequency = 'Weekly';
  String minThreshold = '500';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await Storage.getJson(
      'payout_settings',
      (o) => o as Map<String, dynamic>? ?? {},
    );
    setState(() {
      autoPayout = p?['auto'] ?? false;
      frequency = p?['frequency'] ?? 'Weekly';
      minThreshold = p?['min']?.toString() ?? '500';
    });
  }

  Future<void> _save() async {
    await Storage.setJson('payout_settings', {
      'auto': autoPayout,
      'frequency': frequency,
      'min': int.tryParse(minThreshold) ?? 0,
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Payout settings saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payout Settings')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Auto Payout'),
              subtitle: const Text(
                'Automatically transfer funds based on schedule',
              ),
              value: autoPayout,
              onChanged: (v) => setState(() => autoPayout = v),
              secondary: const Icon(
                Icons.autorenew,
                color: AppTheme.primaryTeal,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Daily'),
                    selected: frequency == 'Daily',
                    onSelected: (_) => setState(() => frequency = 'Daily'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Weekly'),
                    selected: frequency == 'Weekly',
                    onSelected: (_) => setState(() => frequency = 'Weekly'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('Monthly'),
                    selected: frequency == 'Monthly',
                    onSelected: (_) => setState(() => frequency = 'Monthly'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Minimum payout threshold (₹)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) => minThreshold = v,
              controller: TextEditingController(text: minThreshold),
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
