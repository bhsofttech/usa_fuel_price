import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/update_controller.dart';


class DataDetailsScreen extends StatefulWidget {
  final String endPoint;
  final String title;
  const DataDetailsScreen(
      {super.key, required this.endPoint, required this.title});

  @override
  State<DataDetailsScreen> createState() => _DataDetailsScreenState();
}

class _DataDetailsScreenState extends State<DataDetailsScreen> {
  final UpdateController _updateController = Get.find();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  @override
  void initState() {
    super.initState();
    callApi();
    analytics.logScreenView(screenName: widget.title);
  }

  Future<void> callApi() async {
    await _updateController.getData(widget.endPoint);
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
            widget.title.toUpperCase(),
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
        child: Obx(
          () {
            return _updateController.showDataLoading.value
                ? Center(child: CircularProgressIndicator(color: primaryBlue))
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sticky First Column (Fixed)
                            Column(
                              children: [
                                for (int i = 0;
                                    i < _updateController.getdata.length;
                                    i++)
                                  _buildDataContainer(
                                    i: i,
                                    title: _updateController.getdata[i].one,
                                    isFirstColumn: true,
                                    isHeader: i == 0,
                                  ),
                              ],
                            ),
                            // Scrollable Remaining Columns
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Row(
                                  children: [
                                    _buildColumn([
                                      for (var d in _updateController.getdata)
                                        d.two
                                    ]),
                                    _buildColumn([
                                      for (var d in _updateController.getdata)
                                        d.three
                                    ]),
                                    _buildColumn([
                                      for (var d in _updateController.getdata)
                                        d.four
                                    ]),
                                    _buildColumn([
                                      for (var d in _updateController.getdata)
                                        d.five
                                    ]),
                                    _buildColumn([
                                      for (var d in _updateController.getdata)
                                        d.six
                                    ]),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget _buildColumn(List<String> data) {
    return Column(
      children: [
        for (int i = 0; i < data.length; i++)
          _buildDataContainer(
            i: i,
            title: data[i],
            isHeader: i == 0,
          ),
      ],
    );
  }

  Widget _buildDataContainer({
    required int i,
    required String title,
    bool isFirstColumn = false,
    bool isHeader = false,
  }) {
    final bool isEven = i % 2 == 0;

    return Container(
      height: 52, // Guaranteed uniform height for alignment
      width: isFirstColumn ? 140 : 110, // Consistent column widths
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isHeader
            ? primaryBlue.withOpacity(0.08)
            : isEven
                ? Colors.transparent
                : backgroundGray.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE5E5EA),
            width: 0.5,
          ),
          right: BorderSide(
            color: const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isHeader
              ? FontWeight.bold
              : (isFirstColumn ? FontWeight.w600 : FontWeight.w500),
          fontSize: isHeader ? 12.5 : 12,
          fontFamily: isHeader ? "SF Pro Display" : "SF Pro Text",
          letterSpacing: -0.2,
          color: isHeader
              ? primaryBlue
              : isFirstColumn
                  ? textPrimary
                  : textPrimary.withOpacity(0.8),
        ),
      ),
    );
  }
}


