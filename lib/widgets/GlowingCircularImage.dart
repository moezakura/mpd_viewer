import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'dart:math' as math;

class GlowingCircularImage extends StatefulWidget {
  final String? imagePath;
  final double size;
  final double glowIntensity;

  const GlowingCircularImage({
    Key? key,
    required this.imagePath,
    this.size = 100.0,
    this.glowIntensity = 5.0,
  }) : super(key: key);

  @override
  _GlowingCircularImageState createState() => _GlowingCircularImageState();
}

class _GlowingCircularImageState extends State<GlowingCircularImage> {
  bool _isLoading = false;
  bool _hasError = false;
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
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size + widget.glowIntensity * 2,
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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
          ),
          child: ClipOval(
            child: (_isLoading || widget.imagePath == null)
                ? Center(child: CircularProgressIndicator())
                : _hasError
                    ? Icon(Icons.error, color: Colors.red)
                    : Image(
                        image: FileImage(File(widget.imagePath!)),
                        fit: BoxFit.cover,
                      ),
          ),
        ),
      ),
    );
  }
}
