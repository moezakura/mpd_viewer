import 'package:flutter/material.dart';

class ConnectionErrorOverlay extends StatelessWidget {
  final bool isVisible;

  const ConnectionErrorOverlay({Key? key, required this.isVisible})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.link_off,
                size: 100,
                color: Colors.white,
              ),
              SizedBox(height: 20),
              Text(
                '接続エラー',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 10),
              Text(
                '再接続を試みています...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
