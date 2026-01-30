import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectDirectoryIndexProvider extends ChangeNotifier {
  static const String _ttlHoursKey = 'path_index_cache_ttl_hours';
  static const String _ignoredDirsKey = 'path_autocomplete_ignored_dirs';
  static const String _watchEnabledDesktopKey =
      'path_index_watch_enabled_desktop';

  static const int defaultTtlHours = 8;
  static const List<String> defaultIgnoredDirs = [
    '.git',
    '.github',
    '.agent',
    '.tmp',
    'node_modules',
    'build',
    '.dart_tool',
    '.vscode',
    '.windsurf',
    '.antigravity',
    '.idea',
    '.gemini',
    '.trae',
    '.opencode',
    '.cursor',
    '.codex',
    '.claude',
    'cmake-build-debug',
    'cmake-build-release',
  ];

  final Map<String, _RootCache> _caches = {};
  Timer? _cleanupTimer;

  int _ttlHours = defaultTtlHours;
  Set<String> _ignoredDirs = defaultIgnoredDirs.toSet();
  bool _watchEnabledDesktop = true;

  ProjectDirectoryIndexProvider() {
    _loadSettings();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpired();
    });
  }

  bool isWatching(String root) {
    final cache = _caches[root];
    return cache?.isWatching ?? false;
  }

  int get ttlHours => _ttlHours;
  Set<String> get ignoredDirs => Set.unmodifiable(_ignoredDirs);
  bool get watchEnabledDesktop => _watchEnabledDesktop;

  List<RootCacheInfo> get cacheInfos {
    final infos = _caches.entries
        .map((e) => RootCacheInfo._fromCache(e.key, e.value))
        .toList();
    infos.sort((a, b) => b.lastSeenAt.compareTo(a.lastSeenAt));
    return infos;
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    for (final cache in _caches.values) {
      cache.dispose();
    }
    super.dispose();
  }

  Future<void> setTtlHours(int hours) async {
    if (hours <= 0 || _ttlHours == hours) return;
    _ttlHours = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_ttlHoursKey, hours);
    _cleanupExpired();
    notifyListeners();
  }

  Future<void> setIgnoredDirEnabled(String name, bool enabled) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    final updated = Set<String>.from(_ignoredDirs);
    if (enabled) {
      updated.add(normalized);
    } else {
      updated.remove(normalized);
    }
    if (setEquals(updated, _ignoredDirs)) return;
    _ignoredDirs = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_ignoredDirsKey, _ignoredDirs.toList()..sort());

    // Invalidate existing indexes so ignore-list changes take effect.
    for (final cache in _caches.values) {
      cache.builtAt = null;
    }
    for (final cache in _caches.values) {
      unawaited(_ensureIndexed(cache, force: true));
    }
    notifyListeners();
  }

  Future<void> setWatchEnabledDesktop(bool enabled) async {
    if (_watchEnabledDesktop == enabled) return;
    _watchEnabledDesktop = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_watchEnabledDesktopKey, enabled);

    if (!_isDesktopPlatform()) {
      notifyListeners();
      return;
    }

    for (final cache in _caches.values) {
      await cache.updateWatching(enabled);
    }
    notifyListeners();
  }

  bool rootExists(String root) {
    if (root.trim().isEmpty) return false;
    return Directory(root).existsSync();
  }

  void touchRoot(String root) {
    final cache = _caches[root];
    final now = DateTime.now();
    if (cache != null) {
      cache.lastSeenAt = now;
      return;
    }

    if (!rootExists(root)) return;

    final newCache = _RootCache(
      root: root,
      lastSeenAt: now,
      onInvalidate: () {
        _scheduleRefresh(root);
      },
    );
    _caches[root] = newCache;
    unawaited(_ensureIndexed(newCache));
    _cleanupExpired();
    notifyListeners();
  }

  bool isIndexBuilding(String root) {
    final cache = _caches[root];
    return cache?.isBuilding ?? false;
  }

  Future<void> refreshRoot(String root) async {
    final cache = _caches[root];
    if (cache == null) return;
    await _ensureIndexed(cache, force: true);
  }

  void _scheduleRefresh(String root) {
    final cache = _caches[root];
    if (cache == null) return;
    if (!_shouldWatch()) return;

    cache.builtAt = null;
    if (cache.isBuilding) return;
    // Fire-and-forget refresh; UI will update when rebuilt.
    unawaited(_ensureIndexed(cache, force: true));
  }

  Future<void> clearRoot(String root) async {
    final cache = _caches.remove(root);
    cache?.dispose();
    notifyListeners();
  }

  bool directoryHasChildren(String root, String dirRelativePath) {
    if (!rootExists(root)) return false;
    final cache = _caches[root];
    if (cache == null) return false;
    if (dirRelativePath.trim().isEmpty) return false;

    final prefix =
        dirRelativePath.endsWith('/') ? dirRelativePath : '$dirRelativePath/';
    final prefixLower = prefix.toLowerCase();

    for (final e in cache.entries) {
      if (e.lower.startsWith(prefixLower)) return true;
    }
    return false;
  }

  List<PathSuggestion> search(String root, String query, {int limit = 20}) {
    if (!rootExists(root)) return const [];
    touchRoot(root);

    final cache = _caches[root];
    if (cache == null) return const [];

    _ensureIndexed(cache);
    return cache.search(query, limit: limit);
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ttlHours = prefs.getInt(_ttlHoursKey) ?? defaultTtlHours;

      final ignored = prefs.getStringList(_ignoredDirsKey);
      if (ignored != null && ignored.isNotEmpty) {
        _ignoredDirs =
            ignored.map((e) => e.trim()).where((e) => e.isNotEmpty).toSet();
      } else {
        _ignoredDirs = defaultIgnoredDirs.toSet();
      }

      _watchEnabledDesktop =
          prefs.getBool(_watchEnabledDesktopKey) ?? _watchEnabledDesktop;
    } catch (_) {
      _ttlHours = defaultTtlHours;
      _ignoredDirs = defaultIgnoredDirs.toSet();
      _watchEnabledDesktop = true;
    }

    notifyListeners();
  }

  Future<void> _ensureIndexed(_RootCache cache, {bool force = false}) async {
    final ttl = Duration(hours: _ttlHours);
    final expired = cache.builtAt == null ||
        DateTime.now().difference(cache.builtAt!) > ttl;

    if (!force && cache.isBuilding) return;
    if (!force && !expired && cache.isReady) {
      await cache.updateWatching(_shouldWatch());
      return;
    }

    if (!rootExists(cache.root)) return;

    final generation = ++cache.buildGeneration;
    cache.isBuilding = true;
    notifyListeners();

    try {
      final result = await compute<_IndexRequest, _IndexResult>(
        _buildIndexInIsolate,
        _IndexRequest(
          root: cache.root,
          ignoredDirNames: _ignoredDirs.toList(),
        ),
      );

      if (cache.buildGeneration != generation) return;

      cache.applyIndex(_toIndexedEntries(result.entries));
      cache.builtAt = DateTime.now();
      cache.isBuilding = false;
      await cache.updateWatching(_shouldWatch());
      notifyListeners();
    } catch (_) {
      if (cache.buildGeneration != generation) return;
      cache.isBuilding = false;
      notifyListeners();
    }
  }

  bool _shouldWatch() {
    return _watchEnabledDesktop && _isDesktopPlatform();
  }

  bool _isDesktopPlatform() {
    return Platform.isLinux || Platform.isMacOS || Platform.isWindows;
  }

  void _cleanupExpired() {
    final ttl = Duration(hours: _ttlHours);
    final now = DateTime.now();

    final toRemove = <String>[];
    _caches.forEach((root, cache) {
      if (now.difference(cache.lastSeenAt) > ttl) {
        toRemove.add(root);
      }
    });

    if (toRemove.isEmpty) return;

    for (final root in toRemove) {
      final cache = _caches.remove(root);
      cache?.dispose();
    }
    notifyListeners();
  }
}

