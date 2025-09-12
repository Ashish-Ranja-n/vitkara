import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'shop_card.dart';
import '../design_tokens.dart';

class ShopDetailPage extends StatelessWidget {
  final Shop shop;
  const ShopDetailPage({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final percent = (shop.raised / shop.target).clamp(0, 1).toDouble();
    final percentLabel = '${(percent * 100).round()}%';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(shop.name, style: AppTypography.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(shop.logoAsset),
                  backgroundColor: AppColors.surface,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${shop.category} · ${shop.city}',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildStatRow('Avg UPI/day', currency.format(shop.avgUpi)),
            _buildStatRow('Ticket', currency.format(shop.ticket)),
            _buildStatRow('Est Return', '${shop.estReturn}x'),
            _buildStatRow('Raised', currency.format(shop.raised)),
            _buildStatRow('Target', currency.format(shop.target)),
            const SizedBox(height: 22),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.small),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.accentGreen,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Progress', style: AppTypography.body),
                Text(
                  percentLabel,
                  style: AppTypography.badge.copyWith(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text('More details coming soon...', style: AppTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            value,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
