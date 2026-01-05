import 'dart:convert';

import 'package:uuid/uuid.dart';

class ServerConfig {
  final String id;
  final String name;
  final String url;
  final bool isEnabled;

  ServerConfig({
    String? id,
    required this.name,
    required this.url,
    required this.isEnabled,
  }) : id = id ?? const Uuid().v4();

  String get displayName {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) return trimmed;
    return hostPortFromUrl(url) ?? url;
  }

  ServerConfig copyWith({
    String? name,
    String? url,
    bool? isEnabled,
  }) {
    return ServerConfig(
      id: id,
      name: name ?? this.name,
      url: url ?? this.url,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'isEnabled': isEnabled,
    };
  }

  factory ServerConfig.fromJson(Map<String, dynamic> json) {
    return ServerConfig(
      id: json['id'],
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      isEnabled: json['isEnabled'] ?? false,
    );
  }

  static String? hostPortFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final host = uri.host;
      if (host.isEmpty) return null;
      final port = uri.hasPort ? uri.port : 0;
      if (port > 0) return '$host:$port';
      return host;
    } catch (_) {
      return null;
    }
  }

  static String encodeList(List<ServerConfig> configs) {
    return jsonEncode(configs.map((c) => c.toJson()).toList());
  }

  static List<ServerConfig> decodeList(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => ServerConfig.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}
