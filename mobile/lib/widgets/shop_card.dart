import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_tokens.dart';

class Shop {
  final String name;
  final String category;
  final String city;
  final String logoAsset;
  final double avgUpi;
  final double ticket;
  final double estReturn;
  final double raised;
  final double target;
  final bool trending;

  Shop({
    required this.name,
    required this.category,
    required this.city,
    required this.logoAsset,
    required this.avgUpi,
    required this.ticket,
    required this.estReturn,
    required this.raised,
    required this.target,
    this.trending = false,
  });
}

class ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onInvest;
  final VoidCallback onDetails;
  final Color accentColor;
  final bool embedded;
  const ShopCard({
    super.key,
    required this.shop,
    required this.onInvest,
    required this.onDetails,
    this.accentColor = AppColors.accentGreen,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (shop.raised / shop.target).clamp(0, 1).toDouble();
    final percentLabel = '${(percent * 100).round()}%';
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    final inner = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.name,
                            style: AppTypography.cardTitle,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (shop.trending) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.trending_up, color: accentColor, size: 16),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${shop.category} • ${shop.city}',
                      style: AppTypography.caption,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _statChip('Avg UPI', currency.format(shop.avgUpi)),
                        _statChip('Ticket', currency.format(shop.ticket)),
                        _statChip('Est', '${shop.estReturn}x'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Progress row: a flexible progress bar and a fixed percent badge to the right.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Bar (thinner)
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadii.small),
                            child: Container(
                              height: 8,
                              color: AppColors.surface.withAlpha(
                                (0.12 * 255).round(),
                              ),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: percent,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Percent badge (fixed width) outside the bar to avoid overlap
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardElevated,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            percentLabel,
                            style: AppTypography.badge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right,
                color: AppColors.secondaryText,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );

    if (embedded) {
      return Padding(
        // match the horizontal inset used by non-embedded cards so embedded
        // and featured cards align perfectly.
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onDetails,
          child: inner,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Material(
        color: AppColors.cardElevated,
        borderRadius: BorderRadius.circular(AppRadii.card),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.card),
          onTap: onDetails,
          child: inner,
        ),
      ),
    );
  }

  Widget _statChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha((0.85 * 255).round()),
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
