import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../utils/storage.dart';

class KYCDocumentsScreen extends StatefulWidget {
  const KYCDocumentsScreen({super.key});

  @override
  State<KYCDocumentsScreen> createState() => _KYCDocumentsScreenState();
}

class _KYCDocumentsScreenState extends State<KYCDocumentsScreen> {
  List<String> uploaded = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final u = await Storage.getJson(
      'kyc_docs',
      (o) => o as List<dynamic>? ?? [],
    );
    setState(() => uploaded = (u ?? []).cast<String>());
  }

  Future<void> _mockUpload() async {
    // mock: pick from local assets or simulate
    final placeholder = 'assets/images/id_sample.png';
    uploaded.add(placeholder);
    await Storage.setJson('kyc_docs', uploaded);
    // TODO: integrate real file picker and upload API with secure storage
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Document uploaded (mock)')));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('KYC Documents')),
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Uploaded documents',
                      style: AppTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (uploaded.isEmpty)
                    Center(
                      child: Text(
                        'No documents uploaded',
                        style: AppTheme.bodyMedium,
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: uploaded
                          .map(
                            (p) => GestureDetector(
                              onTap: () => showDialog(
                                context: context,
                                builder: (_) =>
                                    AlertDialog(content: Image.asset(p)),
                              ),
                              child: Image.asset(
                                p,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _mockUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload documents'),
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
