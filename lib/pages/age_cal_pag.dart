import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
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

  final Color primaryOrange = const Color(0xffF47D4E);
  final Color darkBlue = const Color(0xFF0A4B9A);

  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    Get.find<GoogleAdsController>().showAds();
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
            colorScheme: ColorScheme.light(
              primary: primaryOrange,
              onPrimary: Colors.white,
              onSurface: darkBlue,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: primaryOrange,
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
Zodiac: $_zodiacSign testo
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
        title: const Text('Calculation History'),
        content: SizedBox(
          width: double.maxFinite,
          child: _calculationHistory.isEmpty
              ? const Text('No history available.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _calculationHistory.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _calculationHistory[index],
                          style: const TextStyle(fontSize: 12),
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
              child: const Text('Clear History'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leadingWidth: 50,
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          "Age Calculator".toUpperCase(),
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
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
        actions: [
          _calculationHistory.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.history,
                    color: darkBlue,
                  ),
                  tooltip: 'View History',
                  onPressed: _calculationHistory.isNotEmpty
                      ? _showHistoryDialog
                      : null,
                )
              : const SizedBox(),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Birth Date',
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _birthDateController,
                      onTap: () => _selectDate(context, true),
                      decoration: InputDecoration(
                        hintText: 'Select Birth Date',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "SF Pro Text",
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: darkBlue.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Compare With Date (Optional)',
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _selectedDateController,
                      onTap: () => _selectDate(context, false),
                      decoration: InputDecoration(
                        hintText: 'Select Date to Compare',
                        hintStyle: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontFamily: "SF Pro Text",
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: primaryOrange,
                            width: 1,
                          ),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F7),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: darkBlue.withOpacity(0.5),
                          size: 20,
                        ),
                      ),
                      readOnly: true,
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Text",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.calculate,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Calculate',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "SF Pro Text",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: _birthDate != null ? _calculateAge : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.refresh,
                      color: primaryOrange,
                    ),
                    label: Text(
                      'Reset',
                      style: TextStyle(
                        color: primaryOrange,
                        fontFamily: "SF Pro Text",
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: _resetCalculator,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: primaryOrange,
                          width: 1,
                        ),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_ageResult.isNotEmpty ||
                  _nextBirthday.isNotEmpty ||
                  _zodiacSign.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
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
                                color: darkBlue,
                                fontFamily: "SF Pro Text",
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _ageResult,
                              style: TextStyle(
                                color: darkBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(
                              height: 24,
                              thickness: 0.5,
                              color: Color(0xFFD1D1D6),
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
                                color: darkBlue,
                                fontFamily: "SF Pro Text",
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _nextBirthday,
                              style: TextStyle(
                                color: darkBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Divider(
                              height: 24,
                              thickness: 0.5,
                              color: Color(0xFFD1D1D6),
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
                                color: darkBlue,
                                fontFamily: "SF Pro Text",
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${_lifePercentage.toStringAsFixed(2)}% of 90 years lived',
                              style: TextStyle(
                                color: darkBlue.withOpacity(0.8),
                                fontFamily: "SF Pro Text",
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: _lifePercentage / 100,
                              backgroundColor: const Color(0xFFD1D1D6),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                primaryOrange,
                              ),
                              minHeight: 8,
                              borderRadius: BorderRadius.circular(4),
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
