import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../utils/formatters.dart';

class OverviewDetailScreen extends StatelessWidget {
  final String userName;
  final int totalInvestmentPaise;
  final int? investedPrincipalPaise;
  final int? availableBalancePaise;
  final int? accruedReturnsPaise;
  final int todayPayoutEstPaise;
  final int yesterdayPayoutPaise;
  final DateTime? nextPayoutDate;

  const OverviewDetailScreen({
    super.key,
    required this.userName,
    required this.totalInvestmentPaise,
    this.investedPrincipalPaise,
    this.availableBalancePaise,
    this.accruedReturnsPaise,
    required this.todayPayoutEstPaise,
    required this.yesterdayPayoutPaise,
    this.nextPayoutDate,
  });

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
              _sectionHeading('Per-shop investments (mock)'),
              // Mock list — TODO: replace with real per-shop investments from backend
              _metricTile('FreshMart', '₹40,000.00'),
              const SizedBox(height: 8),
              _metricTile('Urban Tailor', '₹3,000.00'),
              const SizedBox(height: 8),
              _metricTile('Chai Point', '₹0.00'),

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