class RootCacheInfo {
  final String root;
  final DateTime lastSeenAt;
  final DateTime? builtAt;
  final bool isBuilding;
  final int entryCount;
  final bool isWatching;

  RootCacheInfo({
    required this.root,
    required this.lastSeenAt,
    required this.builtAt,
    required this.isBuilding,
    required this.entryCount,
    required this.isWatching,
  });

  factory RootCacheInfo._fromCache(String root, _RootCache cache) {
    return RootCacheInfo(
      root: root,
      lastSeenAt: cache.lastSeenAt,
      builtAt: cache.builtAt,
      isBuilding: cache.isBuilding,
      entryCount: cache.entries.length,
      isWatching: cache.isWatching,
    );
  }
}

class PathSuggestion {
  final String relativePath;
  final bool isDir;

  const PathSuggestion({
    required this.relativePath,
    required this.isDir,
  });

  String get displayText => isDir ? '$relativePath/' : relativePath;
}

class _RootCache {
  final String root;
  DateTime lastSeenAt;
  final VoidCallback onInvalidate;

  DateTime? builtAt;
  bool isBuilding = false;
  int buildGeneration = 0;

  final List<_IndexedEntry> entries = [];

  StreamSubscription<FileSystemEvent>? _watchSub;
  Timer? _watchDebounce;
  bool isWatching = false;

