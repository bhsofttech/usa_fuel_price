import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/pages/market/stock/stock_list_screen.dart';

class CryptoCategoriesScreen extends StatefulWidget {
  const CryptoCategoriesScreen({super.key});

  @override
  State<CryptoCategoriesScreen> createState() => _CryptoCategoriesScreenState();
}

class _CryptoCategoriesScreenState extends State<CryptoCategoriesScreen> with TickerProviderStateMixin {
  final Color primaryBlue = const Color(0xFF007AFF);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<StockCategory> categories = [
    StockCategory(
      title: "All Coins",
      icon: Icons.list_alt_rounded,
      color: Color(0xFF0A84FF),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-all/',
    ),
    StockCategory(
      title: "Top Gainers",
      icon: Icons.trending_up_rounded,
      color: Color(0xFF30D158),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-gainers/',
    ),
    StockCategory(
      title: "Biggest Losers",
      icon: Icons.trending_down_rounded,
      color: Color(0xFFFF453A),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-losers/',
    ),
    StockCategory(
      title: "DeFi Coins",
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF5E5CE6),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-defi/',
    ),
    StockCategory(
      title: "Large Cap",
      icon: Icons.diamond_rounded,
      color: Color(0xFFBF5AF2),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-large-cap/',
    ),
    StockCategory(
      title: "Small Cap",
      icon: Icons.emoji_objects_rounded,
      color: Color(0xFFFF9F0A),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-small-cap/',
    ),
    StockCategory(
      title: "52 Week High",
      icon: Icons.arrow_upward_rounded,
      color: Color(0xFF30D158),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-52-week-high/',
    ),
    StockCategory(
      title: "52 Week Low",
      icon: Icons.arrow_downward_rounded,
      color: Color(0xFFFF453A),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-52-week-low/',
    ),
    StockCategory(
      title: "All Time High",
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFFFF2D55),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-all-time-high/',
    ),
    StockCategory(
      title: "All Time Low",
      icon: Icons.water_drop_rounded,
      color: Color(0xFF66D9E8),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-all-time-low/',
    ),
    StockCategory(
      title: "NFT Coins",
      icon: Icons.image_rounded,
      color: Color(0xFFAF52DE),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-nft/',
    ),
    StockCategory(
      title: "Meme Coins",
      icon: Icons.emoji_emotions_rounded,
      color: Color(0xFFFF9500),
      route: 'https://in.tradingview.com/markets/cryptocurrencies/prices-meme/',
    ),
  ];

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
            "Crypto Categories".toUpperCase(),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose a Crypto Category",
                    style: TextStyle(
                      color: primaryBlue.withOpacity(0.8),
                      fontFamily: "SF Pro Text",
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return Column(
      children: categories.asMap().entries.map((entry) {
        int index = entry.key;
        StockCategory category = entry.value;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, (1 - _animationController.value) * 20 * (index + 1)),
              child: Opacity(
                opacity: _animationController.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildEnhancedCategoryCard(
                    category.title,
                    category.icon,
                    category.color,
                    [category.color.withOpacity(0.7), category.color],
                    () => Get.to(() => StockListScreen(url: category.route)),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildEnhancedCategoryCard(
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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

class StockCategory {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  StockCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });
}