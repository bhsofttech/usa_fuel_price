import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

import 'car_detail_screen.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  _CarListScreenState createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen>
    with TickerProviderStateMixin {
  List<Car> cars = [];
  bool isLoading = false;
  String errorMessage = '';

  final Color primaryBlue = const Color(0xFF007AFF);
  final Color lightBlue = const Color(0xFF4DA6FF);
  final Color backgroundGray = const Color(0xFFF2F2F7);
  final Color cardWhite = const Color(0xFFFFFFFF);
  final Color textPrimary = const Color(0xFF1C1C1E);
  final Color textSecondary = const Color(0xFF8E8E93);

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    fetchCars();
    _animationController.forward();
  }

  Future<void> fetchCars() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final url =
        'https://ev-database.org/#group=vehicle-group&rs-pr=10000_100000&rs-er=0_1000&rs-ld=0_1000&rs-ac=2_23&rs-dcfc=0_300&rs-ub=10_200&rs-tw=0_2500&rs-ef=100_350&rs-sa=-1_5&rs-w=1000_3500&rs-c=0_5000&rs-y=2010_2030&s=1&p=1-10';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final carElements = document.getElementsByClassName('list-item');

        List<Car> fetchedCars = [];
        for (var element in carElements) {
          final name = element.querySelector('.title')?.text.trim() ?? 'N/A';
          final price = element.querySelector('.price')?.text.trim() ?? 'N/A';
          final range =
              element.querySelector('.erange_real')?.text.trim() ?? 'N/A';
          final efficiency =
              element.querySelector('.efficiency')?.text.trim() ?? 'N/A';
          final weight = element.querySelector('.weight')?.text.trim() ?? 'N/A';
          final fastcharge =
              element.querySelector('.fastcharge_speed_print')?.text.trim() ??
                  'N/A';
          final towing =
              element.querySelector('.towweight_p')?.text.trim() ?? 'N/A';
          final cargoVolume =
              element.querySelector('.cargo')?.text.trim() ?? 'N/A';
          final pricePerRange =
              element.querySelector('.price-per-range')?.text.trim() ?? 'N/A';
          final imageUrl =
              element.querySelector('img')?.attributes['src'] ?? 'N/A';
          final zeroTO100Speed =
              element.querySelector('.acceleration_p')?.text.trim() ?? 'N/A';
          final firstStop =
              element.querySelector('.long_distance_total')?.text.trim() ??
                  'N/A';
          final priceInGe =
              element.querySelector('.country_de')?.text.trim() ?? 'N/A';
          final priceInFr =
              element.querySelector('.country_nl')?.text.trim() ?? 'N/A';
          final priceInUK =
              element.querySelector('.country_uk')?.text.trim() ?? 'N/A';

          fetchedCars.add(Car(
              name: name,
              price: price,
              range: range,
              efficiency: efficiency,
              weight: weight,
              fastcharge: fastcharge,
              towing: towing,
              cargoVolume: cargoVolume,
              pricePerRange: pricePerRange,
              imageUrl: imageUrl,
              firstStop: firstStop,
              zeroTO100Speed: zeroTO100Speed,
              priceInGe: priceInGe,
              priceInFr: priceInFr,
              priceInUK: priceInUK));
        }

        setState(() {
          cars = fetchedCars;
          isLoading = false;
        });

        if (fetchedCars.isEmpty) {
          setState(() {
            errorMessage =
                'No cars found. Check .list-item selector or website structure.';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to load page: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error fetching data: $e';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          leadingWidth: 50,
          backgroundColor: cardWhite.withOpacity(0.95),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          centerTitle: true,
          title: Text(
            "ELECTRIC VEHICLES".toUpperCase(),
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: primaryBlue),
            onPressed: () => Navigator.of(context).pop(),
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Available Electric Vehicles",
                style: TextStyle(
                  color: primaryBlue.withOpacity(0.8),
                  fontFamily: "SF Pro Text",
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 12),
              _buildHeaderStats(),
              const SizedBox(height: 12),
              isLoading && cars.isEmpty
                  ? _buildLoadingState()
                  : errorMessage.isNotEmpty
                      ? _buildErrorState()
                      : FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildCarList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: primaryBlue,
          ),
          const SizedBox(height: 12),
          Text(
            "Fetching Electric Vehicles",
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Loading vehicle data...",
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 12,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: textSecondary,
            size: 24,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            style: TextStyle(
              fontFamily: 'SF Pro Display',
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(
                colors: [lightBlue, primaryBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.directions_car,
              color: cardWhite,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Electric Vehicles",
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${cars.length} vehicles available",
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 12,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                  0, (1 - _animationController.value) * 20 * (index + 1)),
              child: Opacity(
                opacity: _animationController.value,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCarCard(index),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCarCard(int index) {
    final car = cars[index];
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _scaleController.forward();
      },
      onTapUp: (_) {
        _scaleController.reverse();
        Get.to(
          () => CarDetailsScreen(car: car),
        );
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.all(12),
          // Increased height to accommodate vertical layout
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              car.imageUrl.isNotEmpty && car.imageUrl != 'N/A'
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "https://ev-database.org/${car.imageUrl}",
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: backgroundGray,
                          child: Icon(
                            Icons.directions_car,
                            color: textSecondary,
                            size: 40,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: backgroundGray,
                      child: Icon(
                        Icons.directions_car,
                        color: textSecondary,
                        size: 40,
                      ),
                    ),
              const SizedBox(height: 8), // Space between image and text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  car.name,
                  style: TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 15.0,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Car {
  final String name;
  final String price;
  final String range;
  final String efficiency;
  final String weight;
  final String fastcharge;
  final String towing;
  final String cargoVolume;
  final String pricePerRange;
  final String imageUrl;
  final String zeroTO100Speed;
  final String firstStop;
  final String priceInGe;
  final String priceInFr;
  final String priceInUK;

  Car({
    required this.name,
    required this.price,
    required this.range,
    required this.efficiency,
    required this.weight,
    required this.fastcharge,
    required this.towing,
    required this.cargoVolume,
    required this.pricePerRange,
    required this.imageUrl,
    required this.firstStop,
    required this.zeroTO100Speed,
    required this.priceInGe,
    required this.priceInFr,
    required this.priceInUK,
  });
}
