import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class BankDetailsScreen extends StatefulWidget {
  const BankDetailsScreen({super.key});

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  List<Map<String, dynamic>> banks = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final b = await Storage.getJson(
      'bank_accounts',
      (o) => o as List<dynamic>? ?? [],
    );
    setState(() => banks = (b ?? []).cast<Map<String, dynamic>>());
  }

  Future<void> _addBank() async {
    final holder = TextEditingController();
    final account = TextEditingController();
    final ifsc = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Bank Account', style: AppTheme.headlineMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: holder,
                  decoration: const InputDecoration(
                    labelText: 'Account holder name',
                  ),
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: account,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Account number',
                  ),
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: ifsc,
                  decoration: const InputDecoration(labelText: 'IFSC'),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return 'Required';
                    if (s.length != 11) return 'IFSC must be 11 chars';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final newBank = {
                        'holder': holder.text.trim(),
                        'account': account.text.trim(),
                        'ifsc': ifsc.text.trim(),
                        'verified': false,
                      };
                      banks.add(newBank);
                      await Storage.setJson('bank_accounts', banks);
                      // TODO: send bank details to secure backend for verification
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok == true) {
      _load();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bank added (mock)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bank & Payouts')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            Expanded(
              child: banks.isEmpty
                  ? Center(
                      child: Text('No bank linked', style: AppTheme.bodyMedium),
                    )
                  : ListView.separated(
                      itemCount: banks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final b = banks[i];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [AppTheme.defaultShadow],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance,
                                color: AppTheme.primaryTeal,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b['holder'] ?? '',
                                      style: AppTheme.headlineSmall,
                                    ),
                                    Text(
                                      '****${(b['account'] ?? '').toString().padLeft(4).substring(((b['account'] ?? '').toString().length - 4).clamp(0, 4))}',
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Chip(
                                label: Text(
                                  (b['verified'] == true)
                                      ? 'Verified'
                                      : 'Unverified',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton.icon(
              onPressed: _addBank,
              icon: const Icon(Icons.add),
              label: const Text('Add bank'),
            ),
          ],
        ),
      ),
    );
  }
}
