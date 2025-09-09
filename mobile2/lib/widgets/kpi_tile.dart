import 'package:flutter/material.dart';
import '../theme.dart';

/// A tile that displays a KPI metric. Lightweight, accessible, and tappable.
class KpiTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  const KpiTile({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: [AppTheme.defaultShadow],
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? AppTheme.primaryTeal).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon!,
                color: iconColor ?? AppTheme.primaryTeal,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Metric texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.mutedText,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: AppTheme.bodyLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    // If tappable, wrap with InkWell to provide feedback and semantics
    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
          child: Semantics(button: true, label: '$title, $value', child: tile),
        ),
      );
    }

    return Semantics(container: true, child: tile);
  }
}
