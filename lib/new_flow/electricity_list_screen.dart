import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class ElectricityListScreen extends StatefulWidget {
  const ElectricityListScreen({super.key});

  @override
  State<ElectricityListScreen> createState() => _ElectricityListScreenState();
}

class _ElectricityListScreenState extends State<ElectricityListScreen> {
  List<Map<String, String>> electricityPrices = [];
  bool isLoading = true;
  String errorMessage = '';

  final Color primaryOrange = const Color(0xFFFF9500);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    _fetchElectricityPrices();
  }

  Future<void> _fetchElectricityPrices() async {
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
      List<Map<String, String>> tempElectricity = [];

      // Find all tables with class gaselectricity
      final tables = document.querySelectorAll('table.gaselectricity');
      
      for (var table in tables) {
        // Check if this table is for Electricity by looking at the links
        final firstLink = table.querySelector('a');
        if (firstLink != null && firstLink.attributes['href']?.contains('electricity-price') == true) {
          final rows = table.querySelectorAll('tbody tr');
          for (var row in rows) {
            final cells = row.querySelectorAll('td');
            if (cells.length >= 3) {
              final location = cells[0].text.trim();
              final price = cells[1].text.trim();
              final change = cells[2].text.trim();

              tempElectricity.add({
                'location': location,
                'price': price,
                'change': change,
              });
            }
          }
          break; // Found the electricity table
        }
      }

      if (mounted) {
        setState(() {
          electricityPrices = tempElectricity;
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
            "USA ELECTRICITY PRICES",
            style: TextStyle(
              color: primaryOrange,
              fontFamily: "SF Pro Display",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: primaryOrange, size: 20),
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
            ? Center(child: CircularProgressIndicator(color: primaryOrange))
            : errorMessage.isNotEmpty
                ? Center(child: Text(errorMessage))
                : electricityPrices.isEmpty
                    ? const Center(child: Text("No electricity data found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const BouncingScrollPhysics(),
                        itemCount: electricityPrices.length,
                        itemBuilder: (context, index) {
                          final data = electricityPrices[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildElectricityCard(data),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildElectricityCard(Map<String, String> data) {
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
                  colors: [Color(0xFFFFD60A), Color(0xFFFF9F0A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9F0A).withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.bolt_rounded,
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
                    data['location'] ?? '',
                    style: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Electricity Price",
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
                    fontSize: 11.0,
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
