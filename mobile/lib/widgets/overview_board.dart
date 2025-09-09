import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';
import '../utils/formatters.dart';
import '../screens/overview_detail.dart';

class OverviewBoard extends StatelessWidget {
  final String userName;
  final bool verified;
  final int totalInvestmentPaise;
  final double estimatedIndex;
  final int walletBalancePaise;
  final int todayRsaPaise;
  final int yesterdayRsaPaise;
  final DateTime? nextPayoutDate;
  final int? accruedReturnsPaise;
  final bool showWarning;

  const OverviewBoard({
    super.key,
    required this.userName,
    required this.verified,
    required this.totalInvestmentPaise,
    required this.estimatedIndex,
    required this.walletBalancePaise,
    required this.todayRsaPaise,
    required this.yesterdayRsaPaise,
    required this.nextPayoutDate,
    this.accruedReturnsPaise,
    this.showWarning = false,
  });

  // Demo fallback (TODO: replace with backend values)
  // final demoOverview example:
  // final demoOverview = {
  //   'user_name': 'Ashish',
  //   'total_investment_paise': 4000000,      // ₹40,000.00
  //   'estimated_index': 1.25,               // display as ~1.25x
  //   'wallet_balance_paise': 800000,        // ₹8,000.00
  //   'today_rsa_paise': 12000,              // ₹120.00
  //   'yesterday_rsa_paise': 10000,          // ₹100.00
  //   'next_payout_date': '2025-09-02'
  // };

  @override
  Widget build(BuildContext context) {
    final small = MediaQuery.of(context).size.width < 380;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.edge,
        vertical: 8,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OverviewDetailScreen(
                userName: userName,
                totalInvestmentPaise: totalInvestmentPaise,
                investedPrincipalPaise: null,
                availableBalancePaise: walletBalancePaise,
                accruedReturnsPaise: accruedReturnsPaise,
                todayPayoutEstPaise: todayRsaPaise,
                yesterdayPayoutPaise: yesterdayRsaPaise,
                nextPayoutDate: nextPayoutDate,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppRadii.card),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row A - header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Hi $userName',
                          style: GoogleFonts.inter(
                            fontSize: small ? 18 : 20,
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
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: AppColors.kpiHighlight,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Verified',
                                  style: AppTypography.badge.copyWith(
                                    color: AppColors.kpiHighlight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // show a short tooltip via a simple dialog for accessibility
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          content: const Text(
                            'Estimated index — indicative only.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          formatIndex(estimatedIndex),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.accentOrange,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppColors.accentOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Row B - primary metrics
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // total investment (hero target)
                        Hero(
                          tag: 'total_investment',
                          child: Semantics(
                            label: 'Total investment',
                            value: formatINRFromPaise(totalInvestmentPaise),
                            child: Text(
                              formatINRFromPaise(totalInvestmentPaise),
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.kpiHighlight,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Total Investment',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Right compact wallet
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: AppColors.primaryText,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            formatINRFromPaise(walletBalancePaise),
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Wallet',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Row C - small metrics and footer
              Row(
                children: [
                  Expanded(
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: [
                        Text(
                          'Today (est):',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                        Text(
                          formatINRFromPaise(todayRsaPaise),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.kpiHighlight,
                          ),
                        ),
                        Text(
                          '•',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                        Text(
                          'Yesterday:',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                        Text(
                          formatINRFromPaise(yesterdayRsaPaise),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        nextPayoutDate != null
                            ? 'Next payout: ${DateFormat.yMMMd().format(nextPayoutDate!)}'
                            : 'Next payout: —',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.mutedText,
                      ),
                    ],
                  ),
                ],
              ),

              if (showWarning)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Tooltip(
                    message: 'Data inconsistent — please refresh',
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '!',
                            style: AppTypography.badge.copyWith(
                              color: AppColors.cardElevated,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Data inconsistent — please refresh',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
