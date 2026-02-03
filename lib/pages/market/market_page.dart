import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/pages/market/bonds/bond_categories_screen.dart';
import 'package:usa_gas_price/pages/market/crypto/crypto_categories.dart';
import 'package:usa_gas_price/pages/market/etf/etf_screen.dart';
import 'package:usa_gas_price/pages/market/forex/forex_screen.dart';
import 'package:usa_gas_price/pages/market/futures/futures_screen.dart';
import 'package:usa_gas_price/pages/market/indices/indices_screen.dart';
import 'package:usa_gas_price/pages/market/stock/stock_categories.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> with TickerProviderStateMixin {
  final Color primaryBlue = const Color(0xFF007AFF);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    init();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          leadingWidth: 50,
          backgroundColor: Colors.white.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "USA Stock Markets".toUpperCase(),
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          iconTheme: IconThemeData(color: primaryBlue),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 0.33,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose a Market",
                    style: TextStyle(
                      color: primaryBlue.withOpacity(0.8),
                      fontFamily: "SF Pro Text",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMarketOptions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketOptions() {
    final markets = [
      {
        'title': 'Stock',
        'icon': Icons.show_chart_rounded,
        'color': const Color(0xFF34C759),
        'gradient': [const Color(0xFF5AC8FA), const Color(0xFF34C759)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const StockCategoriesScreen(),
            ),
      },
      {
        'title': 'Crypto',
        'icon': Icons.currency_bitcoin_rounded,
        'color': const Color(0xFFFF9500),
        'gradient': [const Color(0xFFFFB340), const Color(0xFFFF9500)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const CryptoCategoriesScreen(),
            ),
      },
      {
        'title': 'Indices',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF007AFF),
        'gradient': [const Color(0xFF4A90E2), const Color(0xFF007AFF)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const IndicesScreen(),
            ),
      },
      {
        'title': 'ETF',
        'icon': Icons.account_balance_wallet_rounded,
        'color': const Color(0xFFAF52DE),
        'gradient': [const Color(0xFFBF5AF2), const Color(0xFFAF52DE)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const EtfScreen(),
            ),
      },
      {
        'title': 'Features',
        'icon': Icons.star_rounded,
        'color': const Color(0xFFFF3B30),
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFFF3B30)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const FuturesScreen(),
            ),
      },
      {
        'title': 'Bond',
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF5856D6),
        'gradient': [const Color(0xFF8E8FFA), const Color(0xFF5856D6)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const BondCategoriesScreen(),
            ),
      },
      {
        'title': 'Forex',
        'icon': Icons.currency_exchange,
        'color': const Color(0xFF5856D6),
        'gradient': [const Color(0xFF8E8FFA), const Color(0xFF5856D6)],
        'onTap': () => Get.find<GoogleAdsController>().navigateWithAd(
              nextPage: const ForexScreen(),
            ),
      },
    ];

    return Column(
      children: markets.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> market = entry.value;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  0, (1 - _animationController.value) * 20 * (index + 1)),
              child: Opacity(
                opacity: _animationController.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEnhancedMarketCard(
                    market['title'],
                    market['icon'],
                    market['color'],
                    market['gradient'],
                    market['onTap'],
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedMarketCard(
    String title,
    IconData icon,
    Color color,
    List<Color> gradient,
    Function() onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: primaryBlue,
                      fontFamily: "SF Pro Text",
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: primaryBlue.withOpacity(0.4),
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
