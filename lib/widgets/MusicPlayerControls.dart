import 'package:flutter/material.dart';

class MusicPlayerControls extends StatelessWidget {
  final VoidCallback onPlayPause;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isPlaying;

  const MusicPlayerControls({
    Key? key,
    required this.onPlayPause,
    required this.onPrevious,
    required this.onNext,
    required this.value,
    required this.onChanged,
    required this.isPlaying,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // アイコンサイズ
    const double iconSize = 64;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: iconSize,
                onPressed: onPrevious,
              ),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: iconSize,
                onPressed: onPlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: iconSize,
                onPressed: onNext,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Slider(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}