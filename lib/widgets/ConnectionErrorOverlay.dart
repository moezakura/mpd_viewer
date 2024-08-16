import 'package:flutter/material.dart';

class ConnectionErrorOverlay extends StatelessWidget {
  final bool isVisible;
  final String connectHost;
  final int connectPort;

  const ConnectionErrorOverlay(
      {Key? key,
      required this.isVisible,
      required this.connectHost,
      required this.connectPort})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: isVisible,
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.link_off,
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                '接続エラー',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              const Text(
                '再接続を試みています...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 14),
              Text(
                "接続先: $connectHost:$connectPort",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
