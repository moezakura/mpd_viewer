import 'dart:io';

import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:mpd_viewer/widgets/LoadingDots.dart';
import 'package:mpd_viewer/widgets/LocalImageWithFallback.dart';

class ConditionalMarquee extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double width;

  const ConditionalMarquee({
    Key? key,
    required this.text,
    this.style,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    if (textPainter.width <= width) {
      return Text(
        text,
        style: style,
        overflow: TextOverflow.ellipsis,
      );
    } else {
      return SizedBox(
        width: width,
        child: Marquee(
          text: text,
          style: style,
          scrollAxis: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          blankSpace: 20.0,
          velocity: 30.0,
          pauseAfterRound: Duration(seconds: 1),
          startPadding: 10.0,
          accelerationDuration: Duration(seconds: 1),
          accelerationCurve: Curves.linear,
          decelerationDuration: Duration(milliseconds: 500),
          decelerationCurve: Curves.easeOut,
        ),
      );
    }
  }
}

class SimpleSongCardWidget extends StatelessWidget {
  final String title;
  final String? imagePath;
  final String album;
  final String artist;

  const SimpleSongCardWidget({
    Key? key,
    required this.title,
    required this.album,
    required this.artist,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      width: 340,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(1),
      ),
      child: Row(
        children: [
          ClipOval(
            child: (imagePath == null)
                ? Center(
                    child: LoadingDots(
                    dotColor: Theme.of(context).colorScheme.primary,
                  ))
                : LocalImageWithFallback(
                    imagePath: imagePath!,
                    songName: title,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 20,
                  child: ConditionalMarquee(
                    text: title,
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1
                        ?.copyWith(fontWeight: FontWeight.bold),
                    width: 252, // 340 - (60 + 16 + 12)
                  ),
                ),
                SizedBox(height: 4),
                SizedBox(
                  height: 20,
                  child: ConditionalMarquee(
                    text: '$artist • $album',
                    style: Theme.of(context).textTheme.caption?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    width: 252, // 340 - (60 + 16 + 12)
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
