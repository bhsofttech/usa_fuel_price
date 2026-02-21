import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/google_ads_controller.dart';
import 'package:usa_gas_price/widgets/time_card.dart';

import '../controller/time_controller.dart';

class WorldClockScreen extends StatelessWidget {
  const WorldClockScreen({super.key});

  final List<Map<String, String>> continents = const [
    {
      'name': 'Europe',
      'url': 'https://www.timeanddate.com/worldclock/?continent=europe'
    },
    {
      'name': 'North America',
      'url': 'https://www.timeanddate.com/worldclock/?continent=namerica'
    },
    {
      'name': 'South America',
      'url': 'https://www.timeanddate.com/worldclock/?continent=samerica&low=1'
    },
    {
      'name': 'Australia',
      'url':
          'https://www.timeanddate.com/worldclock/?continent=australasia&low=1'
    },
    {
      'name': 'Asia',
      'url': 'https://www.timeanddate.com/worldclock/?continent=asia'
    },
    {
      'name': 'Africa',
      'url': 'https://www.timeanddate.com/worldclock/?continent=africa&low=1'
    },
  ];
  final Color primaryBlue = const Color(0xFF007AFF);
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: continents.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'World',
            style: TextStyle(
              color: primaryBlue,
              fontFamily: "SF Pro Display",
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: primaryBlue,
              labelColor: primaryBlue,
              unselectedLabelColor: Colors.black,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                color: Colors.black,
                fontFamily: "SF Pro Display",
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              unselectedLabelStyle: const TextStyle(
                color: Colors.black,
                fontFamily: "SF Pro Display",
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
              tabs: continents.map((e) => Tab(text: e['name'])).toList(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: continents
                    .map((e) => ContinentTimeList(
                          regionName: e['name']!,
                          url: e['url']!,
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContinentTimeList extends StatefulWidget {
  final String regionName;
  final String url;

  const ContinentTimeList({
    super.key,
    required this.regionName,
    required this.url,
  });

  @override
  State<ContinentTimeList> createState() => _ContinentTimeListState();
}

class _ContinentTimeListState extends State<ContinentTimeList>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Fetch data if not already present
    final TimeController controller = Get.find();
    if (controller.continentData[widget.regionName] == null ||
        controller.continentData[widget.regionName]!.isEmpty) {
      // Using simpler fetch trigger
      // We should avoid setState in initState unless we listen to controller
      // But controller.fetch is async
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchContinentTime(widget.regionName, widget.url);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<TimeController>(
      builder: (controller) {
        bool isLoading = controller.continentLoading[widget.regionName] == true;
        var data = controller.continentData[widget.regionName] ?? [];

        if (isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF6366F1)),
                const SizedBox(height: 16),
                FadeIn(
                    child: Text("Loading ${widget.regionName}...",
                        style: const TextStyle(color: Colors.white54))),
              ],
            ),
          );
        }

        if (data.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.public_off, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text("No data for ${widget.regionName}",
                    style: const TextStyle(color: Colors.white54)),
                TextButton(
                  onPressed: () => controller.fetchContinentTime(
                      widget.regionName, widget.url),
                  child: const Text("Retry"),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final isFav = controller.favorites.any((e) => e.city == item.city);
            return TimeCard(
              item: item,
              isFav: isFav,
              onFavTap: () async {
                Get.find<GoogleAdsController>().navigateWithAd(
                    onAction: () async {
                  await controller.saveFavorites(info: item);
                });
              },
            );
          },
        );
      },
    );
  }
}
