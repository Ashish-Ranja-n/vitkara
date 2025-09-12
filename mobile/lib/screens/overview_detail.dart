import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../utils/formatters.dart';
import '../services/investor_service.dart';

class OverviewDetailScreen extends StatefulWidget {
  const OverviewDetailScreen({super.key});

  @override
  State<OverviewDetailScreen> createState() => _OverviewDetailScreenState();
}

class _OverviewDetailScreenState extends State<OverviewDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _profile;
  List<dynamic> _investments = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final investorService = InvestorService();
      final profile = await investorService.getProfile();
      final investmentsResult = await investorService.getInvestments();

      setState(() {
        _profile = profile;
        _investments = investmentsResult?['investments'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  String get userName => _profile?['name'] ?? 'User';
  int get totalInvestmentPaise =>
      ((_profile?['totalInvestment'] ?? 0) * 100).toInt();
  int? get investedPrincipalPaise =>
      totalInvestmentPaise > 0 ? totalInvestmentPaise : null;
  int? get availableBalancePaise =>
      ((_profile?['walletBalance'] ?? 0) * 100).toInt();
  int? get accruedReturnsPaise => null; // TODO: calculate from investments
  int get todayPayoutEstPaise => 0; // TODO: calculate
  int get yesterdayPayoutPaise => 0; // TODO: calculate
  DateTime? get nextPayoutDate => null; // TODO: calculate

  Widget _sectionHeading(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12.0),
    child: Text(title, style: AppTypography.sectionHeading),
  );

  Widget _metricTile(String title, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(color: AppColors.mutedText),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.cardTitle.copyWith(
              color: valueColor ?? AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat.yMMMd();
    // TODO: wire these values to backend. Demo fallback used from parent props.
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        title: Text('Overview', style: AppTypography.title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.edge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeading('Summary'),
              Hero(
                tag: 'total_investment',
                child: _metricTile(
                  'Total Investment',
                  formatINRFromPaise(totalInvestmentPaise),
                  valueColor: AppColors.kpiHighlight,
                ),
              ),
              const SizedBox(height: 12),

              _sectionHeading('Balances'),
              Row(
                children: [
                  Expanded(
                    child: _metricTile(
                      'Invested (principal)',
                      investedPrincipalPaise != null
                          ? formatINRFromPaise(investedPrincipalPaise!)
                          : '—',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricTile(
                      'Available',
                      availableBalancePaise != null
                          ? formatINRFromPaise(availableBalancePaise!)
                          : '—',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _sectionHeading('Returns & Payouts'),
              Row(
                children: [
                  Expanded(
                    child: _metricTile(
                      'Accrued returns',
                      accruedReturnsPaise != null
                          ? formatINRFromPaise(accruedReturnsPaise!)
                          : '—',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _metricTile(
                      'Today (est)',
                      formatINRFromPaise(todayPayoutEstPaise),
                      valueColor: AppColors.kpiHighlight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _metricTile(
                'Yesterday (est)',
                formatINRFromPaise(yesterdayPayoutPaise),
              ),
              const SizedBox(height: 12),
              _sectionHeading('Next payout'),
              _metricTile(
                'Next payout date',
                nextPayoutDate != null ? dateFmt.format(nextPayoutDate!) : '—',
              ),

              const SizedBox(height: 16),
              _sectionHeading('Per-shop investments'),
              if (_investments.isEmpty)
                _metricTile('No investments yet', '—')
              else
                ..._investments.map((inv) {
                  final shopName =
                      inv['campaignId']['shopId']['name'] ?? 'Unknown';
                  final amount = (inv['amount'] ?? 0).toDouble();
                  return Column(
                    children: [
                      _metricTile(
                        shopName,
                        formatINRFromPaise((amount * 100).toInt()),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                }).toList(),

              const SizedBox(height: 16),
              _sectionHeading('Payout history (mock)'),
              _metricTile('2025-09-01', '₹120.00'),
              const SizedBox(height: 8),
              _metricTile('2025-08-31', '₹100.00'),

              const SizedBox(height: 16),
              _sectionHeading('Notes'),
              Text(
                'Amounts stored in paise (integer). Values shown are indicative. // TODO: Replace demo data with backend values and wire refresh flows.',
                style: AppTypography.body.copyWith(color: AppColors.mutedText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
