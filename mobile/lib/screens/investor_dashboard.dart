import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'investor_profile_page.dart';
import '../design_tokens.dart';
import '../widgets/market_summary_card.dart';
import '../widgets/shop_card.dart';
import '../widgets/invest_modal.dart';
import '../widgets/shop_detail.dart';
import '../widgets/shimmer_placeholder.dart';
// previous UserPanel replaced by OverviewBoard
import '../widgets/overview_board.dart';
import '../widgets/animated_background.dart';

class InvestorDashboard extends StatefulWidget {
  const InvestorDashboard({super.key});

  @override
  State<InvestorDashboard> createState() => _InvestorDashboardState();
}

class _InvestorDashboardState extends State<InvestorDashboard> {
  final String _selectedFilter = 'All';
  bool _loading = true;
  List<Shop> _shops = [];
  List<Shop> _filteredShops = [];
  String _selectedSegment = 'All Listings';

  // mock user investments keyed by shop name
  final Map<String, Map<String, dynamic>> _userInvestments = {};

  @override
  void initState() {
    super.initState();
    // Set status bar for dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF12171C),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    _loadMockData();
  }

  Future<void> _loadMockData() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    _shops = [
      Shop(
        name: 'FreshMart',
        category: 'Grocery',
        city: 'Delhi',
        logoAsset: 'assets/shop1.png',
        avgUpi: 12000,
        ticket: 5000,
        estReturn: 1.3,
        raised: 35000,
        target: 50000,
        trending: true,
      ),
      Shop(
        name: 'Urban Tailor',
        category: 'Fashion',
        city: 'Mumbai',
        logoAsset: 'assets/shop2.png',
        avgUpi: 8000,
        ticket: 3000,
        estReturn: 1.2,
        raised: 15000,
        target: 20000,
      ),
      Shop(
        name: 'Chai Point',
        category: 'Cafe',
        city: 'Bangalore',
        logoAsset: 'assets/shop3.png',
        avgUpi: 10000,
        ticket: 4000,
        estReturn: 1.4,
        raised: 42000,
        target: 60000,
        trending: true,
      ),
    ];
    // mock that user has invested in FreshMart: 8 units
    _userInvestments.clear();
    _userInvestments['FreshMart'] = {
      'units': 8,
      'invested': 40000.0,
      'nextPayout': DateTime.now().add(const Duration(days: 1)),
      'dailyReturn': 120.0,
    };
    _applyFilters();
    setState(() => _loading = false);
  }

  void _applyFilters() {
    setState(() {
      // No search input UI — keep filter-only behaviour based on _selectedFilter
      _filteredShops = _shops.where((shop) {
        bool matchesFilter = _selectedFilter == 'All';
        if (_selectedFilter == 'Nearby') matchesFilter = shop.city == 'Delhi';
        if (_selectedFilter == 'High ROI') {
          matchesFilter = shop.estReturn >= 1.3;
        }
        if (_selectedFilter == 'Most Funded') {
          matchesFilter = shop.raised / shop.target > 0.7;
        }
        if (_selectedFilter == 'New') {
          matchesFilter = shop.raised / shop.target < 0.3;
        }
        return matchesFilter;
      }).toList();
    });
  }

  void _onInvest(Shop shop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => InvestModal(
        ticketPrice: shop.ticket,
        onConfirm: (qty) {
          // add to mock investments
          final prev = _userInvestments[shop.name];
          final added = qty * shop.ticket;
          setState(() {
            if (prev != null) {
              prev['units'] = prev['units'] + qty;
              prev['invested'] = prev['invested'] + added;
            } else {
              _userInvestments[shop.name] = {
                'units': qty,
                'invested': added,
                'nextPayout': DateTime.now().add(const Duration(days: 7)),
                'dailyReturn': 0.0,
              };
            }
          });
        },
      ),
    );
  }

  void _onDetails(Shop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopDetailPage(shop: shop)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure status bar style is set on every build
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(0, 0, 54, 77),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 32, 46),
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 0, 0, 0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // animated particle background (tweak densityMultiplier/minParticles/speed here)
            Positioned.fill(
              child: AnimatedBackground(
                densityMultiplier: 0.8,
                minParticles: 10,
                speed: 0.85,
                connectThreshold: 160.0,
              ),
            ),
            // content
            SafeArea(
              child: Column(
                children: [
                  // Fixed header
                  _StickyMarketHeader().build(context, 0, false),
                  // Fixed overview board
                  const OverviewBoard(),
                  // Fixed market summary
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 2,
                    ),
                    child: MarketSummaryCard(
                      activeListings: _shops.length,
                      todayVolume:
                          null, // TODO: hook to backend for real-time volume
                      totalFundRaised: currency.format(
                        _shops.fold<double>(0.0, (p, e) => p + e.raised),
                      ),
                    ),
                  ),
                  // Fixed segmented control
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.cardElevated,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedSegment = 'All Listings';
                                      _applyFilters();
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedSegment == 'All Listings'
                                            ? AppColors.surface
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'All Listings (${_shops.length})',
                                          style: TextStyle(
                                            color:
                                                _selectedSegment ==
                                                    'All Listings'
                                                ? Colors.white
                                                : AppColors.secondaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() {
                                      _selectedSegment = 'My Investments';
                                      _applyFilters();
                                    }),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _selectedSegment == 'My Investments'
                                            ? AppColors.surface
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'My Investments (${_userInvestments.length})',
                                          style: TextStyle(
                                            color:
                                                _selectedSegment ==
                                                    'My Investments'
                                                ? Colors.white
                                                : AppColors.secondaryText,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable shop list only
                  Expanded(
                    child: RefreshIndicator(
                      color: AppColors.accentGreen,
                      backgroundColor: AppColors.cardElevated,
                      onRefresh: _loadMockData,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          // Featured shop card (first shop) - keep but only on All Listings.
                          if (_shops.isNotEmpty &&
                              _selectedSegment == 'All Listings')
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 0,
                              ),
                              child: ShopCard(
                                shop: _shops.first,
                                onInvest: () => _onInvest(_shops.first),
                                onDetails: () => _onDetails(_shops.first),
                                accentColor: AppColors.accentOrange,
                                embedded: true,
                              ),
                            ),
                          // Shop list
                          if (_loading)
                            ...List.generate(
                              3,
                              (i) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 6,
                                ),
                                child: ShimmerPlaceholder(height: 120),
                              ),
                            )
                          else if (_filteredShops.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'No shops found.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF9AA5AD),
                                  ),
                                ),
                              ),
                            )
                          else
                            () {
                              // determine shops to display based on segment
                              List<Shop> base = _filteredShops;
                              if (_selectedSegment == 'My Investments') {
                                base = _shops
                                    .where(
                                      (s) =>
                                          _userInvestments.containsKey(s.name),
                                    )
                                    .toList();
                              }
                              // avoid duplicating featured in All Listings
                              final displayedShops =
                                  (_selectedSegment == 'All Listings' &&
                                      _shops.isNotEmpty &&
                                      base.contains(_shops.first))
                                  ? base
                                        .where((s) => s != _shops.first)
                                        .toList()
                                  : base;

                              return Column(
                                children: List.generate(displayedShops.length, (
                                  i,
                                ) {
                                  final shop = displayedShops[i];
                                  return Column(
                                    children: [
                                      if (i > 0) const SizedBox(height: 6),
                                      _StaggeredItem(
                                        index: i,
                                        child: ShopCard(
                                          shop: shop,
                                          onInvest: () => _onInvest(shop),
                                          onDetails: () => _onDetails(shop),
                                          accentColor: AppColors.accentOrange,
                                          embedded: true,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            }(),
                          const SizedBox(height: 20), // Bottom padding
                        ],
                      ),
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

// simple staggered slide+fade wrapper
class _StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;
  const _StaggeredItem({required this.child, required this.index});

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _offset;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.85, curve: Curves.easeOutCubic),
    );
    _offset = Tween(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curve);
    _opacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    Future.delayed(
      Duration(milliseconds: 60 * widget.index),
      () => _ctrl.forward(),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(opacity: _opacity, child: widget.child),
    );
  }
}

// Sticky header delegate for Market page
class _StickyMarketHeader extends SliverPersistentHeaderDelegate {
  @override
  double get minExtent => 80;
  @override
  double get maxExtent => 92;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(
        0x0012171C,
      ), // keep transparent background; parent gradient shows
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Brand (left)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Vitkara',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Invest in Main Street',
                  style: TextStyle(
                    color: Color(0xFF8DA6B0),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Small avatar / quick actions
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InvestorProfilePage(),
                      ),
                    );
                  },
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: Color(0xFF0CBBD6),
                    child: Icon(Icons.person, size: 20, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF00E5FF),
                  ),
                  onPressed: () {},
                  splashRadius: 22,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      false;
}

// User panel card shown under the header — Vittas-first display
// _UserPanel removed; replaced by widgets/user_panel.dart

// _MiniStat removed; replaced by Vittas-first layout in _UserPanel

// Listing is now rendered using `ShopCard` widget in widgets/shop_card.dart
