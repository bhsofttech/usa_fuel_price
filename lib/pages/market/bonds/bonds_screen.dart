import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/Get.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/controller/stock_controller.dart';
import 'package:usa_gas_price/widgets/svg_icon_widget.dart';

class BondsScreen extends StatefulWidget {
  final String url;
  const BondsScreen({super.key, required this.url});

  @override
  State<BondsScreen> createState() => _BondsScreenState();
}

class _BondsScreenState extends State<BondsScreen>
    with TickerProviderStateMixin {
  StockController stockController = Get.find();
  final Color primaryBlue = const Color(0xFF007AFF);

  final ScrollController _verticalBodyController = ScrollController();
  final ScrollController _verticalColumnController = ScrollController();
  final ScrollController _horizontalBodyController = ScrollController();
  final ScrollController _horizontalHeaderController = ScrollController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    Get.find<GoogleAdsController>().showAds();
    stockController.fetchBonds(widget.url);

    // Sync vertical
    _verticalBodyController.addListener(() {
      if (_verticalColumnController.offset != _verticalBodyController.offset) {
        _verticalColumnController.jumpTo(_verticalBodyController.offset);
      }
    });
    _verticalColumnController.addListener(() {
      if (_verticalBodyController.offset != _verticalColumnController.offset) {
        _verticalBodyController.jumpTo(_verticalColumnController.offset);
      }
    });

    // Sync horizontal
    _horizontalBodyController.addListener(() {
      if (_horizontalHeaderController.offset !=
          _horizontalBodyController.offset) {
        _horizontalHeaderController.jumpTo(_horizontalBodyController.offset);
      }
    });
    _horizontalHeaderController.addListener(() {
      if (_horizontalBodyController.offset !=
          _horizontalHeaderController.offset) {
        _horizontalBodyController.jumpTo(_horizontalHeaderController.offset);
      }
    });

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
    _verticalBodyController.dispose();
    _verticalColumnController.dispose();
    _horizontalBodyController.dispose();
    _horizontalHeaderController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> init() async {
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const minWidth = 120.0;
    double colWidth = (screenWidth / 5).clamp(minWidth, 160);

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
              "US Bonds".toUpperCase(),
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.swipe_outlined,
                      size: 16,
                      color: primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Scroll',
                      style: TextStyle(
                        fontFamily: "SF Pro Text",
                        fontSize: 12,
                        color: primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: SafeArea(
            child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                    position: _slideAnimation,
                    child: Obx(
                      () {
                        if (stockController.fechBondsLoading.value) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryBlue),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Loading bonds data...",
                                    style: TextStyle(
                                      color: primaryBlue.withOpacity(0.8),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        if (stockController.getBonds.isEmpty) {
                          return Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bar_chart_rounded,
                                    size: 36,
                                    color: primaryBlue.withOpacity(0.8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "No bonds found",
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontFamily: "SF Pro Text",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Try refreshing or check your connection",
                                    style: TextStyle(
                                      color: primaryBlue.withOpacity(0.8),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 13,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final firstIndex = stockController.getBonds.first;
                        final remainingIndices =
                            stockController.getBonds.skip(1).toList();

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(children: [
                            // Fixed header row
                            Container(
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFFE5E5EA),
                                    width: 0.33,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Fixed Symbol column for header
                                  Container(
                                    width: 200,
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      border: Border(
                                        right: BorderSide(
                                            color: Color(0xFFE5E5EA),
                                            width: 0.33),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            "BOND",
                                            style: TextStyle(
                                              fontFamily: "SF Pro Text",
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color:
                                                  primaryBlue.withOpacity(0.8),
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        Icon(
                                          Icons.filter_list_rounded,
                                          size: 14,
                                          color: primaryBlue.withOpacity(0.8),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Scrollable data for header row
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _horizontalHeaderController,
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          _buildHeaderCell(
                                              firstIndex.price, colWidth),
                                          _buildHeaderCell(
                                              firstIndex.changePercent,
                                              colWidth),
                                          _buildHeaderCell(
                                              firstIndex.volume, colWidth),
                                          _buildHeaderCell(
                                              firstIndex.relativeVolume,
                                              colWidth),
                                          _buildHeaderCell(
                                              firstIndex.marketCap, colWidth),
                                          _buildHeaderCell(
                                              firstIndex.peRatio, colWidth),
                                          _buildHeaderCell(
                                              firstIndex.epsDilTTM, colWidth),
                                          _buildHeaderCell(
                                              firstIndex.epsDilGrowthYoY,
                                              colWidth),
                                          _buildHeaderCell(
                                              firstIndex.dividendYield,
                                              colWidth),
                                          _buildHeaderCell(
                                              firstIndex.sector, colWidth),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Scrollable body for remaining rows
                            Expanded(
                              child: Row(
                                children: [
                                  // Fixed Symbol column for remaining rows
                                  SingleChildScrollView(
                                    controller: _verticalColumnController,
                                    child: Column(
                                      children: remainingIndices
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final i = entry.key;
                                        final index = entry.value;
                                        return Container(
                                          width: 200,
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: i.isEven
                                                ? Colors.white
                                                : const Color(0xFFF2F4F7),
                                            border: Border(
                                              right: const BorderSide(
                                                  color: Color(0xFFE5E5EA),
                                                  width: 0.33),
                                              bottom: BorderSide(
                                                color: i ==
                                                        remainingIndices
                                                                .length -
                                                            1
                                                    ? Colors.transparent
                                                    : const Color(0xFFE5E5EA),
                                                width: 0.33,
                                              ),
                                            ),
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              index.image.isEmpty
                                                  ? Container(
                                                      height: 32,
                                                      width: 32,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: primaryBlue
                                                            .withOpacity(0.2),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          "S",
                                                          style: TextStyle(
                                                            color: primaryBlue,
                                                            fontFamily:
                                                                "SF Pro Text",
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.06),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: CircleSvgAvatar(
                                                        url: index.image,
                                                        size: 28,
                                                        stock: index.symbol,
                                                      ),
                                                    ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      index.shortName,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "SF Pro Text",
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 12,
                                                        color: primaryBlue,
                                                        letterSpacing: -0.2,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 0),
                                                    Text(
                                                      index.symbol,
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "SF Pro Text",
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        fontSize: 9,
                                                        color: primaryBlue
                                                            .withOpacity(0.8),
                                                        letterSpacing: -0.2,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // Scrollable body for remaining rows
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: _horizontalBodyController,
                                      scrollDirection: Axis.horizontal,
                                      child: SingleChildScrollView(
                                        controller: _verticalBodyController,
                                        child: Column(
                                          children: remainingIndices
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final i = entry.key;
                                            final index = entry.value;

                                            return Container(
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: i.isEven
                                                    ? Colors.white
                                                    : const Color(0xFFF2F4F7),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: i ==
                                                            remainingIndices
                                                                    .length -
                                                                1
                                                        ? Colors.transparent
                                                        : const Color(
                                                            0xFFE5E5EA),
                                                    width: 0.33,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  _buildDataCell(
                                                      index.price, colWidth, i),
                                                  _buildChangeCell(
                                                      index.changePercent,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(index.volume,
                                                      colWidth, i),
                                                  _buildDataCell(
                                                      index.relativeVolume,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(
                                                      index.marketCap,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(index.peRatio,
                                                      colWidth, i),
                                                  _buildDataCell(
                                                      index.epsDilTTM,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(
                                                      index.epsDilGrowthYoY,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(
                                                      index.dividendYield,
                                                      colWidth,
                                                      i),
                                                  _buildDataCell(index.sector,
                                                      colWidth, i),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        );
                      },
                    )))));
  }

  Widget _buildHeaderCell(String text, double width) {
    return Container(
      width: width,
      height: 40,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E5EA), width: 0.33),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: TextStyle(
          fontFamily: "SF Pro Text",
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: primaryBlue.withOpacity(0.8),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text, double width, int rowIndex) {
    final isPositive = text.contains("+");
    final isNegative = text.contains("âˆ’") || text.contains("−");
    Color textColor = primaryBlue;
    if (isPositive) textColor = const Color(0xFF34C759); // Green for positive
    if (isNegative) textColor = const Color(0xFFFF3B30); // Red for negative

    return Container(
      width: width,
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E5EA), width: 0.33),
        ),
      ),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: TextStyle(
          fontFamily: "SF Pro Text",
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildChangeCell(String value, double width, int rowIndex) {
    final isNegative = value.contains("âˆ’") || value.contains("−");
    final color =
        isNegative ? const Color(0xFFFF3B30) : const Color(0xFF34C759);
    final icon =
        isNegative ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    return Container(
      width: width,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: const BoxDecoration(
        border: Border(
          right: BorderSide(color: Color(0xFFE5E5EA), width: 0.33),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: "SF Pro Text",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
