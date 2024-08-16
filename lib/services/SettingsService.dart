import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _connectHostKey = 'connectHost';
  static const String _connectPortKey = 'connectPort';

  Future<void> setConnectHost(String host) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectHostKey, host);
  }

  Future<String> getConnectHost() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_connectHostKey) ?? 'localhost';
  }

  Future<void> setConnectPort(int port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_connectPortKey, port);
  }

  Future<int> getConnectPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_connectPortKey) ?? 6600;
  }
}