import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:usa_gas_price/widgets/time_card.dart';

import '../controller/time_controller.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TimeController controller = Get.find();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.loadFavorites());
    final Color primaryBlue = const Color(0xFF007AFF);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: TextStyle(
            color: primaryBlue,
            fontFamily: "SF Pro Display",
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: GetBuilder<TimeController>(
        builder: (ctrl) {
          if (ctrl.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline,
                      size: 56, color: Color(0xFFD1D1D6)),
                  SizedBox(height: 12),
                  Text("No favorites yet",
                      style: TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 12),
            itemCount: ctrl.favorites.length,
            itemBuilder: (context, index) {
              final item = ctrl.favorites[index];
              return TimeCard(
                item: item,
                isFav: true, // Always fav in fav page
                onFavTap: () => ctrl.saveFavorites(info: item),
              );
            },
          );
        },
      ),
    );
  }
}
