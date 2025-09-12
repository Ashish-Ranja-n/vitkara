import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../design_tokens.dart';
import '../utils/formatters.dart';
import '../screens/overview_detail.dart';
import '../providers/auth_provider.dart';

class OverviewBoard extends StatefulWidget {
  const OverviewBoard({super.key});

  @override
  State<OverviewBoard> createState() => _OverviewBoardState();
}

class _OverviewBoardState extends State<OverviewBoard> {
  // Values that are not available from API - keep as N/A or defaults
  final double _estimatedIndex = 1.25; // Default value
  final int _todayRsaPaise = 0; // N/A
  final int _yesterdayRsaPaise = 0; // N/A
  final DateTime? _nextPayoutDate = null; // N/A
  final int? _accruedReturnsPaise = null; // N/A
  final bool _showWarning = false;

  Future<void> _onRefresh() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.refreshInvestorData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.state.user;
        final userName = user?['name'] ?? 'User';
        final verified = user?['verified'] ?? false;
        final totalInvestment = user?['totalInvestment']?.toDouble() ?? 0.0;
        final walletBalance = user?['walletBalance']?.toDouble() ?? 0.0;

        final totalInvestmentPaise = (totalInvestment * 100).round();
        final walletBalancePaise = (walletBalance * 100).round();

        final small = MediaQuery.of(context).size.width < 380;
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.kpiHighlight,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.edge,
                vertical: 8,
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OverviewDetailScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadii.card),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
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
                                  formatIndex(_estimatedIndex),
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
                                    value: formatINRFromPaise(
                                      totalInvestmentPaise,
                                    ),
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
                                  formatINRFromPaise(_todayRsaPaise),
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
                                  formatINRFromPaise(_yesterdayRsaPaise),
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
                                'Next payout: —',
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

                      if (_showWarning)
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
            ),
          ),
        );
      },
    );
  }
}