  _RootCache({
    required this.root,
    required this.lastSeenAt,
    required this.onInvalidate,
  });

  bool get isReady => builtAt != null && entries.isNotEmpty;

  void dispose() {
    _watchSub?.cancel();
    _watchDebounce?.cancel();
  }

  void applyIndex(List<_IndexedEntry> newEntries) {
    entries
      ..clear()
      ..addAll(newEntries);
  }

  List<PathSuggestion> search(String query, {int limit = 20}) {
    final q = query.trim().toLowerCase();
    if (entries.isEmpty) return const [];

    if (q.isEmpty) {
      final out = <PathSuggestion>[];
      for (final e in entries) {
        out.add(PathSuggestion(relativePath: e.relativePath, isDir: e.isDir));
        if (out.length >= limit) break;
      }
      return out;
    }

    final scored = <_ScoredEntry>[];
    for (final e in entries) {
      final score = _subsequenceScore(q, e.lower);
      if (score == null) continue;
      scored.add(_ScoredEntry(score: score, entry: e));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return a.entry.relativePath.compareTo(b.entry.relativePath);
    });

    final out = <PathSuggestion>[];
    for (final s in scored) {
      out.add(PathSuggestion(
          relativePath: s.entry.relativePath, isDir: s.entry.isDir));
      if (out.length >= limit) break;
    }
    return out;
  }

  Future<void> updateWatching(bool enabled) async {
    _watchDebounce?.cancel();

    if (!enabled) {
      await _watchSub?.cancel();
      _watchSub = null;
      isWatching = false;
      return;
    }

    if (isWatching) return;

    try {
      _watchSub = Directory(root).watch(recursive: true).listen((event) {
        _watchDebounce?.cancel();
        _watchDebounce = Timer(const Duration(seconds: 2), () {
          onInvalidate();
        });
      });
      isWatching = true;
    } catch (_) {
      await _watchSub?.cancel();
      _watchSub = null;
      isWatching = false;
    }
  }
}

class _IndexedEntry {
  final String relativePath;
  final bool isDir;
  final String lower;

  const _IndexedEntry({
    required this.relativePath,
    required this.isDir,
    required this.lower,
  });
}

class _ScoredEntry {
  final int score;
  final _IndexedEntry entry;

  const _ScoredEntry({
    required this.score,
    required this.entry,
  });
}

