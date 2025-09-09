import 'package:flutter/material.dart';
import '../../theme.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  void _openTicket(BuildContext context) async {
    final ctl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Create ticket'),
        content: TextField(
          controller: ctl,
          decoration: const InputDecoration(hintText: 'Describe your issue'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (ok == true) {
      // TODO: send ticket to backend
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ticket created (mock)')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      backgroundColor: AppTheme.pageBackground,
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.horizontalPadding),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                boxShadow: [AppTheme.defaultShadow],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.call,
                      color: AppTheme.primaryTeal,
                    ),
                    title: const Text('Call Support'),
                    subtitle: const Text('+91 12345 67890'),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Calling support (mock)')),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.chat,
                      color: AppTheme.primaryTeal,
                    ),
                    title: const Text('Chat with us'),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening chat (mock)')),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.support_agent,
                      color: AppTheme.primaryTeal,
                    ),
                    title: const Text('Create ticket'),
                    onTap: () => _openTicket(context),
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
