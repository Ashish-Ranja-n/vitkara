import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class QRManagementScreen extends StatefulWidget {
  const QRManagementScreen({super.key});

  @override
  State<QRManagementScreen> createState() => _QRManagementScreenState();
}

class _QRManagementScreenState extends State<QRManagementScreen> {
  String issuedDate = '2024-01-01';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await Storage.getString('qr_issued');
    setState(() => issuedDate = d ?? issuedDate);
  }

  Future<void> _requestReplacement() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Request replacement'),
        content: const Text('Request a QR replacement?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Request'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // mock replacement
      await Storage.setString('qr_issued', DateTime.now().toIso8601String());
      // TODO: call backend to initiate replacement
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Replacement requested (mock)')),
      );
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Management')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  // placeholder QR
                  Image.asset(
                    'assets/images/qr_placeholder.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text('Issued: $issuedDate', style: AppTheme.bodyMedium),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _requestReplacement,
                    child: const Text('Request Replacement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