int? _subsequenceScore(String queryLower, String candidateLower) {
  if (queryLower.isEmpty) return 0;

  int qi = 0;
  int first = -1;
  int last = -1;
  int contiguous = 0;
  int prev = -1000;

  for (int ci = 0; ci < candidateLower.length && qi < queryLower.length; ci++) {
    if (candidateLower.codeUnitAt(ci) == queryLower.codeUnitAt(qi)) {
      if (first == -1) first = ci;
      if (ci == prev + 1) contiguous++;
      prev = ci;
      last = ci;
      qi++;
    }
  }

  if (qi != queryLower.length) return null;

  final lenPenalty = candidateLower.length * 2;
  final startPenalty = first * 5;
  final spreadPenalty = (last - first);

  var segmentBonus = 0;
  if (first == 0) {
    segmentBonus += 40;
  } else if (first > 0 && candidateLower[first - 1] == '/') {
    segmentBonus += 30;
  }

  final contiguousBonus = contiguous * 12;

  return 1000 -
      lenPenalty -
      startPenalty -
      spreadPenalty +
      segmentBonus +
      contiguousBonus;
}

class _IndexRequest {
  final String root;
  final List<String> ignoredDirNames;

  const _IndexRequest({
    required this.root,
    required this.ignoredDirNames,
  });
}

class _IndexResult {
  // Each entry is `[relativePath: String, isDir: bool]`.
  final List<List<Object?>> entries;

  const _IndexResult({
    required this.entries,
  });
}

_IndexResult _buildIndexInIsolate(_IndexRequest request) {
  final root = request.root;
  final ignored = request.ignoredDirNames
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toSet();

  final rootDir = Directory(root);
  if (!rootDir.existsSync()) {
    return const _IndexResult(entries: []);
  }

  final entries = <List<Object?>>[];
  final queue = <Directory>[rootDir];

  final sep = Platform.pathSeparator;
  var normalizedRoot = root;
  if (!normalizedRoot.endsWith(sep)) {
    normalizedRoot = '$normalizedRoot$sep';
  }

  while (queue.isNotEmpty) {
    final dir = queue.removeLast();

    final dirPath = dir.path;
    final name = _baseName(dirPath, sep);
    if (dirPath != rootDir.path && ignored.contains(name)) {
      continue;
    }

    final relDir = _relativePath(normalizedRoot, dirPath);
    if (relDir.isNotEmpty) {
      final normalized = relDir.replaceAll('\\', '/');
      entries.add([normalized, true]);
    }

    try {
      final children = dir.listSync(followLinks: false);
      for (final child in children) {
        if (child is Directory) {
          queue.add(child);
        } else if (child is File) {
          final rel = _relativePath(normalizedRoot, child.path);
          if (rel.isEmpty) continue;
          final normalized = rel.replaceAll('\\', '/');
          entries.add([normalized, false]);
        }
      }
    } catch (_) {
      continue;
    }
  }

  entries.sort((a, b) {
    final aIsDir = (a[1] as bool?) ?? false;
    final bIsDir = (b[1] as bool?) ?? false;
    if (aIsDir != bIsDir) return aIsDir ? -1 : 1;
    final aPath = (a[0] as String?) ?? '';
    final bPath = (b[0] as String?) ?? '';
    return aPath.compareTo(bPath);
  });

  return _IndexResult(entries: entries);
}

List<_IndexedEntry> _toIndexedEntries(List<List<Object?>> raw) {
  final out = <_IndexedEntry>[];
  for (final row in raw) {
    if (row.length < 2) continue;
    final path = row[0];
    final isDir = row[1];
    if (path is! String || isDir is! bool) continue;
    out.add(_IndexedEntry(
      relativePath: path,
      isDir: isDir,
      lower: path.toLowerCase(),
    ));
  }
  return out;
}

String _relativePath(String normalizedRootWithSep, String fullPath) {
  if (!fullPath.startsWith(normalizedRootWithSep)) return '';
  return fullPath.substring(normalizedRootWithSep.length);
}

String _baseName(String path, String sep) {
  final normalized =
      path.endsWith(sep) ? path.substring(0, path.length - 1) : path;
  final idx = normalized.lastIndexOf(sep);
  if (idx == -1) return normalized;
  return normalized.substring(idx + 1);
}
