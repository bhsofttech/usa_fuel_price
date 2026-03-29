import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'package:usa_gas_price/time/time_setup_screen.dart';

class GasCityWiseScreen extends StatefulWidget {
  final String stateName;
  final String stateUrl;
  const GasCityWiseScreen(
      {super.key, required this.stateName, required this.stateUrl});

  @override
  State<GasCityWiseScreen> createState() => _GasCityWiseScreenState();
}

class _GasCityWiseScreenState extends State<GasCityWiseScreen>
    with TickerProviderStateMixin {
  Map<String, Map<String, String>> stateAverage = {};
  List<Map<String, String>> cityAverages = [];
  List<Map<String, String>> lowestStations = [];

  bool isLoading = true;
  String errorMessage = '';

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    analytics.logScreenView(
        screenName: "${widget.stateName} Gas Prices Screen");

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

    _fetchStatePrices();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatePrices() async {
    final url = widget.stateUrl.startsWith('http')
        ? widget.stateUrl
        : 'https://www.oilmonster.com${widget.stateUrl}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP Error: ${response.statusCode}');
      }

      final document = parser.parse(response.body);

      // 1. State Average
      Map<String, Map<String, String>> avg = {};
      final wdBoxes = document.querySelectorAll('div.border.p-2, div.col-md-3');
      for (var box in wdBoxes) {
        final nameEl = box.querySelector('h4.wdname, .wdname');
        final priceEl = box.querySelector('.wdprice, div.wdprice');
        final changeEl = box.querySelector('div[class*="wdprice"]');

        if (nameEl != null && priceEl != null) {
          final fuel = nameEl.text.trim();
          final price = priceEl.text.trim();
          final change = changeEl?.text.trim() ?? '';
          avg[fuel] = {'price': price, 'change': change};
        }
      }

      // 2. City Averages
      List<Map<String, String>> cities = [];
      final cityTable = document.querySelector('table.gpricetable');
      if (cityTable != null) {
        final rows = cityTable.querySelectorAll('tbody tr');
        for (var row in rows) {
          final cells = row.querySelectorAll('td');
          if (cells.length >= 5) {
            final city =
                (cells[0].querySelector('a')?.text ?? cells[0].text).trim();
            cities.add({
              'city': city,
              'regular': cells[1].text.trim(),
              'midgrade': cells[2].text.trim(),
              'premium': cells[3].text.trim(),
              'diesel': cells[4].text.trim(),
            });
          }
        }
      }

      // 3. Lowest Gas Stations
      List<Map<String, String>> stations = [];
      final allTables = document.querySelectorAll('table');

      for (var table in allTables) {
        final headerText =
            table.querySelector('thead')?.text.toLowerCase() ?? '';
        if (headerText.contains('gas station') &&
            (headerText.contains('lowest') ||
                table.text.contains('Chevron') ||
                table.text.contains('ExxonMobil'))) {
          final rows = table.querySelectorAll('tbody tr');
          for (var row in rows) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 5) {
              String stationInfo = '';
              final nameLink = cells[0].querySelector('a');
              final addressEl =
                  cells[0].querySelector('.gascomaddress, p, div');

              if (nameLink != null) {
                stationInfo = nameLink.text.trim();
              } else {
                stationInfo = cells[0].text.trim();
              }

              if (addressEl != null) {
                final addr = addressEl.text.trim();
                if (addr.isNotEmpty && !stationInfo.contains(addr)) {
                  stationInfo += '\n$addr';
                }
              }

              if (stationInfo.trim().isEmpty) continue;

              stations.add({
                'station': stationInfo,
                'regular': cells[1].text.trim(),
                'midgrade': cells[2].text.trim(),
                'premium': cells[3].text.trim(),
                'diesel': cells[4].text.trim(),
              });
            }
          }
          if (stations.isNotEmpty) break;
        }
      }

      if (mounted) {
        setState(() {
          stateAverage = avg;
          cityAverages = cities;
          lowestStations = stations;
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
            "${widget.stateName} Gas Prices".toUpperCase(),
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
                              "${widget.stateName} Average",
                              style: TextStyle(
                                color: primaryBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...stateAverage.entries
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              final fuel = entry.value.key;
                              final data = entry.value.value;
                              final change = data['change'] ?? '0.00';

                              return _buildStaggeredItem(
                                  index,
                                  _buildPriceCard(fuel, data['price'] ?? 'N/A',
                                      change, Icons.analytics_rounded));
                            }),
                            const SizedBox(height: 24),
                            if (cityAverages.isNotEmpty) ...[
                              Text(
                                "City Averages",
                                style: TextStyle(
                                  color: primaryBlue.withOpacity(0.8),
                                  fontFamily: "SF Pro Text",
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: cityAverages.length,
                                itemBuilder: (context, index) {
                                  final item = cityAverages[index];
                                  return _buildStaggeredItem(
                                      index + stateAverage.length,
                                      _buildGenericCard(
                                          item['city'] ?? '',
                                          item,
                                          Icons.location_city_rounded,
                                          "city"));
                                },
                              ),
                              const SizedBox(height: 24),
                            ],
                            if (lowestStations.isNotEmpty) ...[
                              Text(
                                "Lowest Gas Stations",
                                style: TextStyle(
                                  color: primaryBlue.withOpacity(0.8),
                                  fontFamily: "SF Pro Text",
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: lowestStations.length,
                                itemBuilder: (context, index) {
                                  final item = lowestStations[index];
                                  return _buildStaggeredItem(
                                      index +
                                          stateAverage.length +
                                          cityAverages.length,
                                      _buildGenericCard(
                                          item['station'] ?? '',
                                          item,
                                          Icons.local_gas_station_rounded,
                                          "station"));
                                },
                              ),
                            ],
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

  Widget _buildPriceCard(
      String title, String price, String change, IconData icon) {
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [lightBlue, primaryBlue],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text('Change: $change',
                      style: TextStyle(
                          color: _getChangeColor(change), fontSize: 12)),
                ],
              ),
            ),
            Text(price,
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "SF Pro Display")),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericCard(String title, Map<String, String> data,
      IconData icon, String typeIdentifier) {
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
                  child: Icon(icon, color: primaryBlue, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
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
            _buildPriceRow('Regular', data['regular'] ?? ''),
            const Divider(height: 20, thickness: 0.5),
            _buildPriceRow('Midgrade', data['midgrade'] ?? ''),
            const Divider(height: 20, thickness: 0.5),
            _buildPriceRow('Premium', data['premium'] ?? ''),
            const Divider(height: 20, thickness: 0.5),
            _buildPriceRow('Diesel Price', data['diesel'] ?? '', isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: textSecondary, fontSize: 14, fontFamily: "SF Pro Text")),
        Text(value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              fontFamily: "SF Pro Display",
            )),
      ],
    );
  }
}
