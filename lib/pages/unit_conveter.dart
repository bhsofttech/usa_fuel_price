import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';

class UnitConverterApp extends StatelessWidget {
  const UnitConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF007AFF); // iOS system blue
    const Color darkBlue = Color(0xFF0A4B9A); // Darker blue variant

    return MaterialApp(
      title: 'Advanced Unit Converter',
      theme: ThemeData.light().copyWith(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor:
            const Color(0xFFF2F2F7), // iOS style background
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: darkBlue),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 1,
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: "SF Pro Text",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: primaryBlue,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0.5,
          titleTextStyle: TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
          iconTheme: IconThemeData(color: darkBlue),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFD1D1D6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: primaryBlue, width: 1.5),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 1,
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(
              fontFamily: "SF Pro Text",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String selectedCategory = 'Length';
  String fromUnit = 'Meter';
  String toUnit = 'Kilometer';
  double inputValue = 0;
  double outputValue = 0;
  final TextEditingController _inputController = TextEditingController();
  List<String> conversionHistory = [];
  Set<String> favoriteConversions = {};
  bool showHistory = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool isLoading = false;

  final Map<String, Map<String, Map<String, double>>> conversionCategories = {
    'Length': {
      'Meter': {
        'Meter': 1,
        'Kilometer': 0.001,
        'Decimeter': 10,
        'Centimeter': 100,
        'Millimeter': 1000,
        'Micrometer': 1e6,
        'Nanometer': 1e9,
        'Picometer': 1e12,
        'Femtometer': 1e15,
        'Attometer': 1e18,
        'Decameter': 0.1,
        'Hectometer': 0.01,
        'Megameter': 1e-6,
        'Gigameter': 1e-9,
        'Terameter': 1e-12,
        'Petameter': 1e-15,
        'Exameter': 1e-18,
        'Zettameter': 1e-21,
        'Yottameter': 1e-24,
        'Light Year': 1.057e-16,
        'Astronomical Unit': 6.68459e-12,
        'Parsec': 3.24078e-17,
        'Angstrom': 1e10,
        'Fermi': 1e15,
        'Micron': 1e6,
        'X-unit': 9.979243e12,
        'Cubit': 1.874666,
        'Hand': 9.84252,
        'Span': 4.374453,
        'Finger': 44.99438,
        'Nail': 17.49781,
        'Palm': 13.12336,
        'Foot': 3.28084,
        'Yard': 1.093613,
        'Inch': 39.37008,
        'Mile': 0.000621371,
        'Nautical Mile': 0.000539957,
        'Fathom': 0.546807,
        'Rod': 0.1988388,
        'Chain': 0.0497097,
        'Furlong': 0.00497096,
        'Link': 4.97096,
        'Mil': 39370.08,
        'Point': 2834.646,
        'Pica': 236.2205,
        'Twip': 56692.91,
        'Barleycorn': 118.1102,
        'Ken': 0.4720633,
        'Roman Actus': 0.02818591,
        'Vara': 1.196309,
        'Arpent': 0.01710241,
        'Perch': 0.1988388,
        'Pole': 0.1988388,
        'Ell': 0.8748906,
        'Aln': 1.684132,
        'Famn': 0.5613772,
        'Caliber': 3937.008,
        'Cent': 100,
        'Didot Point': 2651.262,
        'Cicero': 222.2222,
        'Pixel': 3779.528,
        'Em': 2834.646,
        'En': 5669.291,
        'Agate': 5669.291,
        'Arshin': 1.406074,
        'Sazhen': 0.4686914,
        'Verst': 0.0009373828,
        'Vershok': 22.497,
        "Missouri": 22.49719,
        'Pyad': 5.624297,
        'Toise': 0.5130836,
        'Bohr': 1.889726e10,
        'Electron Radius': 3.548690e17,
        'Planck Length': 6.187927e34,
        'League': 0.0002071237,
        'Cable': 0.005399568,
        'Survey Foot': 3.280833333,
        'Survey Mile': 0.0006213699,
        'Russian Verst': 0.0009373828,
        'Japanese Ri': 0.0002546477,
        'Chinese Li': 0.002,
        'Nautical League': 0.0001799856,
        'Cable Length (International)': 0.005399568,
      },
    },
    'Area': {
      'Square Meter': {
        'Square Meter': 1,
        'Square Kilometer': 1e-6,
        'Square Decimeter': 100,
        'Square Centimeter': 10000,
        'Square Millimeter': 1e6,
        'Square Micrometer': 1e12,
        'Square Nanometer': 1e18,
        'Square Picometer': 1e24,
        'Square Femtometer': 1e30,
        'Square Attometer': 1e36,
        'Hectare': 0.0001,
        'Are': 0.01,
        'Barn': 1e28,
        'Square Mile': 3.861e-7,
        'Square Yard': 1.19599,
        'Square Foot': 10.76391,
        'Square Inch': 1550.003,
        'Acre': 0.000247105,
        'Square Rod': 0.03953686,
        'Square Chain': 0.002471054,
        'Square Perch': 0.03953686,
        'Square Pole': 0.03953686,
        'Square Furlong': 2.471054e-5,
        'Square Mile (US Survey)': 3.861006e-7,
        'Circular Inch': 1973.525,
        'Township': 1.0725e-8,
        'Section': 3.861e-7,
        'Homestead': 1.5444e-6,
        'Cuerda': 0.000254427,
        'Varas Castellanas Cuad': 1.4233,
        'Varas Conuqueras Cuad': 0.1588,
        'Arpent': 0.0002924925,
        'Pyeong': 0.3025,
        'Tsubo': 0.3025,
        'Tatami': 0.604999,
        'Shaku': 0.033058,
        'Cho': 0.000100833,
        'Tan': 0.00100833,
        'Se': 0.0100833,
        'Pyong': 0.3025,
        'Rai': 0.000625,
        'Ngan': 0.0025,
        'Square Wah': 0.25,
        'Square Hectometer': 0.0001,
        'Square Dekameter': 0.01,
        'Electron Cross Section': 1.503202e28,
        'Rood': 0.0009884215,
        'Square League': 4.290e-8,
        'Square Survey Foot': 10.763867316,
        'Morgen': 0.0004,
        'Chinese Mu': 0.0015,
        'Indian Bigha': 0.0004,
        'Square Nautical Mile': 2.915451e-7,
        'Dunam': 0.001,
        'Jo': 0.6172839506,
      },
    },
    'Volume': {
      'Liter': {
        'Liter': 1,
        'Milliliter': 1000,
        'Cubic Meter': 0.001,
        'Cubic Centimeter': 1000,
        'Cubic Millimeter': 1e6,
        'Cubic Kilometer': 1e-12,
        'Cubic Decimeter': 1,
        'Cubic Decameter': 0.001,
        'Cubic Hectometer': 1e-6,
        'Cubic Gigameter': 1e-18,
        'Deciliter': 10,
        'Centiliter': 100,
        'Microliter': 1e6,
        'Nanoliter': 1e9,
        'Picoliter': 1e12,
        'Femtoliter': 1e15,
        'Attoliter': 1e18,
        'Gallon (US)': 0.264172,
        'Gallon (UK)': 0.219969,
        'Quart (US)': 1.056688,
        'Quart (UK)': 0.879877,
        'Pint (US)': 2.113376,
        'Pint (UK)': 1.759754,
        'Cup (US)': 4.226753,
        'Cup (UK)': 3.519508,
        'Fluid Ounce (US)': 33.81402,
        'Fluid Ounce (UK)': 35.19508,
        'Tablespoon (US)': 67.62805,
        'Tablespoon (UK)': 56.31213,
        'Teaspoon (US)': 202.8841,
        'Teaspoon (UK)': 168.9364,
        'Barrel (Oil)': 0.006289811,
        'Barrel (US)': 0.008386414,
        'Barrel (UK)': 0.006110256,
        'Hogshead (US)': 0.004193207,
        'Hogshead (UK)': 0.003055128,
        'Gill (US)': 8.453506,
        'Gill (UK)': 7.039016,
        'Minim (US)': 16230.73,
        'Minim (UK)': 16893.64,
        'Cord': 0.0002758958,
        'Cord Foot': 0.002207166,
        'Cubic Foot': 0.03531467,
        'Cubic Inch': 61.02374,
        'Cubic Yard': 0.001307951,
        'Acre-foot': 8.107132e-7,
        'Dram (US)': 270.5122,
        'Dram (UK)': 281.5606,
        'Drop': 20000,
        'Dash (US)': 3246.146,
        'Dash (UK)': 3378.728,
        'Pinch (US)': 3246.146,
        'Pinch (UK)': 3378.728,
        'Smidgen (US)': 6492.292,
        'Smidgen (UK)': 6757.455,
        'Shot': 22.54268,
        'Jigger': 22.54268,
        'Pony': 33.81402,
        'Fifths': 1.32086,
        'Tun': 0.001048301,
        'Butt': 0.002096603,
        'Pipe': 0.002096603,
        'Peck (US)': 0.1135104,
        'Peck (UK)': 0.1099846,
        'Bushel (US)': 0.02837759,
        'Bushel (UK)': 0.02749616,
        'Kilderkin': 0.01222051,
        'Firkin': 0.02444103,
        'Seam': 0.003552924,
        'Strike (US)': 0.0141888,
        'Strike (UK)': 0.01374808,
        'Sack (UK)': 0.005506105,
        'Sack (US)': 0.009459198,
        'Quarter (UK)': 0.002753052,
        'Coomb': 0.006874039,
        'Chaldron': 0.0003716288,
        'Bucket (UK)': 0.05499231,
        'Bucket (US)': 0.05283441,
        'Pottle': 0.439938,
        'Gill (Imperial)': 7.039016,
        'Noggin': 7.039016,
        'Jack': 16.89364,
        'Pint (Dry)': 1.816166,
        'Quart (Dry)': 0.908083,
        'Stere': 0.001,
        'Decistere': 0.01,
        'Board Foot': 0.423776,
        'Register Ton': 0.0003531467,
        'Displacement Ton': 0.001010894,
        'Freight Ton': 0.000882866,
        'Japanese Koku': 0.005541,
        'Chinese Dan': 0.01,
        'UK Fluid Scruple': 844.6818,
        'US Fluid Dram': 270.5122,
        'Imperial Fluid Scruple': 844.6818,
        'Sho': 0.5541125541,
      },
    },
    'Mass': {
      'Kilogram': {
        'Kilogram': 1,
        'Gram': 1000,
        'Milligram': 1e6,
        'Microgram': 1e9,
        'Nanogram': 1e12,
        'Picogram': 1e15,
        'Femtogram': 1e18,
        'Attogram': 1e21,
        'Centigram': 100000,
        'Decigram': 10000,
        'Decagram': 100,
        'Hectogram': 10,
        'Tonne': 0.001,
        'Megatonne': 1e-6,
        'Gigatonne': 1e-9,
        'Pound': 2.2046226218,
        'Ounce': 35.27396195,
        'Grain': 15432.3583529,
        'Stone': 0.1574730444,
        'Short Ton': 0.0011023113,
        'Long Ton': 0.0009842065,
        'Hundredweight (Short)': 0.0220462262,
        'Hundredweight (Long)': 0.0196841306,
        'Slug': 0.0685217659,
        'Troy Ounce': 32.1507465686,
        'Troy Pound': 2.6792288807,
        'Carat': 5000,
        'Pennyweight': 643.0149313725,
        'Japanese Kin': 1.6666666667,
        'Chinese Jin': 2,
        'Indian Tola': 85.735324183,
        'Quintal': 0.01,
        'Dram (Avoirdupois)': 0.5643834,
        'Ser': 1.0718113612,
        'Maund': 0.0267952835,
      },
    },
    'Time': {
      'Second': {
        'Second': 1,
        'Millisecond': 1000,
        'Microsecond': 1e6,
        'Nanosecond': 1e9,
        'Picosecond': 1e12,
        'Femtosecond': 1e15,
        'Attosecond': 1e18,
        'Minute': 0.0166666667,
        'Hour': 0.0002777778,
        'Day': 1.157407e-5,
        'Week': 1.653439e-6,
        'Month': 3.802571e-7,
        'Year': 3.168876e-8,
        'Decade': 3.168876e-9,
        'Century': 3.168876e-10,
        'Millennium': 3.168876e-11,
        'Fortnight': 8.267195e-7,
        'Sidereal Day': 1.160576e-5,
        'Lunar Month': 3.919349e-7,
        'Planck Time': 1.85487e43,
        'Solar Year': 3.168876e-8,
        'Julian Year': 3.168808e-8,
      },
    },
    'Speed': {
      'Meter per Second': {
        'Meter per Second': 1,
        'Kilometer per Hour': 3.6,
        'Mile per Hour': 2.236936292,
        'Knot': 1.943844492,
        'Foot per Second': 3.280839895,
        'Centimeter per Second': 100,
        'Kilometer per Second': 0.001,
        'Inch per Second': 39.37007874,
        'Mach': 0.0029154519,
        'Speed of Light': 3.335640951e-9,
        'Beaufort': 3,
        'Foot per Minute': 196.8504,
        'Meter per Minute': 60,
      },
    },
    'Pressure': {
      'Pascal': {
        'Pascal': 1,
        'Kilopascal': 0.001,
        'Megapascal': 1e-6,
        'Bar': 1e-5,
        'Millibar': 0.01,
        'Atmosphere': 9.869232667e-6,
        'Torr': 0.0075006168,
        'Millimeter of Mercury': 0.0075006168,
        'Inch of Mercury': 0.0002952998,
        'Pound per Square Inch': 0.0001450377377,
        'Kilogram per Square Centimeter': 1.019716e-5,
        'Technical Atmosphere': 1.019716e-5,
        'Barye': 10,
      },
    },
    'Energy': {
      'Joule': {
        'Joule': 1,
        'Kilojoule': 0.001,
        'Megajoule': 1e-6,
        'Gigajoule': 1e-9,
        'Calorie': 0.2388459,
        'Kilocalorie': 0.0002388459,
        'Watt-hour': 0.0002777778,
        'Kilowatt-hour': 2.777777e-7,
        'Electronvolt': 6.241509074e18,
        'Erg': 1e7,
        'British Thermal Unit': 0.000947817,
        'Therm': 9.478171e-9,
        'Foot-pound': 0.7375621493,
        'Horsepower-hour': 3.725061412e-7,
        'Planck Energy': 5.112205e-10,
        'Ton of TNT': 2.390057e-10,
        'Hartree': 2.293712e17,
      },
    },
    'Power': {
      'Watt': {
        'Watt': 1,
        'Kilowatt': 0.001,
        'Megawatt': 1e-6,
        'Gigawatt': 1e-9,
        'Horsepower': 0.0013410220896,
        'Metric Horsepower': 0.0013596216173,
        'Foot-pound per Second': 0.7375621493,
        'Erg per Second': 1e7,
        'Calorie per Second': 0.2388459,
        'British Thermal Unit per Hour': 3.412141633,
        'Pferdestärke (PS)': 0.0013596216,
      },
    },
    'Data Storage': {
      'Byte': {
        'Byte': 1,
        'Bit': 8,
        'Kilobyte': 0.001,
        'Kibibyte': 0.0009765625,
        'Megabyte': 1e-6,
        'Mebibyte': 9.536743164e-7,
        'Gigabyte': 1e-9,
        'Gibibyte': 9.313225746e-10,
        'Terabyte': 1e-12,
        'Tebibyte': 9.094947017e-13,
        'Petabyte': 1e-15,
        'Pebibyte': 8.881784197e-16,
        'Exabyte': 1e-18,
        'Exbibyte': 8.673617379e-19,
        'Zettabyte': 1e-21,
        'Zebibyte': 8.470329473e-22,
        'Yottabyte': 1e-24,
        'Yobibyte': 8.271806125e-25,
        'Nibble': 2,
        'Brontobyte': 1e-27,
        'Geopbyte': 1e-30,
      },
    },
    'Angle': {
      'Degree': {
        'Degree': 1,
        'Radian': 0.01745329252,
        'Gradian': 1.111111111,
        'Arcminute': 60,
        'Arcsecond': 3600,
        'Turn': 0.0027777778,
        'Mil': 17.7777777778,
        'Revolution': 0.0027777778,
        'Quadrant': 0.0111111111,
        'Right Angle': 0.0111111111,
        'Binary Degree (Brad)': 1.40625,
      },
    },
    'Fuel Consumption': {
      'Liters per 100 Kilometers': {
        'Liters per 100 Kilometers': 1,
        'Miles per Gallon (US)': 235.214583333,
        'Miles per Gallon (UK)': 282.480936332,
        'Kilometers per Liter': 100,
        'Gallons per Mile (US)': 0.0042514371,
        'Liters per Mile': 0.01609344,
        'Liters per Kilometer': 100,
        'Gallons per 100 Miles (US)': 23.521458333,
      },
    },
    'Typography': {
      'Point': {
        'Point': 1,
        'Pica': 0.0833333333,
        'Twip': 20,
        'Didot Point': 1.88172043,
        'Cicero': 0.1568100357,
        'Em': 1,
        'En': 2,
        'Agate': 0.1818181818,
      },
    },
    'Force': {
      'Newton': {
        'Newton': 1,
        'Kilonewton': 0.001,
        'Meganewton': 1e-6,
        'Dyne': 100000,
        'Pound-force': 0.2248089431,
        'Ounce-force': 3.5969430896,
        'Kilogram-force': 0.1019716213,
        'Ton-force (metric)': 0.0001019716213,
        'Poundal': 7.233033989,
        'Sthène': 0.1,
      },
    },
    'Frequency': {
      'Hertz': {
        'Hertz': 1,
        'Kilohertz': 0.001,
        'Megahertz': 1e-6,
        'Gigahertz': 1e-9,
        'Revolutions per Minute': 0.0166666667,
        'Revolutions per Second': 1,
        'Cycle per Second': 1,
        'Radian per Second': 0.1591549433,
      },
    },
    'Electric Current': {
      'Ampere': {
        'Ampere': 1,
        'Milliampere': 1000,
        'Kiloampere': 0.001,
        'Microampere': 1e6,
        'Nanoampere': 1e9,
        'Picoampere': 1e12,
        'Femtoampere': 1e15,
      },
    },
    'Voltage': {
      'Volt': {
        'Volt': 1,
        'Millivolt': 1000,
        'Kilovolt': 0.001,
        'Microvolt': 1e6,
        'Nanovolt': 1e9,
        'Picovolt': 1e12,
      },
    },
    'Resistance': {
      'Ohm': {
        'Ohm': 1,
        'Kilohm': 0.001,
        'Megohm': 1e-6,
        'Microhm': 1e6,
        'Nanoohm': 1e9,
      },
    },
    'Capacitance': {
      'Farad': {
        'Farad': 1,
        'Microfarad': 1e6,
        'Nanofarad': 1e9,
        'Picofarad': 1e12,
        'Femtofarad': 1e15,
      },
    },
    'Inductance': {
      'Henry': {
        'Henry': 1,
        'Millihenry': 1000,
        'Microhenry': 1e6,
        'Nanohenry': 1e9,
      },
    },
    'Magnetic Flux': {
      'Weber': {'Weber': 1, 'Maxwell': 100000000, 'Tesla-square-meter': 1},
    },
    'Luminous Intensity': {
      'Candela': {'Candela': 1, 'Lumen per Steradian': 1},
    },
    'Illuminance': {
      'Lux': {
        'Lux': 1,
        'Foot-candle': 0.09290304,
        'Phot': 0.0001,
        'Nox': 0.001,
      },
    },
    'Radiation': {
      'Gray': {'Gray': 1, 'Sievert': 1, 'Rad': 100, 'Rem': 100},
    },
    'Torque': {
      'Newton-meter': {
        'Newton-meter': 1,
        'Kilonewton-meter': 0.001,
        'Pound-foot': 0.7375621493,
        'Pound-inch': 8.8507457916,
        'Kilogram-meter': 0.1019716213,
      },
    },
    'Density': {
      'Kilogram per Cubic Meter': {
        'Kilogram per Cubic Meter': 1,
        'Gram per Cubic Centimeter': 0.001,
        'Pound per Cubic Foot': 0.06242796,
        'Pound per Cubic Inch': 3.6127292e-5,
        'Gram per Liter': 1,
        'Kilogram per Liter': 0.001,
        'Ounce per Cubic Foot': 0.9988473692,
        'Slug per Cubic Foot': 0.0019403203,
      },
    },
    'Flow Rate (Volume)': {
      'Cubic Meter per Second': {
        'Cubic Meter per Second': 1,
        'Liter per Second': 1000,
        'Liter per Minute': 60000,
        'Cubic Foot per Second': 35.314666721,
        'Cubic Foot per Minute': 2118.87997276,
        'Gallon per Minute (US)': 15850.3231415,
        'Gallon per Minute (UK)': 13198.1548976,
      },
    },
    'Flow Rate (Mass)': {
      'Kilogram per Second': {
        'Kilogram per Second': 1,
        'Pound per Second': 2.2046226218,
        'Pound per Hour': 7936.64143866,
        'Kilogram per Hour': 3600,
        'Gram per Second': 1000,
        'Ton per Hour (Metric)': 3.6,
      },
    },
    'Thermal Conductivity': {
      'Watt per Meter-Kelvin': {
        'Watt per Meter-Kelvin': 1,
        'BTU per Hour-Foot-°F': 0.5777893165,
        'Calorie per Second-Centimeter-°C': 0.002388459,
        'Kilowatt per Meter-Kelvin': 0.001,
      },
    },
    'Viscosity (Dynamic)': {
      'Pascal-second': {
        'Pascal-second': 1,
        'Poise': 10,
        'Centipoise': 1000,
        'Pound-force Second per Square Foot': 0.0208854342,
        'Pound per Foot-Second': 0.6719689751,
      },
    },
    'Viscosity (Kinematic)': {
      'Square Meter per Second': {
        'Square Meter per Second': 1,
        'Stokes': 10000,
        'Centistokes': 1e6,
        'Square Foot per Second': 10.7639104167,
      },
    },
  };

  @override
  void initState() {
    super.initState();
    Get.find<GoogleAdsController>().showAds();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),  
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _inputController.addListener(convert);
    _loadFavorites();
    _loadHistory();
  }

  @override
  void dispose() {
    _inputController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void convert() {
    setState(() {
      isLoading = true;
    });

    if (_inputController.text.isEmpty) {
      setState(() {
        outputValue = 0;
        isLoading = false;
      });
      return;
    }

    double input = double.tryParse(_inputController.text) ?? 0;
    double? fromFactor =
        conversionCategories[selectedCategory]?[fromUnit]?[fromUnit];
    double? toFactor =
        conversionCategories[selectedCategory]?[fromUnit]?[toUnit];

    if (fromFactor == null || toFactor == null) {
      setState(() {
        outputValue = 0;
        isLoading = false;
      });
      return;
    }

    setState(() {
      outputValue = input * (toFactor / fromFactor);
      isLoading = false;
      _addToHistory(input);
    });
    _animationController.forward(from: 0);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteConversions = (prefs.getStringList('favorites') ?? []).toSet();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favoriteConversions.toList());
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      conversionHistory = prefs.getStringList('history') ?? [];
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', conversionHistory);
  }

  void _addToHistory(double input) {
    String conversion =
        '$input $fromUnit = $outputValue $toUnit ($selectedCategory)';
    setState(() {
      conversionHistory.insert(0, conversion);
      if (conversionHistory.length > 50) {
        conversionHistory.removeLast();
      }
    });
    _saveHistory();
  }

  void _toggleFavorite() {
    String conversionKey = '$selectedCategory:$fromUnit:$toUnit';
    setState(() {
      if (favoriteConversions.contains(conversionKey)) {
        favoriteConversions.remove(conversionKey);
      } else {
        favoriteConversions.add(conversionKey);
      }
    });
    _saveFavorites();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF007AFF);
    const Color darkBlue = Color(0xFF0A4B9A);

    List<String> categories = conversionCategories.keys.toList();
    List<String> units =
        conversionCategories[selectedCategory]?.keys.toList() ?? [];

    if (!units.contains(fromUnit)) {
      fromUnit = units.isNotEmpty ? units.first : '';
    }
    if (!(conversionCategories[selectedCategory]?[fromUnit]
            ?.containsKey(toUnit) ??
        false)) {
      toUnit =
          conversionCategories[selectedCategory]?[fromUnit]?.keys.first ?? '';
    }

    String conversionKey = '$selectedCategory:$fromUnit:$toUnit';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back)),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.white, // iOS style white app bar

        leadingWidth: 50,
        centerTitle: true,
        title: Text(
          "Unit Converter".toUpperCase(),
          style: const TextStyle(
            color: darkBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
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
          IconButton(
            icon: Icon(showHistory ? Icons.calculate : Icons.history,
                color: darkBlue),
            tooltip: showHistory ? 'Calculator' : 'History',
            onPressed: () {
              setState(() {
                showHistory = !showHistory;
                if (showHistory) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
              });
            },
          ),
          IconButton(
            icon: Icon(
              favoriteConversions.contains(conversionKey)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: favoriteConversions.contains(conversionKey)
                  ? Colors.redAccent
                  : darkBlue,
            ),
            tooltip: favoriteConversions.contains(conversionKey)
                ? 'Remove Favorite'
                : 'Add Favorite',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
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
                      "Converting...",
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Category Dropdown
                    Container(
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          items: categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: const TextStyle(
                                  color: darkBlue,
                                  fontFamily: "SF Pro Text",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                selectedCategory = newValue;
                                fromUnit =
                                    conversionCategories[selectedCategory]
                                            ?.keys
                                            .first ??
                                        '';
                                toUnit = conversionCategories[selectedCategory]
                                            ?[fromUnit]
                                        ?.keys
                                        .first ??
                                    '';
                              });
                              convert();
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Category',
                            labelStyle: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontFamily: "SF Pro Text",
                              fontSize: 14.0,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  const BorderSide(color: Color(0xFFD1D1D6)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: primaryBlue, width: 1.5),
                            ),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          menuMaxHeight: 300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Conversion Input Card
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
                        children: [
                          // From Unit and Input
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    value: fromUnit,
                                    decoration: InputDecoration(
                                      labelText: 'From',
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontFamily: "SF Pro Text",
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                    items: units.map((String unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          style: const TextStyle(
                                            color: darkBlue,
                                            fontFamily: "SF Pro Text",
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          fromUnit = newValue;
                                          if (!(conversionCategories[
                                                          selectedCategory]
                                                      ?[fromUnit]
                                                  ?.containsKey(toUnit) ??
                                              false)) {
                                            toUnit = conversionCategories[
                                                            selectedCategory]
                                                        ?[fromUnit]
                                                    ?.keys
                                                    .first ??
                                                '';
                                          }
                                        });
                                        convert();
                                      }
                                    },
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    menuMaxHeight: 300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: _inputController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Value',
                                    labelStyle: const TextStyle(
                                      color: Color(0xFF8E8E93),
                                      fontFamily: "SF Pro Text",
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: Color(0xFF8E8E93)),
                                      onPressed: () {
                                        _inputController.clear();
                                        convert();
                                      },
                                    ),
                                  ),
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // To Unit and Output
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButtonFormField<String>(
                                    value: toUnit,
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(() {
                                          toUnit = newValue;
                                        });
                                        convert();
                                      }
                                    },
                                    items:
                                        conversionCategories[selectedCategory]
                                                ?[fromUnit]
                                            ?.keys
                                            .map((String unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(
                                          unit,
                                          style: const TextStyle(
                                            color: darkBlue,
                                            fontFamily: "SF Pro Text",
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    decoration: InputDecoration(
                                      labelText: 'To',
                                      labelStyle: const TextStyle(
                                        color: Color(0xFF8E8E93),
                                        fontFamily: "SF Pro Text",
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                    ),
                                    isExpanded: true,
                                    dropdownColor: Colors.white,
                                    menuMaxHeight: 300,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFFF2F2F7),
                                    ),
                                    child: Text(
                                      outputValue
                                          .toStringAsFixed(8)
                                          .replaceAll(RegExp(r'\.?0*$'), ''),
                                      style: const TextStyle(
                                        color: primaryBlue,
                                        fontFamily: "SF Pro Text",
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Swap Button
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                String temp = fromUnit;
                                fromUnit = toUnit;
                                toUnit = temp;
                                if (_inputController.text.isNotEmpty) {
                                  double input =
                                      double.tryParse(_inputController.text) ??
                                          0;
                                  _inputController.text =
                                      outputValue.toString();
                                  outputValue = input;
                                }
                              });
                              convert();
                            },
                            icon: const Icon(Icons.swap_horiz, size: 20),
                            label: const Text(
                              'Swap Units',
                              style: TextStyle(
                                fontFamily: "SF Pro Text",
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Favorites Section
                    if (favoriteConversions.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
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
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              child: Text(
                                'Favorites',
                                style: TextStyle(
                                  color: darkBlue,
                                  fontFamily: "SF Pro Text",
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: favoriteConversions.length,
                                itemBuilder: (context, index) {
                                  final fav =
                                      favoriteConversions.elementAt(index);
                                  final parts = fav.split(':');
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6.0),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        setState(() {
                                          selectedCategory = parts[0];
                                          fromUnit = parts[1];
                                          toUnit = parts[2];
                                        });
                                        convert();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: primaryBlue.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.star,
                                                size: 18,
                                                color: Colors.yellow[700]),
                                            const SizedBox(width: 8),
                                            Text(
                                              '${parts[1]} → ${parts[2]}',
                                              style: const TextStyle(
                                                color: darkBlue,
                                                fontFamily: "SF Pro Text",
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.w600,
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
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    // History Section
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Container(
                        padding: const EdgeInsets.all(12),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Conversion History',
                                  style: TextStyle(
                                    color: darkBlue,
                                    fontFamily: "SF Pro Text",
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_sweep,
                                      color: Colors.redAccent),
                                  tooltip: 'Clear History',
                                  onPressed: () {
                                    setState(() {
                                      conversionHistory.clear();
                                    });
                                    _saveHistory();
                                  },
                                ),
                              ],
                            ),
                            if (conversionHistory.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'No conversions yet.',
                                  style: TextStyle(
                                    color: const Color(0xFF8E8E93),
                                    fontFamily: "SF Pro Text",
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: conversionHistory.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {
                                    final parts =
                                        conversionHistory[index].split(' = ');
                                    final input =
                                        double.parse(parts[0].split(' ')[0]);
                                    final category = parts[1]
                                        .split(' (')[1]
                                        .replaceAll(')', '');
                                    final from = parts[0].split(' ')[1];
                                    final to =
                                        parts[1].split(' ')[1].split(' (')[0];
                                    setState(() {
                                      selectedCategory = category;
                                      fromUnit = from;
                                      toUnit = to;
                                      _inputController.text = input.toString();
                                      showHistory = false;
                                      _animationController.reverse();
                                    });
                                    convert();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        Icon(Icons.history,
                                            color: primaryBlue, size: 20),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            conversionHistory[index],
                                            style: const TextStyle(
                                              color: darkBlue,
                                              fontFamily: "SF Pro Text",
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: primaryBlue.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: primaryBlue,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: showHistory
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 500),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
