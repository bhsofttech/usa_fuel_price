import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class VehicleScreen extends StatefulWidget {
  @override
  _VehicleScreenState createState() => _VehicleScreenState();
}

class _VehicleScreenState extends State<VehicleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<Database>? _dbFuture;
  final Color primaryBlue = const Color(0xFF007AFF); // iOS system blue
  final Color darkBlue = const Color(0xFF0A4B9A); // Darker blue variant

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _dbFuture = initDb();
  }

  Future<Database> initDb() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'vehicle_system.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            '''CREATE TABLE settings(key TEXT PRIMARY KEY, value TEXT)''');
        await db.execute(
            '''CREATE TABLE vehicles(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, brand TEXT, model TEXT, year TEXT, plateNo TEXT, fuelType TEXT, odometer REAL)''');
        await db.execute(
            '''CREATE TABLE fuel_logs(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, date TEXT, volume REAL, cost REAL, odometer REAL, FOREIGN KEY(vehicleId) REFERENCES vehicles(id))''');
        await db.execute(
            '''CREATE TABLE expenses(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, date TEXT, category TEXT, description TEXT, cost REAL, FOREIGN KEY(vehicleId) REFERENCES vehicles(id))''');
        await db.execute(
            '''CREATE TABLE maintenance(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, date TEXT, taskType TEXT, description TEXT, cost REAL, FOREIGN KEY(vehicleId) REFERENCES vehicles(id))''');
        await db.execute(
            '''CREATE TABLE trips(id INTEGER PRIMARY KEY AUTOINCREMENT, vehicleId INTEGER, startDate TEXT, endDate TEXT, distance REAL, notes TEXT, FOREIGN KEY(vehicleId) REFERENCES vehicles(id))''');
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Database>(
      future: _dbFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F7),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SpinKitFadingCircle(
                    color: primaryBlue,
                    size: 40.0,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Loading Vehicle Data...",
                    style: TextStyle(
                      color: darkBlue.withOpacity(0.8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: "SF Pro Text",
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final db = snapshot.data!;
        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F7),
          appBar: AppBar(
            leadingWidth: 50,
            backgroundColor: Colors.white,
            elevation: 0.5,
            centerTitle: true,
            title: Text(
              "Vehicle Trip System".toUpperCase(),
              style: TextStyle(
                color: primaryBlue,
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
            bottom: TabBar(
              controller: _tabController,
              onTap: (_) {
                Get.find<GoogleAdsController>().showAds();
                setState(() {});
              },
              isScrollable: true,
              indicatorColor: primaryBlue,
              labelColor: primaryBlue,
              unselectedLabelColor: Color(0xFF8E8E93),
              labelStyle: const TextStyle(
                fontFamily: "SF Pro Text",
                fontWeight: FontWeight.w600,
                fontSize: 14.0,
              ),
              tabs: [
                Tab(text: "Vehicles"),
                Tab(text: "Fuel Logs"),
                Tab(text: "Expenses"),
                Tab(text: "Maintenance"),
                Tab(text: "Trips"),
                Tab(text: "Reports"),
                Tab(text: "Settings"),
              ],
            ),
          ),
          body: SafeArea(
            child: Container(
              color: const Color(0xFFF2F2F7),
              child: TabBarView(
                physics: NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  VehiclesTab(db: db),
                  FuelLogsTab(db: db),
                  ExpensesTab(db: db),
                  MaintenanceTab(db: db),
                  TripsTab(db: db),
                  ReportsTab(db: db),
                  SettingsTab(db: db),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🚗 VEHICLES TAB

class VehiclesTab extends StatefulWidget {
  final Database db;
  VehiclesTab({required this.db});

  @override
  _VehiclesTabState createState() => _VehiclesTabState();
}

class _VehiclesTabState extends State<VehiclesTab> {
  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() => isLoading = true);
    final data = await widget.db.query('vehicles');
    setState(() {
      vehicles = data;
      isLoading = false;
    });
  }

  Future<void> showVehicleDialog(
      {Map<String, dynamic>? vehicle, required BuildContext context}) async {
    final nameController = TextEditingController(text: vehicle?['name'] ?? '');
    final typeController = TextEditingController(text: vehicle?['type'] ?? '');
    final brandController =
        TextEditingController(text: vehicle?['brand'] ?? '');
    final modelController =
        TextEditingController(text: vehicle?['model'] ?? '');
    final yearController = TextEditingController(text: vehicle?['year'] ?? '');
    final plateController =
        TextEditingController(text: vehicle?['plateNo'] ?? '');
    final fuelController =
        TextEditingController(text: vehicle?['fuelType'] ?? '');
    final odometerController =
        TextEditingController(text: vehicle?['odometer']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Name is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: typeController,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Type is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: brandController,
                  decoration: InputDecoration(
                    labelText: 'Brand',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Brand is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: modelController,
                  decoration: InputDecoration(
                    labelText: 'Model',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Model is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) {
                    if (value!.isEmpty) return 'Year is required';
                    final year = int.tryParse(value);
                    if (year == null ||
                        year < 1900 ||
                        year > DateTime.now().year) {
                      return 'Enter a valid year';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: plateController,
                  decoration: InputDecoration(
                    labelText: 'Plate No',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Plate No is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: fuelController,
                  decoration: InputDecoration(
                    labelText: 'Fuel Type',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  validator: (value) =>
                      value!.isEmpty ? 'Fuel Type is required' : null,
                ),
                SizedBox(height: 12),
                TextFormField(
                  controller: odometerController,
                  decoration: InputDecoration(
                    labelText: 'Odometer',
                    labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                    filled: true,
                    fillColor: Color(0xFFF2F2F7),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(color: darkBlue),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) return 'Odometer is required';
                    final odometer = double.tryParse(value);
                    if (odometer == null || odometer < 0) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final data = {
                  'name': nameController.text,
                  'type': typeController.text,
                  'brand': brandController.text,
                  'model': modelController.text,
                  'year': yearController.text,
                  'plateNo': plateController.text,
                  'fuelType': fuelController.text,
                  'odometer': double.parse(odometerController.text),
                };
                if (vehicle == null) {
                  await widget.db.insert('vehicles', data);
                } else {
                  await widget.db.update('vehicles', data,
                      where: 'id = ?', whereArgs: [vehicle['id']]);
                }
                fetchVehicles();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteVehicle(int id, BuildContext context) async {
    await widget.db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
    fetchVehicles();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vehicle deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      {required int id,
      required String name,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Vehicle',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$name"? This action cannot be undone.',
          style: TextStyle(color: darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              deleteVehicle(id, context);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: isLoading
          ? SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: primaryBlue,
                      size: 40.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Loading Vehicles...",
                      style: TextStyle(
                        color: darkBlue.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                  ],
                ),
              ),
            )
          : vehicles.isEmpty
              ? SafeArea(
                  child: Center(
                    child: Text(
                      "No vehicles added yet.",
                      style: TextStyle(
                        color: darkBlue.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    itemCount: vehicles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final v = vehicles[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () =>
                            showVehicleDialog(vehicle: v, context: context),
                        child: Container(
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      v['name'],
                                      style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: "SF Pro Text",
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: primaryBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.edit,
                                          color: primaryBlue,
                                          size: 20,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red, size: 20),
                                        onPressed: () =>
                                            showDeleteConfirmationDialog(
                                                id: v['id'],
                                                name: v['name'],
                                                context: context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFFF2F2F7),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildInfo(
                                      title: "Type",
                                      value: v['type'],
                                      color: primaryBlue,
                                    ),
                                    buildInfo(
                                      title: "Brand",
                                      value: v['brand'],
                                      color: primaryBlue,
                                    ),
                                    buildInfo(
                                      title: "Model",
                                      value: v['model'],
                                      color: primaryBlue,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => showVehicleDialog(context: context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontFamily: "SF Pro Text",
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Text",
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ⛽ FUEL LOGS TAB

class FuelLogsTab extends StatefulWidget {
  final Database db;
  FuelLogsTab({required this.db});

  @override
  _FuelLogsTabState createState() => _FuelLogsTabState();
}

class _FuelLogsTabState extends State<FuelLogsTab> {
  List<Map<String, dynamic>> fuelLogs = [];
  List<Map<String, dynamic>> vehicles = [];
  int? selectedVehicleId;
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    fetchFuelLogs();
  }

  Future<void> fetchVehicles() async {
    final data = await widget.db.query('vehicles');
    setState(() => vehicles = data);
  }

  Future<void> fetchFuelLogs() async {
    setState(() => isLoading = true);
    final data = await widget.db.query(
      'fuel_logs',
      where: selectedVehicleId != null ? 'vehicleId = ?' : null,
      whereArgs: selectedVehicleId != null ? [selectedVehicleId] : null,
      orderBy: 'date DESC',
    );
    setState(() {
      fuelLogs = data;
      isLoading = false;
    });
  }

  Future<void> showFuelDialog(
      {Map<String, dynamic>? log, required BuildContext context}) async {
    int? vehicleId = log?['vehicleId'] ?? selectedVehicleId;
    DateTime selectedDate = log?['date'] != null
        ? DateTime.tryParse(log!['date']) ?? DateTime.now()
        : DateTime.now();
    final volumeController =
        TextEditingController(text: log?['volume']?.toString() ?? '');
    final costController =
        TextEditingController(text: log?['cost']?.toString() ?? '');
    final odometerController =
        TextEditingController(text: log?['odometer']?.toString() ?? '');
    String dateDisplay = DateFormat('yyyy-MM-dd').format(selectedDate);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            log == null ? 'Add Fuel Log' : 'Edit Fuel Log',
            style: TextStyle(
              color: darkBlue,
              fontFamily: "SF Pro Display",
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: vehicleId,
                    decoration: InputDecoration(
                      labelText: 'Vehicle',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    dropdownColor: Colors.white,
                    items: vehicles
                        .map((v) => DropdownMenuItem<int>(
                              value: v['id'],
                              child: Text(v['name'],
                                  style: TextStyle(color: darkBlue)),
                            ))
                        .toList(),
                    onChanged: (val) => setDialogState(() => vehicleId = val),
                    validator: (value) =>
                        value == null ? 'Vehicle is required' : null,
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title: Text('Date: $dateDisplay',
                        style: TextStyle(color: darkBlue)),
                    trailing: Icon(Icons.calendar_today, color: primaryBlue),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2099),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryBlue,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateDisplay = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: volumeController,
                    decoration: InputDecoration(
                      labelText: 'Volume',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Volume is required';
                      final volume = double.tryParse(value);
                      if (volume == null || volume <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    decoration: InputDecoration(
                      labelText: 'Cost',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Cost is required';
                      final cost = double.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: odometerController,
                    decoration: InputDecoration(
                      labelText: 'Odometer',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Odometer is required';
                      final odometer = double.tryParse(value);
                      if (odometer == null || odometer < 0) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: primaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate() && vehicleId != null) {
                  final data = {
                    'vehicleId': vehicleId,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'volume': double.parse(volumeController.text),
                    'cost': double.parse(costController.text),
                    'odometer': double.parse(odometerController.text),
                  };
                  if (log == null) {
                    await widget.db.insert('fuel_logs', data);
                  } else {
                    await widget.db.update('fuel_logs', data,
                        where: 'id = ?', whereArgs: [log['id']]);
                  }
                  fetchFuelLogs();
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteFuelLog(int id, BuildContext context) async {
    await widget.db.delete('fuel_logs', where: 'id = ?', whereArgs: [id]);
    fetchFuelLogs();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fuel log deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      {required int id,
      required String name,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Fuel Log',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this fuel log for "$name"? This action cannot be undone.',
          style: TextStyle(color: darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              deleteFuelLog(id, context);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                child: DropdownButton<int>(
                  value: selectedVehicleId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Filter by Vehicle',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontFamily: "SF Pro Text")),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.arrow_drop_down, color: primaryBlue),
                  ),
                  items: vehicles
                      .map((v) => DropdownMenuItem<int>(
                            value: v['id'],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(v['name'],
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontFamily: "SF Pro Text")),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedVehicleId = val);
                    fetchFuelLogs();
                  },
                ),
              ),
            ),
            isLoading
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            color: primaryBlue,
                            size: 40.0,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading Fuel Logs...",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : fuelLogs.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "No fuel logs available.",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: fuelLogs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = fuelLogs[index];
                            final vehicle = vehicles.firstWhere(
                                (v) => v['id'] == item['vehicleId'],
                                orElse: () => {});
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  showFuelDialog(log: item, context: context),
                              child: Container(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${vehicle.isNotEmpty ? vehicle['name'] : 'Unknown'}",
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text",
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: primaryBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: primaryBlue,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () =>
                                                  showDeleteConfirmationDialog(
                                                      id: item['id'],
                                                      name: vehicle['name'] ??
                                                          'Unknown',
                                                      context: context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFFF2F2F7),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildInfo(
                                            title: "Cost",
                                            value: "\$${item['cost']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Volume",
                                            value: "${item['volume']} L",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Date",
                                            value: "${item['date']}",
                                            color: primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => showFuelDialog(context: context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontFamily: "SF Pro Text",
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Text",
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 💰 EXPENSES TAB

class ExpensesTab extends StatefulWidget {
  final Database db;
  ExpensesTab({required this.db});

  @override
  _ExpensesTabState createState() => _ExpensesTabState();
}

class _ExpensesTabState extends State<ExpensesTab> {
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> vehicles = [];
  int? selectedVehicleId;
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    fetchExpenses();
  }

  Future<void> fetchVehicles() async {
    final data = await widget.db.query('vehicles');
    setState(() => vehicles = data);
  }

  Future<void> fetchExpenses() async {
    setState(() => isLoading = true);
    final data = await widget.db.query(
      'expenses',
      where: selectedVehicleId != null ? 'vehicleId = ?' : null,
      whereArgs: selectedVehicleId != null ? [selectedVehicleId] : null,
      orderBy: 'date DESC',
    );
    setState(() {
      expenses = data;
      isLoading = false;
    });
  }

  Future<void> showExpenseDialog(
      {Map<String, dynamic>? expense, required BuildContext context}) async {
    int? vehicleId = expense?['vehicleId'] ?? selectedVehicleId;
    DateTime selectedDate = expense?['date'] != null
        ? DateTime.tryParse(expense!['date']) ?? DateTime.now()
        : DateTime.now();
    final categoryController =
        TextEditingController(text: expense?['category'] ?? '');
    final descriptionController =
        TextEditingController(text: expense?['description'] ?? '');
    final costController =
        TextEditingController(text: expense?['cost']?.toString() ?? '');
    String dateDisplay = DateFormat('yyyy-MM-dd').format(selectedDate);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            expense == null ? 'Add Expense' : 'Edit Expense',
            style: TextStyle(
              color: darkBlue,
              fontFamily: "SF Pro Display",
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: vehicleId,
                    decoration: InputDecoration(
                      labelText: 'Vehicle',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    dropdownColor: Colors.white,
                    items: vehicles
                        .map((v) => DropdownMenuItem<int>(
                              value: v['id'],
                              child: Text(v['name'],
                                  style: TextStyle(color: darkBlue)),
                            ))
                        .toList(),
                    onChanged: (val) => setDialogState(() => vehicleId = val),
                    validator: (value) =>
                        value == null ? 'Vehicle is required' : null,
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title: Text('Date: $dateDisplay',
                        style: TextStyle(color: darkBlue)),
                    trailing: Icon(Icons.calendar_today, color: primaryBlue),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2099),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryBlue,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateDisplay = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    validator: (value) =>
                        value!.isEmpty ? 'Category is required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    validator: (value) =>
                        value!.isEmpty ? 'Description is required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    decoration: InputDecoration(
                      labelText: 'Cost',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Cost is required';
                      final cost = double.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: primaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate() && vehicleId != null) {
                  final data = {
                    'vehicleId': vehicleId,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'category': categoryController.text,
                    'description': descriptionController.text,
                    'cost': double.parse(costController.text),
                  };
                  if (expense == null) {
                    await widget.db.insert('expenses', data);
                  } else {
                    await widget.db.update('expenses', data,
                        where: 'id = ?', whereArgs: [expense['id']]);
                  }
                  fetchExpenses();
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteExpense(int id, BuildContext context) async {
    await widget.db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    fetchExpenses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      {required int id,
      required String name,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Expense',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this expense for "$name"? This action cannot be undone.',
          style: TextStyle(color: darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              deleteExpense(id, context);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                child: DropdownButton<int>(
                  value: selectedVehicleId,
                  hint: const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Filter by Vehicle',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontFamily: "SF Pro Text")),
                  ),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.arrow_drop_down, color: primaryBlue),
                  ),
                  items: vehicles
                      .map((v) => DropdownMenuItem<int>(
                            value: v['id'],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(v['name'],
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontFamily: "SF Pro Text")),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedVehicleId = val);
                    fetchExpenses();
                  },
                ),
              ),
            ),
            isLoading
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            color: primaryBlue,
                            size: 40.0,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading Expenses...",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : expenses.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "No expenses available.",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: expenses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = expenses[index];
                            final vehicle = vehicles.firstWhere(
                                (v) => v['id'] == item['vehicleId'],
                                orElse: () => {});
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => showExpenseDialog(
                                  expense: item, context: context),
                              child: Container(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${vehicle.isNotEmpty ? vehicle['name'] : 'Unknown'}",
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text",
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: primaryBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: primaryBlue,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () =>
                                                  showDeleteConfirmationDialog(
                                                      id: item['id'],
                                                      name: vehicle['name'] ??
                                                          'Unknown',
                                                      context: context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFFF2F2F7),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildInfo(
                                            title: "Cost",
                                            value: "\$${item['cost']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Category",
                                            value: "${item['category']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Date",
                                            value: "${item['date']}",
                                            color: primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => showExpenseDialog(context: context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontFamily: "SF Pro Text",
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Text",
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 🔧 MAINTENANCE TAB

class MaintenanceTab extends StatefulWidget {
  final Database db;
  MaintenanceTab({required this.db});

  @override
  _MaintenanceTabState createState() => _MaintenanceTabState();
}

class _MaintenanceTabState extends State<MaintenanceTab> {
  List<Map<String, dynamic>> tasks = [];
  List<Map<String, dynamic>> vehicles = [];
  int? selectedVehicleId;
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    fetchTasks();
  }

  Future<void> fetchVehicles() async {
    final data = await widget.db.query('vehicles');
    setState(() => vehicles = data);
  }

  Future<void> fetchTasks() async {
    setState(() => isLoading = true);
    final data = await widget.db.query(
      'maintenance',
      where: selectedVehicleId != null ? 'vehicleId = ?' : null,
      whereArgs: selectedVehicleId != null ? [selectedVehicleId] : null,
      orderBy: 'date DESC',
    );
    setState(() {
      tasks = data;
      isLoading = false;
    });
  }

  Future<void> showMaintenanceDialog(
      {Map<String, dynamic>? task, required BuildContext context}) async {
    int? vehicleId = task?['vehicleId'] ?? selectedVehicleId;
    DateTime selectedDate = task?['date'] != null
        ? DateTime.tryParse(task!['date']) ?? DateTime.now()
        : DateTime.now();
    final typeController = TextEditingController(text: task?['taskType'] ?? '');
    final descriptionController =
        TextEditingController(text: task?['description'] ?? '');
    final costController =
        TextEditingController(text: task?['cost']?.toString() ?? '');
    String dateDisplay = DateFormat('yyyy-MM-dd').format(selectedDate);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(
            task == null ? 'Add Maintenance Task' : 'Edit Maintenance Task',
            style: TextStyle(
              color: darkBlue,
              fontFamily: "SF Pro Display",
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: vehicleId,
                    decoration: InputDecoration(
                      labelText: 'Vehicle',
                      labelStyle: const TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: const Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    dropdownColor: Colors.white,
                    items: vehicles
                        .map((v) => DropdownMenuItem<int>(
                              value: v['id'],
                              child: Text(v['name'],
                                  style: TextStyle(color: darkBlue)),
                            ))
                        .toList(),
                    onChanged: (val) => setDialogState(() => vehicleId = val),
                    validator: (value) =>
                        value == null ? 'Vehicle is required' : null,
                  ),
                  SizedBox(height: 12),
                  ListTile(
                    title: Text('Date: $dateDisplay',
                        style: TextStyle(color: darkBlue)),
                    trailing: Icon(Icons.calendar_today, color: primaryBlue),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2099),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryBlue,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && picked != selectedDate) {
                        setDialogState(() {
                          selectedDate = picked;
                          dateDisplay = DateFormat('yyyy-MM-dd').format(picked);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: typeController,
                    decoration: InputDecoration(
                      labelText: 'Task Type',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    validator: (value) =>
                        value!.isEmpty ? 'Task Type is required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    validator: (value) =>
                        value!.isEmpty ? 'Description is required' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: costController,
                    decoration: InputDecoration(
                      labelText: 'Cost',
                      labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                      filled: true,
                      fillColor: Color(0xFFF2F2F7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: darkBlue),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Cost is required';
                      final cost = double.tryParse(value);
                      if (cost == null || cost <= 0) {
                        return 'Enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: primaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (formKey.currentState!.validate() && vehicleId != null) {
                  final data = {
                    'vehicleId': vehicleId,
                    'date': DateFormat('yyyy-MM-dd').format(selectedDate),
                    'taskType': typeController.text,
                    'description': descriptionController.text,
                    'cost': double.parse(costController.text),
                  };
                  if (task == null) {
                    await widget.db.insert('maintenance', data);
                  } else {
                    await widget.db.update('maintenance', data,
                        where: 'id = ?', whereArgs: [task['id']]);
                  }
                  fetchTasks();
                  Navigator.pop(context);
                }
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteTask(int id, BuildContext context) async {
    await widget.db.delete('maintenance', where: 'id = ?', whereArgs: [id]);
    fetchTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Maintenance task deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      {required int id,
      required String name,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Maintenance Task',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this maintenance task for "$name"? This action cannot be undone.',
          style: TextStyle(color: darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              deleteTask(id, context);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                child: DropdownButton<int>(
                  value: selectedVehicleId,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Filter by Vehicle',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontFamily: "SF Pro Text")),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.arrow_drop_down, color: primaryBlue),
                  ),
                  items: vehicles
                      .map((v) => DropdownMenuItem<int>(
                            value: v['id'],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(v['name'],
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontFamily: "SF Pro Text")),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedVehicleId = val);
                    fetchTasks();
                  },
                ),
              ),
            ),
            isLoading
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            color: primaryBlue,
                            size: 40.0,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading Maintenance...",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : tasks.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "No maintenance tasks available.",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: tasks.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = tasks[index];
                            final vehicle = vehicles.firstWhere(
                                (v) => v['id'] == item['vehicleId'],
                                orElse: () => {});
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () => showMaintenanceDialog(
                                  task: item, context: context),
                              child: Container(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${vehicle.isNotEmpty ? vehicle['name'] : 'Unknown'}",
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text",
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: primaryBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: primaryBlue,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () =>
                                                  showDeleteConfirmationDialog(
                                                      id: item['id'],
                                                      name: vehicle['name'] ??
                                                          'Unknown',
                                                      context: context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFFF2F2F7),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildInfo(
                                            title: "Cost",
                                            value: "\$${item['cost']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Task Type",
                                            value: "${item['taskType']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Date",
                                            value: "${item['date']}",
                                            color: primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => showMaintenanceDialog(context: context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontFamily: "SF Pro Text",
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Text",
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 🗺️ TRIPS TAB

class TripsTab extends StatefulWidget {
  final Database db;
  TripsTab({required this.db});

  @override
  _TripsTabState createState() => _TripsTabState();
}

class _TripsTabState extends State<TripsTab> {
  List<Map<String, dynamic>> trips = [];
  List<Map<String, dynamic>> vehicles = [];
  int? selectedVehicleId;
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchVehicles();
    fetchTrips();
  }

  Future<void> fetchVehicles() async {
    final data = await widget.db.query('vehicles');
    setState(() => vehicles = data);
  }

  Future<void> fetchTrips() async {
    setState(() => isLoading = true);
    final data = await widget.db.query(
      'trips',
      where: selectedVehicleId != null ? 'vehicleId = ?' : null,
      whereArgs: selectedVehicleId != null ? [selectedVehicleId] : null,
      orderBy: 'startDate DESC',
    );
    setState(() {
      trips = data;
      isLoading = false;
    });
  }

  Future<void> showTripDialog(
      {Map<String, dynamic>? trip, required BuildContext context}) async {
    int? vehicleId = trip?['vehicleId'] ?? selectedVehicleId;
    DateTime startDate = trip?['startDate'] != null
        ? DateTime.tryParse(trip!['startDate']) ?? DateTime.now()
        : DateTime.now();
    DateTime? endDate =
        trip?['endDate'] != null ? DateTime.tryParse(trip!['endDate']) : null;
    final distanceController =
        TextEditingController(text: trip?['distance']?.toString() ?? '');
    final notesController = TextEditingController(text: trip?['notes'] ?? '');
    String startDateDisplay = DateFormat('yyyy-MM-dd').format(startDate);
    String endDateDisplay =
        endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'Not set';
    final formKey = GlobalKey<FormState>();

    await showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                title: Text(
                  trip == null ? 'Add Trip' : 'Edit Trip',
                  style: TextStyle(
                    color: darkBlue,
                    fontFamily: "SF Pro Display",
                    fontWeight: FontWeight.w600,
                  ),
                ),
                content: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<int>(
                          value: vehicleId,
                          decoration: InputDecoration(
                            labelText: 'Vehicle',
                            labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                            filled: true,
                            fillColor: Color(0xFFF2F2F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: darkBlue),
                          dropdownColor: Colors.white,
                          items: vehicles
                              .map((v) => DropdownMenuItem<int>(
                                    value: v['id'],
                                    child: Text(v['name'],
                                        style: TextStyle(color: darkBlue)),
                                  ))
                              .toList(),
                          onChanged: (val) =>
                              setDialogState(() => vehicleId = val),
                          validator: (value) =>
                              value == null ? 'Vehicle is required' : null,
                        ),
                        SizedBox(height: 12),
                        ListTile(
                          title: Text('Start Date: $startDateDisplay',
                              style: TextStyle(color: darkBlue)),
                          trailing:
                              Icon(Icons.calendar_today, color: primaryBlue),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2099),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: primaryBlue,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                });

                            if (picked != null && picked != startDate) {
                              setDialogState(() {
                                startDate = picked;
                                startDateDisplay =
                                    DateFormat('yyyy-MM-dd').format(picked);
                              });
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        ListTile(
                          title: Text('End Date: $endDateDisplay',
                              style: TextStyle(color: darkBlue)),
                          trailing:
                              Icon(Icons.calendar_today, color: primaryBlue),
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2099),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: primaryBlue,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setDialogState(() {
                                endDate = picked;
                                endDateDisplay =
                                    DateFormat('yyyy-MM-dd').format(picked);
                              });
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: distanceController,
                          decoration: InputDecoration(
                            labelText: 'Distance (km)',
                            labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                            filled: true,
                            fillColor: Color(0xFFF2F2F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: darkBlue),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value!.isEmpty) return 'Distance is required';
                            final distance = double.tryParse(value);
                            if (distance == null || distance <= 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: notesController,
                          decoration: InputDecoration(
                            labelText: 'Notes',
                            labelStyle: TextStyle(color: Color(0xFF8E8E93)),
                            filled: true,
                            fillColor: Color(0xFFF2F2F7),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: TextStyle(color: darkBlue),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: primaryBlue)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate() &&
                          vehicleId != null) {
                        final data = {
                          'vehicleId': vehicleId,
                          'startDate':
                              DateFormat('yyyy-MM-dd').format(startDate),
                          'endDate': endDate != null
                              ? DateFormat('yyyy-MM-dd').format(endDate!)
                              : null,
                          'distance': double.parse(distanceController.text),
                          'notes': notesController.text,
                        };
                        if (trip == null) {
                          await widget.db.insert('trips', data);
                        } else {
                          await widget.db.update('trips', data,
                              where: 'id = ?', whereArgs: [trip['id']]);
                        }
                        fetchTrips();
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Save'),
                  ),
                ],
              ),
            ));
  }

  Future<void> deleteTrip(int id, BuildContext context) async {
    await widget.db.delete('trips', where: 'id = ?', whereArgs: [id]);
    fetchTrips();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      {required int id,
      required String name,
      required BuildContext context}) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete Trip',
          style: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this trip for "$name"? This action cannot be undone.',
          style: TextStyle(color: darkBlue),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: primaryBlue)),
          ),
          TextButton(
            onPressed: () {
              deleteTrip(id, context);
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
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
                child: DropdownButton<int>(
                  value: selectedVehicleId,
                  hint: const Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text('Filter by Vehicle',
                        style: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontFamily: "SF Pro Text")),
                  ),
                  isExpanded: true,
                  underline: SizedBox(),
                  icon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Icon(Icons.arrow_drop_down, color: primaryBlue),
                  ),
                  items: vehicles
                      .map((v) => DropdownMenuItem<int>(
                            value: v['id'],
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Text(v['name'],
                                  style: TextStyle(
                                      color: darkBlue,
                                      fontFamily: "SF Pro Text")),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedVehicleId = val);
                    fetchTrips();
                  },
                ),
              ),
            ),
            isLoading
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitFadingCircle(
                            color: primaryBlue,
                            size: 40.0,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Loading Trips...",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : trips.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text(
                            "No trips available.",
                            style: TextStyle(
                              color: darkBlue.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: "SF Pro Text",
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          itemCount: trips.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = trips[index];
                            final vehicle = vehicles.firstWhere(
                                (v) => v['id'] == item['vehicleId'],
                                orElse: () => {});
                            return InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () =>
                                  showTripDialog(trip: item, context: context),
                              child: Container(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "${vehicle.isNotEmpty ? vehicle['name'] : 'Unknown'}",
                                            style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text",
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: primaryBlue
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                Icons.edit,
                                                color: primaryBlue,
                                                size: 20,
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            IconButton(
                                              icon: Icon(Icons.delete,
                                                  color: Colors.red, size: 20),
                                              onPressed: () =>
                                                  showDeleteConfirmationDialog(
                                                      id: item['id'],
                                                      name: vehicle['name'] ??
                                                          'Unknown',
                                                      context: context),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFFF2F2F7),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          buildInfo(
                                            title: "Distance",
                                            value: "${item['distance']} km",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "Start Date",
                                            value: "${item['startDate']}",
                                            color: primaryBlue,
                                          ),
                                          buildInfo(
                                            title: "End Date",
                                            value: item['endDate'] ?? 'N/A',
                                            color: primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () => showTripDialog(context: context),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildInfo({
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontFamily: "SF Pro Text",
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontFamily: "SF Pro Text",
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// 📊 REPORTS TAB

class ReportsTab extends StatefulWidget {
  final Database db;
  ReportsTab({required this.db});

  @override
  _ReportsTabState createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  List<Map<String, dynamic>> vehicles = [];
  List<Map<String, dynamic>> fuelLogs = [];
  List<Map<String, dynamic>> expenses = [];
  List<Map<String, dynamic>> maintenance = [];
  List<Map<String, dynamic>> trips = [];
  int? selectedVehicleId;
  String selectedReportType = 'Fuel Efficiency';
  DateTime? startDate;
  DateTime? endDate;
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    final vehicleData = await widget.db.query('vehicles');
    final fuelLogData = await widget.db.query(
      'fuel_logs',
      where: buildWhereClause('vehicleId'),
      whereArgs: buildWhereArgs(),
    );
    final expenseData = await widget.db.query(
      'expenses',
      where: buildWhereClause('vehicleId'),
      whereArgs: buildWhereArgs(),
    );
    final maintenanceData = await widget.db.query(
      'maintenance',
      where: buildWhereClause('vehicleId'),
      whereArgs: buildWhereArgs(),
    );
    final tripData = await widget.db.query(
      'trips',
      where: buildWhereClause('vehicleId'),
      whereArgs: buildWhereArgs(),
    );
    setState(() {
      vehicles = vehicleData;
      fuelLogs = fuelLogData;
      expenses = expenseData;
      maintenance = maintenanceData;
      trips = tripData;
      isLoading = false;
    });
  }

  String? buildWhereClause(String vehicleIdColumn) {
    List<String> clauses = [];
    if (selectedVehicleId != null) {
      clauses.add('$vehicleIdColumn = ?');
    }
    if (startDate != null) {
      clauses.add('date >= ?');
    }
    if (endDate != null) {
      clauses.add('date <= ?');
    }
    return clauses.isEmpty ? null : clauses.join(' AND ');
  }

  List<dynamic> buildWhereArgs() {
    List<dynamic> args = [];
    if (selectedVehicleId != null) {
      args.add(selectedVehicleId);
    }
    if (startDate != null) {
      args.add(DateFormat('yyyy-MM-dd').format(startDate!));
    }
    if (endDate != null) {
      args.add(DateFormat('yyyy-MM-dd').format(endDate!));
    }
    return args;
  }

  List<FlSpot> getFuelEfficiencySpots() {
    if (fuelLogs.isEmpty || trips.isEmpty) return [];

    final sortedFuelLogs = List<Map<String, dynamic>>.from(fuelLogs)
      ..sort((a, b) =>
          DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
    final sortedTrips = List<Map<String, dynamic>>.from(trips)
      ..sort((a, b) => DateTime.parse(a['startDate'])
          .compareTo(DateTime.parse(b['startDate'])));

    List<FlSpot> spots = [];
    double cumulativeDistance = 0;
    double cumulativeVolume = 0;
    int fuelIndex = 0;
    int tripIndex = 0;

    while (
        fuelIndex < sortedFuelLogs.length && tripIndex < sortedTrips.length) {
      final fuelDate = DateTime.parse(sortedFuelLogs[fuelIndex]['date']);
      final tripDate = DateTime.parse(sortedTrips[tripIndex]['startDate']);

      if (fuelDate.isBefore(tripDate) || fuelDate.isAtSameMomentAs(tripDate)) {
        cumulativeVolume +=
            double.parse(sortedFuelLogs[fuelIndex]['volume'].toString());
        fuelIndex++;
      } else {
        cumulativeDistance +=
            double.parse(sortedTrips[tripIndex]['distance'].toString());
        tripIndex++;
      }

      if (cumulativeVolume > 0 && cumulativeDistance > 0) {
        final efficiency = cumulativeDistance / cumulativeVolume;
        spots.add(FlSpot(spots.length.toDouble(), efficiency));
      }
    }

    while (fuelIndex < sortedFuelLogs.length) {
      cumulativeVolume +=
          double.parse(sortedFuelLogs[fuelIndex]['volume'].toString());
      if (cumulativeVolume > 0 && cumulativeDistance > 0) {
        final efficiency = cumulativeDistance / cumulativeVolume;
        spots.add(FlSpot(spots.length.toDouble(), efficiency));
      }
      fuelIndex++;
    }

    while (tripIndex < sortedTrips.length) {
      cumulativeDistance +=
          double.parse(sortedTrips[tripIndex]['distance'].toString());
      if (cumulativeVolume > 0 && cumulativeDistance > 0) {
        final efficiency = cumulativeDistance / cumulativeVolume;
        spots.add(FlSpot(spots.length.toDouble(), efficiency));
      }
      tripIndex++;
    }

    return spots;
  }

  BarChartData getCostAnalysisData() {
    final fuelCost = fuelLogs.fold<double>(
        0, (sum, log) => sum + double.parse(log['cost'].toString()));
    final expenseCost = expenses.fold<double>(
        0, (sum, exp) => sum + double.parse(exp['cost'].toString()));
    final maintenanceCost = maintenance.fold<double>(
        0, (sum, task) => sum + double.parse(task['cost'].toString()));
    return BarChartData(
      barGroups: [
        BarChartGroupData(
            x: 0,
            barRods: [BarChartRodData(toY: fuelCost, color: primaryBlue)]),
        BarChartGroupData(
            x: 1,
            barRods: [BarChartRodData(toY: expenseCost, color: Colors.green)]),
        BarChartGroupData(x: 2, barRods: [
          BarChartRodData(toY: maintenanceCost, color: Colors.orange)
        ]),
      ],
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              const titles = ['Fuel', 'Expenses', 'Maintenance'];
              return Text(titles[value.toInt()],
                  style: TextStyle(color: darkBlue, fontSize: 12));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              value.toStringAsFixed(0),
              style: TextStyle(color: darkBlue, fontSize: 12),
            ),
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
          show: true, border: Border.all(color: Color(0xFFD1D1D6))),
      gridData: FlGridData(show: true),
    );
  }

  PieChartData getDistancePieData() {
    final vehicleDistances = <int, double>{};
    for (var trip in trips) {
      vehicleDistances[trip['vehicleId']] =
          (vehicleDistances[trip['vehicleId']] ?? 0) +
              double.parse(trip['distance'].toString());
    }
    final colors = [
      primaryBlue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple
    ];
    return PieChartData(
      sections: vehicleDistances.entries.map((entry) {
        final vehicle = vehicles.firstWhere((v) => v['id'] == entry.key,
            orElse: () => {'name': 'Unknown'});
        return PieChartSectionData(
          value: entry.value,
          title: vehicle['name'],
          color: colors[vehicleDistances.keys.toList().indexOf(entry.key) %
              colors.length],
          radius: 100,
          titleStyle: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
        );
      }).toList(),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }

  Future<List<Map<String, dynamic>>> getFuelEfficiencyReport() async {
    List<Map<String, dynamic>> report = [];
    for (var vehicle in vehicles) {
      final fuelLogs = await widget.db.query(
        'fuel_logs',
        where: buildWhereClause('vehicleId') != null
            ? '${buildWhereClause('vehicleId')} AND vehicleId = ?'
            : 'vehicleId = ?',
        whereArgs: [...buildWhereArgs(), vehicle['id']],
      );
      final trips = await widget.db.query(
        'trips',
        where: buildWhereClause('vehicleId') != null
            ? '${buildWhereClause('vehicleId')} AND vehicleId = ?'
            : 'vehicleId = ?',
        whereArgs: [...buildWhereArgs(), vehicle['id']],
      );
      double totalVolume = fuelLogs.fold(
          0.0, (sum, log) => sum + double.parse(log['volume'].toString()));
      double totalDistance = trips.fold(
          0.0, (sum, trip) => sum + double.parse(trip['distance'].toString()));
      double efficiency = totalVolume > 0 ? totalDistance / totalVolume : 0.0;
      report.add({
        'vehicleName': vehicle['name'],
        'efficiency': efficiency,
      });
    }
    return report;
  }

  Map<String, dynamic> getSummaryStats() {
    final fuelCost = fuelLogs.fold<double>(
        0, (sum, log) => sum + double.parse(log['cost'].toString()));
    final expenseCost = expenses.fold<double>(
        0, (sum, exp) => sum + double.parse(exp['cost'].toString()));
    final maintenanceCost = maintenance.fold<double>(
        0, (sum, task) => sum + double.parse(task['cost'].toString()));
    final totalDistance = trips.fold<double>(
        0, (sum, trip) => sum + double.parse(trip['distance'].toString()));
    final totalVolume = fuelLogs.fold<double>(
        0, (sum, log) => sum + double.parse(log['volume'].toString()));
    final avgEfficiency = totalVolume > 0 ? totalDistance / totalVolume : 0.0;
    return {
      'totalCost': fuelCost + expenseCost + maintenanceCost,
      'fuelCost': fuelCost,
      'expenseCost': expenseCost,
      'maintenanceCost': maintenanceCost,
      'totalDistance': totalDistance,
      'avgEfficiency': avgEfficiency,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(color: primaryBlue, size: 40.0),
                    const SizedBox(height: 20),
                    Text(
                      "Loading Reports...",
                      style: TextStyle(
                        color: darkBlue.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
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
                        child: DropdownButton<int>(
                          value: selectedVehicleId,
                          hint: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text('Filter by Vehicle',
                                style: TextStyle(
                                    color: Color(0xFF8E8E93),
                                    fontFamily: "SF Pro Text")),
                          ),
                          isExpanded: true,
                          underline: SizedBox(),
                          icon: Padding(
                            padding: const EdgeInsets.only(right: 12.0),
                            child:
                                Icon(Icons.arrow_drop_down, color: primaryBlue),
                          ),
                          items: vehicles
                              .map((v) => DropdownMenuItem<int>(
                                    value: v['id'],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Text(v['name'],
                                          style: TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text")),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            setState(() => selectedVehicleId = val);
                            fetchData();
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            'Fuel Efficiency',
                            'Cost Analysis',
                            'Distance Traveled'
                          ]
                              .map((type) => Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(
                                            () => selectedReportType = type);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        decoration: BoxDecoration(
                                          color: selectedReportType == type
                                              ? Colors.white
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          boxShadow: selectedReportType == type
                                              ? [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Text(
                                          type,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: selectedReportType == type
                                                ? darkBlue
                                                : Color(0xFF8E8E93),
                                            fontFamily: "SF Pro Text",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        selectedReportType,
                        style: TextStyle(
                          color: darkBlue,
                          fontFamily: "SF Pro Display",
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      height: 300,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
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
                      child: selectedReportType == 'Fuel Efficiency'
                          ? (fuelLogs.isEmpty || trips.isEmpty
                              ? Center(
                                  child: Text(
                                    "No data available for fuel efficiency.",
                                    style: TextStyle(
                                      color: darkBlue.withOpacity(0.8),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : LineChart(LineChartData(
                                  gridData: FlGridData(show: true),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toInt().toString(),
                                          style: TextStyle(
                                              color: Color(0xFF8E8E93),
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (value, meta) => Text(
                                          value.toStringAsFixed(1),
                                          style: TextStyle(
                                              color: Color(0xFF8E8E93),
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
                                    topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(
                                      show: true,
                                      border: Border.all(
                                          color: Color(0xFFD1D1D6), width: 1)),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: getFuelEfficiencySpots(),
                                      isCurved: true,
                                      color: primaryBlue,
                                      barWidth: 4,
                                      dotData: FlDotData(show: true),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: primaryBlue.withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                )))
                          : selectedReportType == 'Cost Analysis'
                              ? (fuelLogs.isEmpty &&
                                      expenses.isEmpty &&
                                      maintenance.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No cost data available.",
                                        style: TextStyle(
                                          color: darkBlue.withOpacity(0.8),
                                          fontFamily: "SF Pro Text",
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : BarChart(getCostAnalysisData()))
                              : (trips.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No distance data available.",
                                        style: TextStyle(
                                          color: darkBlue.withOpacity(0.8),
                                          fontFamily: "SF Pro Text",
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : PieChart(getDistancePieData())),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Summary Statistics",
                        style: TextStyle(
                          color: darkBlue,
                          fontFamily: "SF Pro Display",
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
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
                          if (selectedReportType == 'Fuel Efficiency') ...[
                            FutureBuilder<List<Map<String, dynamic>>>(
                              future: getFuelEfficiencyReport(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: SpinKitFadingCircle(
                                          color: primaryBlue, size: 40.0));
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.isEmpty) {
                                  return Text(
                                    "No fuel efficiency data available.",
                                    style: TextStyle(
                                      color: darkBlue.withOpacity(0.8),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 16,
                                    ),
                                  );
                                }
                                final report = snapshot.data!;
                                return Table(
                                  border: TableBorder.all(
                                      color: Color(0xFFD1D1D6), width: 1),
                                  columnWidths: {
                                    0: FlexColumnWidth(2),
                                    1: FlexColumnWidth(1),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F7)),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Vehicle',
                                              style: TextStyle(
                                                  color: darkBlue,
                                                  fontFamily: "SF Pro Text",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Efficiency (km/L)',
                                              style: TextStyle(
                                                  color: darkBlue,
                                                  fontFamily: "SF Pro Text",
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                        ),
                                      ],
                                    ),
                                    ...report.map((entry) => TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(entry['vehicleName'],
                                                  style: TextStyle(
                                                      color: darkBlue,
                                                      fontFamily: "SF Pro Text",
                                                      fontSize: 14)),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                  entry['efficiency']
                                                      .toStringAsFixed(2),
                                                  style: TextStyle(
                                                      color: primaryBlue,
                                                      fontFamily: "SF Pro Text",
                                                      fontSize: 14)),
                                            ),
                                          ],
                                        )),
                                  ],
                                );
                              },
                            ),
                          ] else if (selectedReportType == 'Cost Analysis') ...[
                            Text(
                                'Total Cost: \$${getSummaryStats()['totalCost'].toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14)),
                            SizedBox(height: 8),
                            Text(
                                'Fuel Cost: \$${getSummaryStats()['fuelCost'].toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14)),
                            SizedBox(height: 8),
                            Text(
                                'Expense Cost: \$${getSummaryStats()['expenseCost'].toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14)),
                            SizedBox(height: 8),
                            Text(
                                'Maintenance Cost: \$${getSummaryStats()['maintenanceCost'].toStringAsFixed(2)}',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14)),
                          ] else ...[
                            Text(
                                'Total Distance: ${getSummaryStats()['totalDistance'].toStringAsFixed(2)} km',
                                style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14)),
                            SizedBox(height: 8),
                            ...vehicles.map((v) {
                              final distance = trips
                                  .where((t) => t['vehicleId'] == v['id'])
                                  .fold<double>(
                                      0,
                                      (sum, t) =>
                                          sum +
                                          double.parse(
                                              t['distance'].toString()));
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                    '${v['name']}: ${distance.toStringAsFixed(2)} km',
                                    style: TextStyle(
                                        color: darkBlue,
                                        fontFamily: "SF Pro Text",
                                        fontSize: 14)),
                              );
                            }),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }
}

// ⚙️ SETTINGS TAB

class SettingsTab extends StatefulWidget {
  final Database db;
  SettingsTab({required this.db});

  @override
  _SettingsTabState createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  String currency = 'USD';
  bool isLoading = true;
  final Color primaryBlue = const Color(0xFF007AFF);
  final Color darkBlue = const Color(0xFF0A4B9A);

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    setState(() => isLoading = true);
    final data = await widget.db
        .query('settings', where: 'key = ?', whereArgs: ['currency']);
    if (data.isNotEmpty) {
      setState(() {
        currency = data[0]['value'] as String;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> saveCurrency(String newCurrency) async {
    await widget.db.insert(
      'settings',
      {'key': 'currency', 'value': newCurrency},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    setState(() => currency = newCurrency);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitFadingCircle(
                      color: primaryBlue,
                      size: 40.0,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Loading Settings...",
                      style: TextStyle(
                        color: darkBlue.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: "SF Pro Text",
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Settings",
                      style: TextStyle(
                        color: darkBlue,
                        fontFamily: "SF Pro Display",
                        fontSize: 24.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
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
                            "Currency",
                            style: TextStyle(
                              color: darkBlue,
                              fontFamily: "SF Pro Text",
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          DropdownButton<String>(
                            value: currency,
                            isExpanded: true,
                            underline: SizedBox(),
                            icon:
                                Icon(Icons.arrow_drop_down, color: primaryBlue),
                            items: ['USD', 'EUR', 'GBP', 'JPY']
                                .map((c) => DropdownMenuItem<String>(
                                      value: c,
                                      child: Text(c,
                                          style: TextStyle(color: darkBlue)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                saveCurrency(val);
                              }
                            },
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
}
