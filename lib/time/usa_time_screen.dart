import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/controller/time_controller.dart'
    show TimeController;
import 'package:usa_gas_price/time/favorite_screen.dart';
import 'package:usa_gas_price/widgets/time_card.dart';

class USATimeScreen extends StatefulWidget {
  const USATimeScreen({super.key});

  @override
  State<USATimeScreen> createState() => _USATimeScreenState();
}

class _USATimeScreenState extends State<USATimeScreen> {
  final TimeController controller = Get.put(TimeController());
  final ScrollController _scrollController = ScrollController();
  final Color primaryBlue = const Color(0xFF007AFF);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTime();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'USA',
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryBlue),
            onPressed: () => controller.fetchTime(),
            tooltip: 'Refresh Time',
          ),
          IconButton(
            icon: Icon(Icons.favorite_rounded, color: primaryBlue),
            onPressed: () => Get.to(() => const FavoritesPage(),
                transition: Transition.cupertino),
            tooltip: 'Favorites',
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Obx(() {
        if (controller.showLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF007AFF),
                ),
                const SizedBox(height: 12),
                FadeIn(
                  child: const Text("Syncing...",
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      )),
                )
              ],
            ),
          );
        }

        return GetBuilder<TimeController>(
          builder: (ctrl) {
            if (ctrl.usaTimeInfo.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time_filled,
                        size: 56, color: Color(0xFFD1D1D6)),
                    const SizedBox(height: 12),
                    const Text("No data available",
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8E8E93),
                          fontWeight: FontWeight.w400,
                        )),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () => ctrl.fetchTime(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Retry"),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF007AFF),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }

            return ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: ctrl.usaTimeInfo.length,
              itemBuilder: (context, index) {
                final item = ctrl.usaTimeInfo[index];
                final isFav = ctrl.favorites.any((e) => e.city == item.city);

                return TimeCard(
                  item: item,
                  isFav: isFav,
                  onFavTap: () async {
                    await ctrl.saveFavorites(info: item);
                  },
                );
              },
            );
          },
        );
      }),
    );
  }
}
