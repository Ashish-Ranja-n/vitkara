import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../theme.dart';
import 'settings.dart';
import '../widgets/campaign_card.dart';
import '../widgets/kpi_tile.dart';
import '../widgets/transaction_row.dart';

/// Dashboard screen showing KPIs, campaign progress, transactions and quick actions.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Currency formatter for Indian Rupees
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  // Layout constants
  static const double _cardPadding = 16.0;
  static const double _itemSpacing = 16.0;
  static const double _headerHeight = 160.0;
  // no negative offset so header won't overlap content when scrolling
  static const double _contentOffset = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBackground,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: _headerHeight,
            // make header scroll away completely to avoid leaving the gradient overlay
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            // ensure status bar icons are dark (suitable for light gradient header)
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ClipRRect(
                // round the bottom of the header so it visually separates from content
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.headerGradient,
                  ),
                  child: SafeArea(
                    child: Padding(
                      // push content lower so title/avatar sit comfortably below the status bar
                      padding: const EdgeInsets.only(
                        left: AppTheme.horizontalPadding,
                        right: AppTheme.horizontalPadding,
                        top: 20,
                        bottom: 12,
                      ),
                      child: _buildShopHeader(context),
                    ),
                  ),
                ),
              ),
            ),
            // settings button is moved into the flexibleSpace header so it scrolls with it
          ),

          // Content below header
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, _contentOffset),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // add an explicit top margin so action card sits below header nicely
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: _buildActionButtons(),
                    ),
                    const SizedBox(height: _itemSpacing),
                    _buildCurrentCampaign(),
                    const SizedBox(height: _itemSpacing),
                    const Text(
                      'Recent Transactions',
                      style: AppTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildTransactionsList(),
                    const SizedBox(height: _itemSpacing),
                    _buildQuickActions(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('New Request'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      ),
    );
  }

  Widget _buildShopHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppTheme.tealLight,
              child: const Text(
                'A',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Ashish's Chai Point",
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.primaryText,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mumbai, Maharashtra',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // positioned settings button so it is inside the header and scrolls away
        Positioned(
          right: -4,
          top: -4,
          child: Material(
            color: Colors.white,
            elevation: 2,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => SettingsScreen()));
              },
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Icon(
                  Icons.settings_outlined,
                  color: AppTheme.primaryTeal,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [AppTheme.defaultShadow],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: KpiTile(
                  title: "Today's GP",
                  value: '₹3,200',
                  icon: Icons.payment,
                  onTap: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: KpiTile(
                  title: 'Avg /day',
                  value: '₹8,500',
                  iconColor: Colors.green,
                  icon: Icons.trending_up,
                  onTap: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Replace QR'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.support_agent),
                  label: const Text('Support'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCampaign() {
    return CampaignCard(
      title: 'Shop Expansion',
      raised: 32000,
      target: 50000,
      daysLeft: 12,
      investorCount: 21,
      onManage: () {},
    );
  }

  Widget _buildTransactionsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
        boxShadow: [AppTheme.defaultShadow],
      ),
      child: Column(
        children: [
          TransactionRow(
            date: DateTime.now(),
            type: TransactionType.sale,
            amount: 250,
            status: 'Completed',
            currencyFormat: _currencyFormat,
          ),
          Divider(height: 1, color: Colors.grey[300]),
          TransactionRow(
            date: DateTime.now().subtract(const Duration(hours: 2)),
            type: TransactionType.sale,
            amount: 180,
            status: 'Completed',
            currencyFormat: _currencyFormat,
          ),
          Divider(height: 1, color: Colors.grey[300]),
          TransactionRow(
            date: DateTime.now().subtract(const Duration(hours: 4)),
            type: TransactionType.payout,
            amount: 500,
            status: 'Processing',
            currencyFormat: _currencyFormat,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: [AppTheme.defaultShadow],
      ),
      child: Column(
        children: [
          _quickActionTile(
            icon: Icons.upload_file,
            iconColor: Colors.blue,
            title: 'Upload Documents',
            subtitle: 'Complete KYC verification',
            onTap: () {},
          ),
          const Divider(),
          _quickActionTile(
            icon: Icons.account_balance,
            iconColor: Colors.green,
            title: 'Bank & Payout',
            subtitle: 'Manage your bank accounts',
            onTap: () {},
          ),
          const Divider(),
          _quickActionTile(
            icon: Icons.description,
            iconColor: Colors.orange,
            title: 'Agreements',
            subtitle: 'View terms and conditions',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor ?? Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
