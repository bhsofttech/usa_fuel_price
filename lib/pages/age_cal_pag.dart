import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class AgeCalculatorScreen extends StatefulWidget {
  const AgeCalculatorScreen({
    super.key,
  });

  @override
  _AgeCalculatorScreenState createState() => _AgeCalculatorScreenState();
}

class _AgeCalculatorScreenState extends State<AgeCalculatorScreen> {
  DateTime? _birthDate;
  DateTime? _selectedDate;
  String _ageResult = '';
  String _nextBirthday = '';
  String _zodiacSign = '';
  String _birthstone = '';
  String _birthSeason = '';
  double _lifePercentage = 0.0;
  List<String> _calculationHistory = [];
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _selectedDateController = TextEditingController();

  // Modern iOS color palette matching gas_state_wise_price.dart and others
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);
  final Color separatorGray = const Color(0xFFD1D1D6);
  final Color primaryOrange = const Color(0xFFF47D4E); // Retained from original

  final List<String> _zodiacSigns = [
    'Capricorn',
    'Aquarius',
    'Pisces',
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius'
  ];

  final List<String> _birthstones = [
    'Garnet',
    'Amethyst',
    'Aquamarine',
    'Diamond',
    'Emerald',
    'Pearl/Alexandrite',
    'Ruby',
    'Peridot',
    'Sapphire',
    'Opal/Tourmaline',
    'Topaz/Citrine',
    'Turquoise/Zircon'
  ];

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    analytics.logScreenView(screenName: "Age Calculator");
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calculationHistory = prefs.getStringList('calculationHistory') ?? [];
    });
  }

  Future<void> _saveCalculation(String calculation) async {
    final prefs = await SharedPreferences.getInstance();
    _calculationHistory.insert(0, calculation);
    if (_calculationHistory.length > 10) {
      _calculationHistory = _calculationHistory.sublist(0, 10);
    }
    await prefs.setStringList('calculationHistory', _calculationHistory);
    setState(() {});
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _calculationHistory = [];
    });
    await prefs.setStringList('calculationHistory', _calculationHistory);
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: cardWhite,
              headerBackgroundColor: primaryBlue,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 18, // Reduced font size
                fontWeight: FontWeight.w600,
                fontFamily: "SF Pro Display",
                letterSpacing: -0.3,
              ),
              dayStyle: TextStyle(
                fontFamily: "SF Pro Text",
                color: textPrimary,
                fontSize: 13, // Reduced font size
                fontWeight: FontWeight.w400,
                letterSpacing: -0.24,
              ),
              todayBackgroundColor:
                  MaterialStateProperty.all(primaryBlue.withOpacity(0.12)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Smaller radius
              ),
              cancelButtonStyle: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                textStyle: const TextStyle(
                  fontFamily: "SF Pro Text",
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
              confirmButtonStyle: TextButton.styleFrom(
                foregroundColor: primaryBlue,
                textStyle: const TextStyle(
                  fontFamily: "SF Pro Text",
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.41,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
          _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
          _calculateZodiacAndBirthstone(picked);
          _calculateBirthSeason(picked);
        } else {
          _selectedDate = picked;
          _selectedDateController.text =
              DateFormat('yyyy-MM-dd').format(picked);
        }
        _calculateAge();
      });
    }
  }

  void _calculateAge() {
    if (_birthDate == null) return;

    final targetDate = _selectedDate ?? DateTime.now();
    final birthDate = _birthDate!;

    if (targetDate.isBefore(birthDate)) {
      setState(() {
        _ageResult = 'Error: Comparison date cannot be before birth date.';
        _nextBirthday = '';
        _zodiacSign = '';
        _birthstone = '';
        _birthSeason = '';
        _lifePercentage = 0.0;
      });
      return;
    }

    int years = targetDate.year - birthDate.year;
    int months = targetDate.month - birthDate.month;
    int days = targetDate.day - birthDate.day;

    if (days < 0) {
      months--;
      final lastMonth = DateTime(targetDate.year, targetDate.month, 0);
      days += lastMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final totalDays = targetDate.difference(birthDate).inDays;
    final totalHours = targetDate.difference(birthDate).inHours;
    final totalMinutes = targetDate.difference(birthDate).inMinutes;
    final totalSeconds = targetDate.difference(birthDate).inSeconds;
    final totalWeeks = totalDays ~/ 7;
    final totalMonths = ((targetDate.year - birthDate.year) * 12) +
        (targetDate.month - birthDate.month);

    DateTime nextBirthday =
        DateTime(targetDate.year, birthDate.month, birthDate.day);
    if (nextBirthday.isBefore(targetDate) || nextBirthday == targetDate) {
      nextBirthday =
          DateTime(targetDate.year + 1, birthDate.month, birthDate.day);
    }
    final daysUntilBirthday = nextBirthday.difference(targetDate).inDays;

    final lifePercentage = (totalDays / (90 * 365)) * 100;

    final calculationResult = '''
Birth Date: ${DateFormat('MMMM d, y').format(birthDate)}
Target Date: ${DateFormat('MMMM d, y').format(targetDate)}
Age: $years years, $months months, $days days
Total: $totalMonths months | $totalWeeks weeks | $totalDays days
Time: $totalHours hours | $totalMinutes minutes | $totalSeconds seconds
Next Birthday: ${DateFormat('MMMM d, y').format(nextBirthday)} (in $daysUntilBirthday days)
Zodiac: $_zodiacSign
Birthstone: $_birthstone
Season: $_birthSeason
Life Progress: ${lifePercentage.toStringAsFixed(2)}% of 90 years
''';

    _saveCalculation(calculationResult);

    setState(() {
      _ageResult = '''
Age: 
$years years, $months months, $days days

Total:
$totalMonths months
$totalWeeks weeks
$totalDays days
$totalHours hours
$totalMinutes minutes
$totalSeconds seconds
''';

      _nextBirthday = '''
Next Birthday: 
${DateFormat('MMMM d, y').format(nextBirthday)}
In $daysUntilBirthday days
''';
      _lifePercentage = lifePercentage;
    });
  }

  void _calculateZodiacAndBirthstone(DateTime birthDate) {
    final day = birthDate.day;
    final month = birthDate.month;

    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      _zodiacSign = _zodiacSigns[0];
      _birthstone = _birthstones[0];
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      _zodiacSign = _zodiacSigns[1];
      _birthstone = _birthstones[1];
    } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      _zodiacSign = _zodiacSigns[2];
      _birthstone = _birthstones[2];
    } else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      _zodiacSign = _zodiacSigns[3];
      _birthstone = _birthstones[3];
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      _zodiacSign = _zodiacSigns[4];
      _birthstone = _birthstones[4];
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      _zodiacSign = _zodiacSigns[5];
      _birthstone = _birthstones[5];
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      _zodiacSign = _zodiacSigns[6];
      _birthstone = _birthstones[6];
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      _zodiacSign = _zodiacSigns[7];
      _birthstone = _birthstones[7];
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      _zodiacSign = _zodiacSigns[8];
      _birthstone = _birthstones[8];
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      _zodiacSign = _zodiacSigns[9];
      _birthstone = _birthstones[9];
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      _zodiacSign = _zodiacSigns[10];
      _birthstone = _birthstones[10];
    } else {
      _zodiacSign = _zodiacSigns[11];
      _birthstone = _birthstones[11];
    }
  }

  void _calculateBirthSeason(DateTime birthDate) {
    final day = birthDate.day;
    final month = birthDate.month;

    if ((month == 12 && day >= 21) ||
        (month == 1) ||
        (month == 2) ||
        (month == 3 && day <= 20)) {
      _birthSeason = 'Winter';
    } else if ((month == 3 && day >= 21) ||
        (month == 4) ||
        (month == 5) ||
        (month == 6 && day <= 20)) {
      _birthSeason = 'Spring';
    } else if ((month == 6 && day >= 21) ||
        (month == 7) ||
        (month == 8) ||
        (month == 9 && day <= 22)) {
      _birthSeason = 'Summer';
    } else {
      _birthSeason = 'Autumn';
    }
  }

  void _resetCalculator() {
    setState(() {
      _birthDate = null;
      _selectedDate = null;
      _ageResult = '';
      _nextBirthday = '';
      _zodiacSign = '';
      _birthstone = '';
      _birthSeason = '';
      _lifePercentage = 0.0;
      _birthDateController.clear();
      _selectedDateController.clear();
    });
    Get.find<GoogleAdsController>().showAds();
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Smaller radius
        ),
        title: Text(
          'Calculation History',
          style: TextStyle(
            color: textPrimary,
            fontFamily: "SF Pro Display",
            fontSize: 18, // Reduced font size
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: _calculationHistory.isEmpty
              ? Text(
                  'No history available.',
                  style: TextStyle(
                    color: textSecondary,
                    fontFamily: "SF Pro Text",
                    fontSize: 13, // Reduced font size
                    fontWeight: FontWeight.w400,
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _calculationHistory.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8), // Reduced separator
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.all(10), // Reduced padding
                      decoration: BoxDecoration(
                        color: cardWhite,
                        borderRadius: BorderRadius.circular(10), // Smaller radius
                        border: Border.all(
                          color: separatorGray.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        _calculationHistory[index],
                        style: TextStyle(
                          color: textPrimary,
                          fontFamily: "SF Pro Text",
                          fontSize: 12, // Consistent font size
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (_calculationHistory.isNotEmpty)
            TextButton(
              onPressed: () {
                _clearHistory();
                Navigator.pop(context);
              },
              child: Text(
                'Clear History',
                style: TextStyle(
                  color: primaryBlue,
                  fontFamily: "SF Pro Text",
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: primaryBlue,
                fontFamily: "SF Pro Text",
                fontSize: 16, // Reduced font size
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: cardWhite,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        centerTitle: true,
        title: Text(
          "Age Calculator",
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 16.0, // Reduced font size
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
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
        actions: [
          _calculationHistory.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.history,
                    color: primaryBlue,
                    size: 20, // Smaller icon
                  ),
                  tooltip: 'View History',
                  onPressed: _showHistoryDialog,
                )
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Balanced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16), // Reduced padding
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), // Smaller radius
                  color: cardWhite,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12, // Reduced blur
                      spreadRadius: 0,
                      offset: const Offset(0, 2), // Smaller offset
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Birth Date',
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Display",
                        fontSize: 18.0, // Reduced font size
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    TextField(
                      controller: _birthDateController,
                      onTap: () => _selectDate(context, true),
                      decoration: InputDecoration(
                        hintText: 'Select Birth Date',
                        hintStyle: TextStyle(
                          color: textSecondary,
                          fontFamily: "SF Pro Text",
                          fontSize: 13.0, // Reduced font size
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: separatorGray.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: separatorGray.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryBlue,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: backgroundGray,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12), // Reduced padding
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: primaryBlue.withOpacity(0.5),
                          size: 18, // Smaller icon
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.0, // Reduced font size
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                    Text(
                      'Compare With Date (Optional)',
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Display",
                        fontSize: 18.0, // Reduced font size
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    TextField(
                      controller: _selectedDateController,
                      onTap: () => _selectDate(context, false),
                      decoration: InputDecoration(
                        hintText: 'Select Date to Compare',
                        hintStyle: TextStyle(
                          color: textSecondary,
                          fontFamily: "SF Pro Text",
                          fontSize: 13.0, // Reduced font size
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: separatorGray.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: separatorGray.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryBlue,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: backgroundGray,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12), // Reduced padding
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: primaryBlue.withOpacity(0.5),
                          size: 18, // Smaller icon
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: textPrimary,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.0, // Reduced font size
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Reduced spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.calculate,
                      color: cardWhite,
                      size: 18, // Smaller icon
                    ),
                    label: Text(
                      'Calculate',
                      style: TextStyle(
                        color: cardWhite,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.0, // Reduced font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _birthDate != null ? _calculateAge : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, // Reduced padding
                        vertical: 12, // Reduced padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(width: 12), // Reduced spacing
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.refresh,
                      color: primaryBlue,
                      size: 18, // Smaller icon
                    ),
                    label: Text(
                      'Reset',
                      style: TextStyle(
                        color: primaryBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 13.0, // Reduced font size
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _resetCalculator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, // Reduced padding
                        vertical: 12, // Reduced padding
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: primaryBlue,
                          width: 0.5,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Reduced spacing
              if (_ageResult.isNotEmpty ||
                  _nextBirthday.isNotEmpty ||
                  _zodiacSign.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16), // Reduced padding
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Smaller radius
                    color: cardWhite,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12, // Reduced blur
                        spreadRadius: 0,
                        offset: const Offset(0, 2), // Smaller offset
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_ageResult.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Age Calculation',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Display",
                                fontSize: 18.0, // Reduced font size
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            Text(
                              _ageResult,
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Text",
                                fontSize: 13.0, // Reduced font size
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(
                              height: 16, // Reduced height
                              thickness: 0.5,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      if (_nextBirthday.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Birthday Information',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Display",
                                fontSize: 18.0, // Reduced font size
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            Text(
                              _nextBirthday,
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Text",
                                fontSize: 13.0, // Reduced font size
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(
                              height: 16, // Reduced height
                              thickness: 0.5,
                                color: Colors.grey
                            ),
                          ],
                        ),
                      if (_zodiacSign.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Astrological Information',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Display",
                                fontSize: 18.0, // Reduced font size
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            Text(
                              'Zodiac: $_zodiacSign\nBirthstone: $_birthstone\nSeason: $_birthSeason',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Text",
                                fontSize: 13.0, // Reduced font size
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(
                              height: 16, // Reduced height
                              thickness: 0.5,
                                color: Colors.grey
                            ),
                          ],
                        ),
                      if (_lifePercentage > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Life Progress',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Display",
                                fontSize: 18.0, // Reduced font size
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            Text(
                              '${_lifePercentage.toStringAsFixed(2)}% of 90 years lived',
                              style: TextStyle(
                                color: textPrimary,
                                fontFamily: "SF Pro Text",
                                fontSize: 13.0, // Reduced font size
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8), // Reduced spacing
                            LinearProgressIndicator(
                              value: _lifePercentage / 100,
                              backgroundColor: separatorGray,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryBlue,
                              ),
                              minHeight: 6, // Reduced height
                              borderRadius: BorderRadius.circular(3), // Smaller radius
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _selectedDateController.dispose();
    super.dispose();
  }
}