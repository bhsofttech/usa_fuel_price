import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/update_controller.dart';
import 'package:usa_gas_price/widgets/data_widget.dart';
import '../../controller/google_ads_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ExpDetailsScreen extends StatefulWidget {
  final String endPoint;
  final String title;
  const ExpDetailsScreen({
    super.key,
    required this.endPoint,
    required this.title,
  });

  @override
  State<ExpDetailsScreen> createState() => _ExpDetailsScreenState();
}

class _ExpDetailsScreenState extends State<ExpDetailsScreen> {
  final UpdateController _updateController = Get.find();
  final GoogleAdsController _googleAdsController = Get.find();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    callApi();
    _googleAdsController.showAds();
    analytics.logScreenView(screenName: widget.title);
  }

  Future<void> callApi() async {
    await _updateController.getData(widget.endPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // iOS style background
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          widget.title.toUpperCase(),
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        iconTheme: IconThemeData(color: darkBlue),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD1D1D6),
                width: 0.5,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () {
            return _updateController.showDataLoading.value
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitFadingCircle(
                          color: primaryBlue,
                          size: 40.0,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Loading Data...",
                          style: TextStyle(
                            color: darkBlue.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: "SF Pro Text",
                          ),
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const DateTimeWidget(),
                        const SizedBox(height: 12.0),
                        Expanded(
                          child: _buildDataTable(),
                        ),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    if (_updateController.getdata.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: darkBlue.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              "No data available",
              style: TextStyle(
                color: darkBlue.withOpacity(0.6),
                fontSize: 16,
                fontFamily: "SF Pro Text",
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Dynamic column generation based on data keys
    final sampleItem = _updateController.getdata.first;
    final columns = sampleItem.toJson().keys.map((key) {
      return DataColumn(
        label: Text(
          key.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        tooltip: key.replaceAll('_', ' '),
      );
    }).toList();

    // Fixed first column width
    const double firstColumnWidth = 120.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fixed first column
            Container(
              width: firstColumnWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                border: Border(
                  right: BorderSide(
                    color: const Color(0xFFE5E5EA),
                    width: 0.5,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header for first column
                  Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Text(
                      columns[0].label.toString(),
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Display",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Data cells for first column
                  ..._updateController.getdata.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final value = item.toJson().values.first;
                    return GestureDetector(
                      onTap: () => _showCellDialog(context, item, 0),
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFFE5E5EA),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Text(
                          value?.toString() ?? '',
                          style: TextStyle(
                            color: darkBlue.withOpacity(0.85),
                            fontFamily: "SF Pro Text",
                            fontSize: 13.0,
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            // Scrollable remaining columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(
                    const Color(0xFFF9FAFB),
                  ),
                  headingTextStyle: TextStyle(
                    color: darkBlue,
                    fontFamily: "SF Pro Display",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  dataTextStyle: TextStyle(
                    color: darkBlue.withOpacity(0.85),
                    fontFamily: "SF Pro Text",
                    fontSize: 13.0,
                    fontWeight: FontWeight.w400,
                  ),
                  columnSpacing: 20,
                  horizontalMargin: 16,
                  headingRowHeight: 50,
                  dataRowHeight: 48,
                  dividerThickness: 0.5,
                  border: const TableBorder(
                    horizontalInside: BorderSide(
                      color: Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                    right: BorderSide(
                      color: Color(0xFFE5E5EA),
                      width: 0.5,
                    ),
                  ),
                  columns: columns.sublist(1), // Exclude first column
                  rows: _updateController.getdata.map((item) {
                    return DataRow(
                      cells: item.toJson().values.skip(1).map((value) {
                        return DataCell(
                          Text(
                            value?.toString() ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          onTap: () => _showCellDialog(context, item,
                              item.toJson().values.toList().indexOf(value)),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to show cell content in a dialog
  void _showCellDialog(BuildContext context, dynamic item, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          item
              .toJson()
              .keys
              .elementAt(index)
              .replaceAll('_', ' ')
              .toUpperCase(),
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          item.toJson().values.elementAt(index)?.toString() ?? '',
          style: TextStyle(
            color: darkBlue.withOpacity(0.85),
            fontFamily: "SF Pro Text",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
