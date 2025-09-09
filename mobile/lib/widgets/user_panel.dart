import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design_tokens.dart';

/// Compact user panel used on the Investment Market screen.
/// All monetary values passed in paise (int). Displays portfolio value,
/// four small metric tiles, single-line footer and CTAs.
class UserPanel extends StatelessWidget {
  final Map<String, dynamic> user;
  final int totalBalancePaise;
  final int investedPrincipalPaise;
  final int availableBalancePaise;
  final int accruedReturnsPaise;
  final int todayPayoutEstPaise;
  final DateTime? nextPayoutDate;
  final bool balanceInconsistent;
  final VoidCallback onInvestMore;
  final VoidCallback onViewPortfolio;
  final VoidCallback onWithdraw;

  const UserPanel({
    super.key,
    required this.user,
    required this.totalBalancePaise,
    required this.investedPrincipalPaise,
    required this.availableBalancePaise,
    required this.accruedReturnsPaise,
    required this.todayPayoutEstPaise,
    this.nextPayoutDate,
    required this.balanceInconsistent,
    required this.onInvestMore,
    required this.onViewPortfolio,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final name = (user['name'] as String?)?.isNotEmpty == true
        ? user['name'] as String
        : 'Investor';
    final verified = user['verified'] as bool? ?? false;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    String fmt(int p) => currency.format(p / 100.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: greeting + portfolio value
          Row(
            children: [
              // left: name + verified + info
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Hi $name',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (verified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGreen,
                                    borderRadius: BorderRadius.circular(
                                      AppRadii.small,
                                    ),
                                  ),
                                  child: const Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Amounts in INR'),
                                    content: const Text(
                                      'All amounts are INR; values come from backend paise. Withdraw transfers occur in INR.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // right: portfolio value in green
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    fmt(totalBalancePaise),
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accentGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Portfolio',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2x2 compact metrics
          Row(
            children: [
              Expanded(child: _miniMetric('Total', fmt(totalBalancePaise))),
              const SizedBox(width: 12),
              Expanded(
                child: _miniMetric('Invested', fmt(investedPrincipalPaise)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _miniMetric('Available', fmt(availableBalancePaise)),
              ),
              const SizedBox(width: 12),
              Expanded(child: _miniMetric('Accrued', fmt(accruedReturnsPaise))),
            ],
          ),

          const SizedBox(height: 8),

          // tiny footer
          Text(
            'Today (est): ${fmt(todayPayoutEstPaise)} • Next: ${nextPayoutDate != null ? DateFormat.yMMMd().format(nextPayoutDate!) : '—'}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText),
          ),

          const SizedBox(height: 6),
          // Note: top action CTAs removed per design — actions are available on each shop card.
        ],
      ),
    );
  }

  Widget _miniMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.mutedText),
        ),
      ],
    );
  }
}
