import 'package:flutter/material.dart';

class SettingsIconButton extends StatelessWidget {
  final void Function(String, String) onSettingsSaved;
  final double top;
  final double right;
  final String defaultHostname;
  final String defaultPort;

  const SettingsIconButton({
    Key? key,
    required this.onSettingsSaved,
    this.top = 16.0,
    this.right = 16.0,
    this.defaultHostname = 'localhost',
    this.defaultPort = '6600',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      right: right,
      child: IconButton(
        icon: Icon(Icons.settings),
        onPressed: () => _showSettingsDialog(context),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    String hostname = defaultHostname;
    String port = defaultPort;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Settings'),
          content: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Hostname'),
                  initialValue: defaultHostname,
                  onChanged: (value) => hostname = value,
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Port'),
                  initialValue: defaultPort,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => port = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (hostname.isNotEmpty && port.isNotEmpty) {
                  onSettingsSaved(hostname, port);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter both hostname and port')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}