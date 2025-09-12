import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'shop_card.dart';
import '../design_tokens.dart';
import '../services/investor_service.dart';

class ShopDetailPage extends StatefulWidget {
  final Shop shop;
  const ShopDetailPage({super.key, required this.shop});

  @override
  State<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends State<ShopDetailPage> {
  late Shop currentShop;

  @override
  void initState() {
    super.initState();
    currentShop = widget.shop;
  }

  void _showInvestDialog() {
    int ticketCount = 1;
    final maxTickets = (currentShop.maxInvestment / currentShop.ticket).floor();
    bool isInvesting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void makeInvestment() async {
            if (ticketCount < 1) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select at least 1 ticket'),
                ),
              );
              return;
            }

            if (ticketCount > maxTickets) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Maximum ${maxTickets} tickets allowed'),
                ),
              );
              return;
            }

            setState(() => isInvesting = true);

            try {
              final investorService = InvestorService();
              final result = await investorService.makeInvestment(
                campaignId: widget.shop.id,
                tickets: ticketCount,
              );

              if (result != null && result['success'] == true) {
                if (result['campaign'] != null) {
                  final newRaised =
                      result['campaign']['currentAmount'] ?? currentShop.raised;
                  setState(
                    () => currentShop = Shop(
                      id: currentShop.id,
                      name: currentShop.name,
                      category: currentShop.category,
                      city: currentShop.city,
                      logoAsset: currentShop.logoAsset,
                      avgUpi: currentShop.avgUpi,
                      ticket: currentShop.ticket,
                      estReturn: currentShop.estReturn,
                      raised: newRaised,
                      target: currentShop.target,
                      trending: currentShop.trending,
                      minInvestment: currentShop.minInvestment,
                      maxInvestment: currentShop.maxInvestment,
                    ),
                  );
                }
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Investment successful!')),
                );
              } else {
                final message = result?['message'] ?? 'Investment failed';
                Navigator.of(context).pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
            } catch (e) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Network error occurred')),
              );
            } finally {
              setState(() => isInvesting = false);
            }
          }

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
                    'Invest in ${currentShop.name}',
                    style: const TextStyle(
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
                      const Text(
                        'Ticket Price',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB7C2C8),
                        ),
                      ),
                      Text(
                        '₹${currentShop.ticket}',
                        style: const TextStyle(
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
                      const Text(
                        'Number of Tickets',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB7C2C8),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFF9AA5AD),
                            ),
                            onPressed: ticketCount > 1
                                ? () => setState(() => ticketCount--)
                                : null,
                          ),
                          Text(
                            '$ticketCount',
                            style: const TextStyle(
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
                            onPressed: ticketCount < maxTickets
                                ? () => setState(() => ticketCount++)
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Maximum: $maxTickets tickets',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9AA5AD),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Investment',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB7C2C8),
                        ),
                      ),
                      Text(
                        '₹${(ticketCount * currentShop.ticket).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF66FFA6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expected Return',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFB7C2C8),
                        ),
                      ),
                      Text(
                        '₹${(ticketCount * currentShop.ticket * (currentShop.estReturn - 1)).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF66FFA6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F9D58),
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isInvesting ? null : makeInvestment,
                    child: isInvesting
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Investing...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Invest $ticketCount Ticket${ticketCount > 1 ? 's' : ''}',
                            style: const TextStyle(
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final percent = (currentShop.raised / currentShop.target)
        .clamp(0, 1)
        .toDouble();
    final percentLabel = '${(percent * 100).round()}%';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(currentShop.name, style: AppTypography.title),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentShop.name,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${currentShop.category} · ${currentShop.city}',
                  style: AppTypography.caption,
                ),
              ],
            ),
            const SizedBox(height: 22),
            _buildStatRow(
              'Avg UPI/day',
              NumberFormat('#,##0.##', 'en_IN').format(currentShop.avgUpi),
            ),
            _buildStatRow('Ticket Price', currency.format(currentShop.ticket)),
            _buildStatRow(
              'Max Tickets',
              '${(currentShop.maxInvestment / currentShop.ticket).floor()}',
            ),
            _buildStatRow('Est Return', '${currentShop.estReturn}x'),
            _buildStatRow('Raised', currency.format(currentShop.raised)),
            _buildStatRow('Target', currency.format(currentShop.target)),
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
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showInvestDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.card),
                  ),
                ),
                child: const Text(
                  'Invest Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
