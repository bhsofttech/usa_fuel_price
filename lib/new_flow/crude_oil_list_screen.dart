import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class CrudeOilListScreen extends StatefulWidget {
  const CrudeOilListScreen({super.key});

  @override
  State<CrudeOilListScreen> createState() => _CrudeOilListScreenState();
}

class _CrudeOilListScreenState extends State<CrudeOilListScreen> {
  List<Map<String, String>> crudeOilPrices = [];
  bool isLoading = true;
  String errorMessage = '';

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    _fetchCrudeOilPrices();
  }

  Future<void> _fetchCrudeOilPrices() async {
    const url = 'https://www.oilmonster.com/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load data');
      }

      final document = parser.parse(response.body);
      List<Map<String, String>> tempCrude = [];

      final crudeRows =
          document.querySelectorAll('table.iternataionalcrude tbody tr');
      for (var row in crudeRows) {
        final cells = row.querySelectorAll('td');
        if (cells.length >= 4) {
          final region = cells[0].text.trim();
          final blend = cells[1].text.trim();
          final price = cells[2].text.trim();
          final change = cells[3].text.trim();

          tempCrude.add({
            'region': region,
            'blend': blend,
            'price': price,
            'change': change,
          });
        }
      }

      if (mounted) {
        setState(() {
          crudeOilPrices = tempCrude;
          isLoading = false;
        });
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
          backgroundColor: cardWhite.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "INTERNATIONAL CRUDE PRICES",
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: primaryBlue, size: 20),
            onPressed: () => Get.back(),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color: cardWhite.withOpacity(0.95),
              border: const Border(
                bottom: BorderSide(
                  color: Color(0xFFE5E5EA),
                  width: 0.33,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: crudeOilPrices.length,
                    itemBuilder: (context, index) {
                      final data = crudeOilPrices[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildCrudeCard(data),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildCrudeCard(Map<String, String> data) {
    final change = data['change'] ?? '0.00';
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
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.opacity_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['region'] ?? '',
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    data['blend'] ?? '',
                    style: TextStyle(
                      color: textSecondary,
                      fontFamily: "SF Pro Text",
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data['price'] ?? 'N/A',
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  change,
                  style: TextStyle(
                    color: _getChangeColor(change),
                    fontFamily: "SF Pro Text",
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
