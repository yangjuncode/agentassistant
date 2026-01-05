import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/server_config.dart';

class ServerStorageService {
  Future<List<ServerConfig>> loadServerConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConfig.serverConfigsStorageKey);
    if (raw != null && raw.trim().isNotEmpty) {
      return ServerConfig.decodeList(raw);
    }

    final migrated = await _migrateLegacyConfigIfNeeded(prefs);
    if (migrated != null) return migrated;

    return [];
  }

  Future<void> saveServerConfigs(List<ServerConfig> configs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConfig.serverConfigsStorageKey,
      ServerConfig.encodeList(configs),
    );
  }

  Future<List<ServerConfig>?> _migrateLegacyConfigIfNeeded(
      SharedPreferences prefs) async {
    final legacyUrl = prefs.getString(AppConfig.serverUrlStorageKey);
    if (legacyUrl == null || legacyUrl.trim().isEmpty) {
      return null;
    }

    final configs = [
      ServerConfig(
        name: '',
        url: legacyUrl,
        isEnabled: true,
      ),
    ];

    await prefs.setString(
      AppConfig.serverConfigsStorageKey,
      ServerConfig.encodeList(configs),
    );

    return configs;
  }
}
