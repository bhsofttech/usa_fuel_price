// ignore_for_file: constant_identifier_names

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:usa_gas_price/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<Database>? myDatabase;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  MobileAds.instance.initialize();

  myDatabase = openDatabase(
    await getDatabasesPath().then((path) => '$path/vehicle_manager.db'),
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE vehicles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          type TEXT,
          mileage REAL
        )
      ''');
      await db.execute('''
        CREATE TABLE trips (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicleId INTEGER,
          source TEXT,
          destination TEXT,
          distance REAL,
          FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
        )
      ''');
      await db.execute('''
  CREATE TABLE fuel_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    vehicleId INTEGER,
    date TEXT,
    volume REAL,
    cost REAL,
    fuelType TEXT,
    FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
  )
      ''');
      await db.execute('''
        CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicleId INTEGER,
          date TEXT,
          category TEXT,
          amount REAL,
          FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
        )
      ''');
      await db.execute('''
        CREATE TABLE maintenance (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vehicleId INTEGER,
          date TEXT,
          detail TEXT,
          cost REAL,
          FOREIGN KEY (vehicleId) REFERENCES vehicles(id)
        )
      ''');
    },
    version: 1,
  );

  runApp(const GetMaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
  ));
}

enum CountryList {
  United_States,
  China,
  Japan,
  Germany,
  United_Kingdom,
  France,
  India,
  Italy,
  Brazil,
  Canada,
  South_Korea,
  Russia,
  Spain,
  Australia,
  Mexico,
  Indonesia,
  Turkey,
  Netherlands,
  Switzerland,
  Saudi_Arabia,
  Argentina,
  South_Africa,
  Singapore,
  Albania,
  Andorra,
  Austria,
  Belarus,
  Belgium,
  Bosnia_and_Herzegovina,
  Bulgaria,
  Croatia,
  Cyprus,
  Czech_Republic,
  Denmark,
  Estonia,
  Euro_area,
  Faroe_Islands,
  Finland,
  Greece,
  Hungary,
  Iceland,
  Ireland,
  Kosovo,
  Latvia,
  Liechtenstein,
  Lithuania,
  Luxembourg,
  Malta,
  Moldova,
  Monaco,
  Montenegro,
  North_Macedonia,
  Norway,
  Poland,
  Portugal,
  Romania,
  Serbia,
  Slovakia,
  Slovenia,
  Sweden,
  Ukraine,
  Antigua_and_Barbuda,
  Aruba,
  Bahamas,
  Barbados,
  Belize,
  Bermuda,
  Bolivia,
  Cayman_Islands,
  Colombia,
  Costa_Rica,
  Cuba,
  Dominica,
  Dominican_Republic,
  Ecuador,
  El_Salvador,
  Grenada,
  Guatemala,
  Guyana,
  Haiti,
  Honduras,
  Jamaica,
  Nicaragua,
  Panama,
  Paraguay,
  Peru,
  Puerto_Rico,
  Suriname,
  Trinidad_and_Tobago,
  Uruguay,
  Venezuela,
  Afghanistan,
  Armenia,
  Azerbaijan,
  Bahrain,
  Bangladesh,
  Bhutan,
  Brunei,
  Cambodia,
  East_Timor,
  Georgia,
  Hong_Kong,
  Iran,
  Iraq,
  Israel,
  Jordan,
  Kazakhstan,
  Kuwait,
  Kyrgyzstan,
  Laos,
  Lebanon,
  Macao,
  Malaysia,
  Maldives,
  Mongolia,
  Myanmar,
  Nepal,
  North_Korea,
  Oman,
  Palestine,
  Pakistan,
  Philippines,
  Qatar,
  Sri_Lanka,
  Syria,
  Taiwan,
  Tajikistan,
  Thailand,
  Turkmenistan,
  United_Arab_Emirates,
  Uzbekistan,
  Vietnam,
  Yemen,
  Algeria,
  Angola,
  Benin,
  Botswana,
  Burkina_Faso,
  Burundi,
  Cameroon,
  Cape_Verde,
  Central_African_Republic,
  Chad,
  Comoros,
  Congo,
  Djibouti,
  Egypt,
  Equatorial_Guinea,
  Eritrea,
  Ethiopia,
  Gabon,
  Gambia,
  Ghana,
  Guinea,
  Guinea_Bissau,
  Ivory_Coast,
  Kenya,
  Lesotho,
  Liberia,
  Libya,
  Madagascar,
  Malawi,
  Mali,
  Mauritania,
  Mauritius,
  Morocco,
  Mozambique,
  Namibia,
  Niger,
  Nigeria,
  Rwanda,
  Senegal,
  Seychelles,
  Sierra_Leone,
  Somalia,
  South_Sudan,
  Sudan,
  Swaziland,
  Tanzania,
  Togo,
  Tunisia,
  Uganda,
  Zambia,
  Zimbabwe,
  Fiji,
  Kiribati,
  New_Caledonia,
  New_Zealand,
  Samoa,
  Solomon_Islands,
  Tonga,
  Vanuatu
}

    Future<bool> checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (connectivityResult.first == ConnectivityResult.mobile) {
      return true;
    } else if (connectivityResult.first == ConnectivityResult.wifi) {
      return true;
    }
    return false;
  }

     String convertDate({required String date}) {
    String dateInput = date;
    DateTime parsedDate = DateTime.parse(dateInput);
    String formattedDate = DateFormat('d MMMM yyyy').format(parsedDate);
    return formattedDate;
  }
