import 'package:flutter/material.dart';
import '../design_tokens.dart';

class MarketSummaryCard extends StatelessWidget {
  final int activeListings;
  final String? todayVolume; // INR formatted string or null
  final String totalFundRaised; // already formatted (INR)
  const MarketSummaryCard({
    super.key,
    required this.activeListings,
    this.todayVolume,
    required this.totalFundRaised,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Active listings
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(Icons.store, color: AppColors.accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeListings.toString(),
                            style: AppTypography.kpiNumber.copyWith(
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text('Active', style: AppTypography.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Total raised (accent orange) - allow larger but avoid overflow with FittedBox
            Flexible(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings, color: AppColors.accentOrange, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // use FittedBox so very large numbers scale down instead of overflowing
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            totalFundRaised.isNotEmpty
                                ? totalFundRaised
                                : 'N/A',
                            style: AppTypography.kpiNumber.copyWith(
                              fontSize: 20,
                              color: AppColors.accentOrange,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text('Total Raised', style: AppTypography.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Today volume
            Flexible(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.show_chart, color: AppColors.mutedText, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          todayVolume ?? 'N/A',
                          style: AppTypography.kpiNumber.copyWith(
                            fontSize: 16,
                            color: todayVolume == null
                                ? AppColors.mutedText
                                : AppColors.kpiHighlight,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Today', style: AppTypography.caption),
                            if (todayVolume == null) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.info_outline,
                                size: 14,
                                color: AppColors.accentOrange,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
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
