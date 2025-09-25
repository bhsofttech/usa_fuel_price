import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// A circular avatar that displays an SVG from a network URL.
/// Supports size, background color, border, and placeholders.
class CircleSvgAvatar extends StatelessWidget {
  final String url;
  final String stock;
  final double size;
  final BoxFit fit;

  const CircleSvgAvatar({
    super.key,
    required this.url,
    required this.stock,
    this.size = 48,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    // Outer container to draw optional border
    return CircleAvatar(
      backgroundColor: Colors.transparent,
      // CircleAvatar already clips to a circle; we add a bit of padding
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: SvgPicture.network(
          url,
          width: size, // safe bounds; actual circle is smaller due to padding
          height: size,
          fit: fit,
          placeholderBuilder: (context) => Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.2),
            ),
            child: Center(
              child: Text(stock[0]),
            ),
          ),
          // If the SVG fails to load, show a fallback icon
          colorFilter: null, // set if you want to tint monochrome SVGs
        ),
      ),
    );
  }
}
