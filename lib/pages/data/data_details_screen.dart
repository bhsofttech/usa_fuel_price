import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../controller/google_ads_controller.dart';
import '../../controller/update_controller.dart';

class DataDetailsScreen extends StatefulWidget {
  final String endPoint;
  final String title;
  const DataDetailsScreen({
    super.key,
    required this.endPoint,
    required this.title,
  });

  @override
  State<DataDetailsScreen> createState() => _DataDetailsScreenState();
}

class _DataDetailsScreenState extends State<DataDetailsScreen>
    with TickerProviderStateMixin {
  final UpdateController _updateController = Get.find();
  final GoogleAdsController _googleAdsController = Get.find();
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  // Modern iOS color palette matching gas_state_wise_price.dart
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);
  final Color successGreen = const Color(0xFF34C759);
  final Color warningOrange = const Color(0xFFFF9500);
  final Color errorRed = const Color(0xFFFF3B30);
  final Color purpleAccent = const Color(0xFFAF52DE);

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? current_date;

  @override
  void initState() {
    super.initState();
    current_date = DateTime.now();

    // Initialize animations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    callApi();
    _googleAdsController.showAds();
    analytics.setCurrentScreen(screenName: widget.title);

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> callApi() async {
    await _updateController.getData(widget.endPoint);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: _buildModernAppBar(),
      body: SafeArea(
        child: Obx(
          () {
            return _updateController.showDataLoading.value
                ? _buildLoadingView()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildMainContent(),
                    ),
                  );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      leadingWidth: 50,
      backgroundColor: cardWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Text(
            widget.title.toUpperCase(),
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      iconTheme: IconThemeData(color: primaryBlue),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          color: cardWhite,
          border: Border(
            bottom: BorderSide(
              color: separatorGray,
              width: 0.33,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: primaryBlue,
            size: 45.0,
          ),
          const SizedBox(height: 16),
          Text(
            "Fetching ${widget.title}",
            style: TextStyle(
              color: textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: "SF Pro Text",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderStats(),
          const SizedBox(height: 16.0),
          Expanded(
            child: _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryBlue.withOpacity(0.08),
            lightBlue.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: primaryBlue.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bar_chart,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: textPrimary,
                    fontFamily: "SF Pro Display",
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_updateController.getdata.length} records available",
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    if (_updateController.getdata.isEmpty) {
      return _buildEmptyState();
    }

    // Dynamic column generation based on data keys
    final sampleItem = _updateController.getdata.first;
    final columns = sampleItem.toJson().keys.map((key) {
      return DataColumn(
        label: Text(
          key.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: textPrimary,
            fontFamily: "SF Pro Display",
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.08,
          ),
        ),
        tooltip: key.replaceAll('_', ' '),
      );
    }).toList();

    // Fixed first column width
    const double firstColumnWidth = 120.0;

    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed first column with enhanced styling
              Container(
                width: firstColumnWidth,
                decoration: BoxDecoration(
                  color: cardWhite,
                  border: Border(
                    right: BorderSide(
                      color: separatorGray.withOpacity(0.5),
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
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            backgroundGray,
                            backgroundGray.withOpacity(0.7),
                          ],
                        ),
                        border: Border(
                          bottom: BorderSide(
                            color: separatorGray.withOpacity(0.5),
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Text(
                        columns[0]
                            .label
                            .toString()
                            .replaceAll('Text("', '')
                            .replaceAll('")', ''),
                        style: TextStyle(
                          color: textPrimary,
                          fontFamily: "SF Pro Display",
                          fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.08,
                        ),
                        textAlign: TextAlign.center,
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
                            color: index.isEven
                                ? cardWhite
                                : backgroundGray.withOpacity(0.5),
                            border: Border(
                              bottom: BorderSide(
                                color: separatorGray.withOpacity(0.5),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              value?.toString() ?? '',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Text",
                                fontSize: 13.0,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.08,
                              ),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
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
                      backgroundGray,
                    ),
                    headingTextStyle: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Display",
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.08,
                    ),
                    dataTextStyle: TextStyle(
                      color: textPrimary,
                      fontFamily: "SF Pro Text",
                      fontSize: 13.0,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.08,
                    ),
                    columnSpacing: 24,
                    horizontalMargin: 16,
                    headingRowHeight: 50,
                    dataRowHeight: 48,
                    dividerThickness: 0.5,
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: separatorGray.withOpacity(0.5),
                        width: 0.5,
                      ),
                    ),
                    columns: columns.sublist(1), // Exclude first column
                    rows:
                        _updateController.getdata.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return DataRow(
                        color: MaterialStateProperty.all(
                          index.isEven
                              ? cardWhite
                              : backgroundGray.withOpacity(0.5),
                        ),
                        cells: item.toJson().values.skip(1).map((value) {
                          return DataCell(
                            Text(
                              value?.toString() ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            onTap: () => _showCellDialog(
                              context,
                              item,
                              item.toJson().values.toList().indexOf(value),
                            ),
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
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: cardWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 25,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: backgroundGray,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.inbox_outlined,
                color: textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "No Data Available",
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontFamily: "SF Pro Display",
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "There's no data to display at the moment.",
              style: TextStyle(
                color: textSecondary,
                fontSize: 15,
                fontFamily: "SF Pro Text",
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showCellDialog(BuildContext context, dynamic item, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        title: Text(
          item
              .toJson()
              .keys
              .elementAt(index)
              .replaceAll('_', ' ')
              .toUpperCase(),
          style: TextStyle(
            color: textPrimary,
            fontFamily: "SF Pro Display",
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.41,
          ),
        ),
        content: Container(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Text(
            item.toJson().values.elementAt(index)?.toString() ?? '',
            style: TextStyle(
              color: textPrimary,
              fontFamily: "SF Pro Text",
              fontSize: 15,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.24,
              height: 1.4,
            ),
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryBlue, lightBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "SF Pro Text",
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginatedDataTable() {
    if (_updateController.getdata.isEmpty) {
      return _buildDataTable(); // Fallback to regular table for empty data
    }

    final sampleItem = _updateController.getdata.first;
    final columns = sampleItem.toJson().keys.map((key) {
      return DataColumn(
        label: Text(
          key.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: textPrimary,
            fontFamily: "SF Pro Display",
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.08,
          ),
        ),
        tooltip: key.replaceAll('_', ' '),
      );
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: PaginatedDataTable(
          header: Text(
            widget.title,
            style: TextStyle(
              color: textPrimary,
              fontFamily: "SF Pro Display",
              fontSize: 17.0,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.41,
            ),
          ),
          headingRowColor: MaterialStateProperty.all(
            backgroundGray,
          ),
          columnSpacing: 24,
          horizontalMargin: 16,
          rowsPerPage: 10,
          showCheckboxColumn: false,
          dataRowHeight: 48,
          headingRowHeight: 50,
          columns: columns,
          source: _DataTableSource(_updateController.getdata, textPrimary),
        ),
      ),
    );
  }
}

class _DataTableSource extends DataTableSource {
  final List<dynamic> data;
  final Color textColor;

  _DataTableSource(this.data, this.textColor);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;

    final item = data[index];
    return DataRow(
      color: MaterialStateProperty.all(
        index.isEven ? Colors.white : Colors.grey.withOpacity(0.5),
      ),
      cells: item.toJson().values.map((value) {
        return DataCell(
          Text(
            value?.toString() ?? '',
            style: TextStyle(
              color: textColor,
              fontFamily: "SF Pro Text",
              fontSize: 13.0,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.08,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        );
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

// Extension to capitalize strings
extension StringExtension on String {
  String get capitalize {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
