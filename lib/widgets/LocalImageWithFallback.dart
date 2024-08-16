import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';

class LocalImageWithFallback extends StatelessWidget {
  final String imagePath;
  final String songName;
  final double width;
  final double height;
  final BoxFit fit;

  const LocalImageWithFallback({
    Key? key,
    required this.imagePath,
    required this.songName,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Center(
            child: Image.asset(
              _getRandomFallbackImage(),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  String _getRandomFallbackImage() {
    final List<String> fallbackImages = [
      'images/fallback_01.png',
      'images/fallback_02.png',
      'images/fallback_03.png',
    ];

    // Use the song name as a seed for the random number generator
    final random = Random(songName.hashCode);
    final index = random.nextInt(fallbackImages.length);

    return fallbackImages[index];
  }
}
