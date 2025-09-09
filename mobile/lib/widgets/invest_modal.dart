import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvestModal extends StatefulWidget {
  final double ticketPrice;
  final void Function(int quantity) onConfirm;
  const InvestModal({
    super.key,
    required this.ticketPrice,
    required this.onConfirm,
  });

  @override
  State<InvestModal> createState() => _InvestModalState();
}

class _InvestModalState extends State<InvestModal> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final total = widget.ticketPrice * _quantity;
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF12171C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Invest in Shop',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE6EEF3),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ticket Price',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB7C2C8)),
                ),
                Text(
                  currency.format(widget.ticketPrice),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF66FFA6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quantity',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB7C2C8)),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Color(0xFF9AA5AD),
                      ),
                      onPressed: _quantity > 1
                          ? () => setState(() => _quantity--)
                          : null,
                    ),
                    Text(
                      '$_quantity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE6EEF3),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF9AA5AD),
                      ),
                      onPressed: () => setState(() => _quantity++),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 16, color: Color(0xFFB7C2C8)),
                ),
                Text(
                  currency.format(total),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF66FFA6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0F9D58),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                widget.onConfirm(_quantity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Investment successful!'),
                    backgroundColor: Color(0xFF12171C),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
