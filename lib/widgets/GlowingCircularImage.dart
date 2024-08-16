import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpd_viewer/widgets/LoadingDots.dart';
import 'package:mpd_viewer/widgets/LocalImageWithFallback.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math' as math;

class GlowingCircularImage extends StatefulWidget {
  final String? imagePath;
  final String songName;
  final double size;
  final double glowIntensity;

  const GlowingCircularImage({
    Key? key,
    required this.imagePath,
    required this.songName,
    this.size = 100.0,
    this.glowIntensity = 5.0,
  }) : super(key: key);

  @override
  _GlowingCircularImageState createState() => _GlowingCircularImageState();
}

class _GlowingCircularImageState extends State<GlowingCircularImage> {
  bool _isLoading = false;
  Color _glowColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(GlowingCircularImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imagePath != oldWidget.imagePath) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imagePath == null) {
      setState(() {
        _isLoading = false;
        _glowColor = Colors.transparent;
      });
      return;
    }
    // 画像ファイルが存在するか
    if (!File(widget.imagePath!).existsSync()) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Image file not found: ${widget.imagePath}');
      return;
    }

    try {
      ImageProvider imageProvider = FileImage(File(widget.imagePath!));
      final paletteGenerator =
          await PaletteGenerator.fromImageProvider(imageProvider);
      setState(() {
        // 画像の主要な色を取得
        Color dominantColor =
            paletteGenerator.dominantColor?.color ?? Colors.grey;

        // HSLカラーモデルに変換
        HSLColor hslColor = HSLColor.fromColor(dominantColor);

        // 彩度を上げる
        double newSaturation = math.min(1.0, hslColor.saturation + 0.3);

        // 明度を調整（暗すぎる場合は明るくする）
        double newLightness = hslColor.lightness < 0.5
            ? math.min(1.0, hslColor.lightness + 0.3)
            : hslColor.lightness;

        // 新しい色を作成
        _glowColor = hslColor
            .withSaturation(newSaturation)
            .withLightness(newLightness)
            .toColor();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.size + widget.glowIntensity * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _glowColor.withOpacity(0.4),
            blurRadius: widget.glowIntensity,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: (_isLoading || widget.imagePath == null)
                ? Center(
                    child: LoadingDots(
                    dotSize: 18,
                    dotColor: Theme.of(context).colorScheme.primary,
                  ))
                : LocalImageWithFallback(
                    imagePath: widget.imagePath!,
                    songName: widget.songName,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ),
    );
  }
}
