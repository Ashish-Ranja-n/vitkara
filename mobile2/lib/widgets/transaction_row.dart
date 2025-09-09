import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

enum TransactionType {
  sale,
  refund,
  payout;

  Color get color {
    switch (this) {
      case TransactionType.sale:
        return Colors.green;
      case TransactionType.refund:
        return Colors.red;
      case TransactionType.payout:
        return AppTheme.primaryTeal;
    }
  }

  IconData get icon {
    switch (this) {
      case TransactionType.sale:
        return Icons.arrow_upward;
      case TransactionType.refund:
        return Icons.arrow_downward;
      case TransactionType.payout:
        return Icons.account_balance_wallet;
    }
  }
}

class TransactionRow extends StatelessWidget {
  final DateTime date;
  final TransactionType type;
  final double amount;
  final String? status;
  final NumberFormat? currencyFormat;

  const TransactionRow({
    super.key,
    required this.date,
    required this.type,
    required this.amount,
    this.status,
    this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: type.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(type.icon, color: type.color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type.name[0].toUpperCase() + type.name.substring(1),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat?.format(amount) ??
                    '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: type.color,
                ),
              ),
              if (status != null) ...[
                const SizedBox(height: 2),
                Text(
                  status!,
                  style: AppTheme.bodyMedium.copyWith(fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
