import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/time/time_setup_screen.dart';

class CrudeOilPricesScreen extends StatefulWidget {
  const CrudeOilPricesScreen({super.key});

  @override
  State<CrudeOilPricesScreen> createState() => _CrudeOilPricesScreenState();
}

class _CrudeOilPricesScreenState extends State<CrudeOilPricesScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> crudeData = [];
  bool isLoading = true;
  String errorMessage = '';

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(screenName: "USA Crude Oil Prices Screen");

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fetchCrudeOilPrices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCrudeOilPrices() async {
    const url = 'https://www.oilmonster.com/crude-oil-prices/united-states/1';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load data: ${response.statusCode}');
      }

      final document = parser.parse(response.body);
      final table = document.querySelector('table.gradelisttable') ??
          document.querySelector('table#catpricetable');

      if (table == null) throw Exception('Table not found');

      final rows = table.querySelectorAll('tbody tr');
      List<Map<String, dynamic>> data = [];
      String currentState = '';

      for (var row in rows) {
        final cells = row.querySelectorAll('td');

        if (row.classes.contains('statehead') || cells.length == 1) {
          final stateLink = row.querySelector('a');
          if (stateLink != null) {
            currentState = stateLink.text.trim();
          }
          continue;
        }

        if (cells.length >= 7) {
          final blendEl = cells[0].querySelector('a') ?? cells[0];
          final blend = blendEl.text.trim();

          final price = cells[1].text.trim();
          final change = cells[2].text.trim();
          final changePercent = cells[3].text.trim();
          final lowHighWeek = cells[4].text.trim();
          final lowHighMonth = cells[5].text.trim();
          final unit = cells[6].text.trim();
          final date = cells.length > 7 ? cells[7].text.trim() : '';

          data.add({
            'state': currentState,
            'blend': blend,
            'price': price,
            'change': change,
            'changePercent': changePercent,
            'lowHighWeek': lowHighWeek,
            'lowHighMonth': lowHighMonth,
            'unit': unit,
            'date': date,
          });
        }
      }

      if (mounted) {
        setState(() {
          crudeData = data;
          isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Error: $e';
          isLoading = false;
        });
      }
    }
  }

  Color _getChangeColor(String change) {
    if (change.contains('+')) return Colors.green;
    if (change.contains('-')) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          leadingWidth: 50,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.access_time_outlined,
                color: Color(0xFF007AFF),
              ),
              onPressed: () {
                Get.to(() => const TimeSetupScreen());
              },
            ).paddingOnly(bottom: 5),
          ],
          backgroundColor: cardWhite.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "USA Crude Oil Prices".toUpperCase(),
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
              color: cardWhite.withOpacity(0.95),
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
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(color: primaryBlue),
              )
            : errorMessage.isNotEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Regional Crude Blends",
                              style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (crudeData.isEmpty)
                              Center(
                                  child: Text("No crude data found.",
                                      style: TextStyle(color: textSecondary)))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: crudeData.length,
                                itemBuilder: (context, index) {
                                  final item = crudeData[index];
                                  return _buildStaggeredItem(
                                      index, _buildCrudeCard(item));
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildStaggeredItem(int index, Widget child) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(
              0, (1 - _animationController.value) * 20 * (index + 1) * 0.1),
          child: Opacity(
            opacity: _animationController.value,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildCrudeCard(Map<String, dynamic> item) {
    final changeColor = _getChangeColor(item['change']);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.oil_barrel_rounded,
                      color: primaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${item['state']} - ${item['blend']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Price',
                        style: TextStyle(color: textSecondary, fontSize: 13)),
                    Text('\$${item['price']}',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            fontFamily: "SF Pro Display")),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(item['changePercent'],
                        style: TextStyle(
                            color: changeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: "SF Pro Display")),
                    Text('Trend: ${item['change']}',
                        style: TextStyle(color: changeColor, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            _buildDetailRow('Unit', item['unit'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('Week Low/High', item['lowHighWeek'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('Month Low/High', item['lowHighMonth'] ?? ''),
            const SizedBox(height: 8),
            _buildDetailRow('Last Updated', item['date'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: textSecondary, fontSize: 13, fontFamily: "SF Pro Text")),
        Text(value,
            style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: "SF Pro Display")),
      ],
    );
  }
}
