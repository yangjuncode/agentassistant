import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:glob/glob.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 路径自动补全的目录索引 Provider
/// 支持 GitIgnore 风格的文件/目录过滤
class ProjectDirectoryIndexProvider extends ChangeNotifier {
  static const String _ttlHoursKey = 'path_index_cache_ttl_hours';
  static const String _watchEnabledDesktopKey =
      'path_index_watch_enabled_desktop';
  static const String _useGitIgnoreKey = 'path_autocomplete_use_gitignore';
  static const String _customIgnorePatternsKey =
      'path_autocomplete_custom_patterns';

  static const int defaultTtlHours = 8;

  /// 默认的忽略模式（gitignore 格式）
  /// 这些是程序内置的默认规则
  static const String defaultIgnorePatterns = '''
# 版本控制
.git/
.github/

# IDE 和编辑器
.vscode/
.idea/
.cursor/

# AI Agent 工具目录
.agent/
.windsurf/
.antigravity/
.gemini/
.trae/
.opencode/
.codex/
.claude/

# 构建产物
build/
.dart_tool/
node_modules/
cmake-build-debug/
cmake-build-release/

# 临时文件
.tmp/
''';

  final Map<String, _RootCache> _caches = {};
  Timer? _cleanupTimer;

  int _ttlHours = defaultTtlHours;
  bool _watchEnabledDesktop = true;
  bool _useGitIgnore = true;
  String _customIgnorePatterns = defaultIgnorePatterns;

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
  bool get watchEnabledDesktop => _watchEnabledDesktop;
  bool get useGitIgnore => _useGitIgnore;
  String get customIgnorePatterns => _customIgnorePatterns;

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

  Future<void> setUseGitIgnore(bool enabled) async {
    if (_useGitIgnore == enabled) return;
    _useGitIgnore = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useGitIgnoreKey, enabled);

    // 使设置变更生效，重新构建索引
    _invalidateAllCaches();
    notifyListeners();
  }

  Future<void> setCustomIgnorePatterns(String patterns) async {
    if (_customIgnorePatterns == patterns) return;
    _customIgnorePatterns = patterns;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customIgnorePatternsKey, patterns);

    // 使设置变更生效，重新构建索引
    _invalidateAllCaches();
    notifyListeners();
  }

  /// 重置自定义忽略规则为默认值
  Future<void> resetCustomIgnorePatterns() async {
    await setCustomIgnorePatterns(defaultIgnorePatterns);
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

  void _invalidateAllCaches() {
    for (final cache in _caches.values) {
      cache.builtAt = null;
    }
    for (final cache in _caches.values) {
      unawaited(_ensureIndexed(cache, force: true));
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ttlHours = prefs.getInt(_ttlHoursKey) ?? defaultTtlHours;
      _watchEnabledDesktop =
          prefs.getBool(_watchEnabledDesktopKey) ?? _watchEnabledDesktop;
      _useGitIgnore = prefs.getBool(_useGitIgnoreKey) ?? _useGitIgnore;
      _customIgnorePatterns =
          prefs.getString(_customIgnorePatternsKey) ?? defaultIgnorePatterns;
    } catch (_) {
      _ttlHours = defaultTtlHours;
      _watchEnabledDesktop = true;
      _useGitIgnore = true;
      _customIgnorePatterns = defaultIgnorePatterns;
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
      // 收集所有忽略模式
      final allPatterns = _collectIgnorePatterns(cache.root);

      final result = await compute<_IndexRequest, _IndexResult>(
        _buildIndexInIsolate,
        _IndexRequest(
          root: cache.root,
          ignorePatterns: allPatterns,
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

  /// 收集所有忽略模式：自定义规则 + (可选) .gitignore
  List<String> _collectIgnorePatterns(String root) {
    final patterns = <String>{};

    // 1. 添加自定义忽略规则
    patterns.addAll(_parseIgnorePatterns(_customIgnorePatterns));

    // 2. 如果启用了 .gitignore，读取并添加
    if (_useGitIgnore) {
      patterns.addAll(_readGitIgnorePatterns(root));
    }

    return patterns.toList();
  }

  /// 解析 gitignore 格式的文本，返回模式列表
  static List<String> _parseIgnorePatterns(String text) {
    final patterns = <String>[];
    for (final line in text.split('\n')) {
      final trimmed = line.trim();
      // 忽略空行和注释
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      patterns.add(trimmed);
    }
    return patterns;
  }

  /// 读取项目根目录的 .gitignore 文件
  List<String> _readGitIgnorePatterns(String root) {
    final patterns = <String>[];
    try {
      final sep = Platform.pathSeparator;
      final gitignoreFile = File('$root$sep.gitignore');
      if (gitignoreFile.existsSync()) {
        final content = gitignoreFile.readAsStringSync();
        patterns.addAll(_parseIgnorePatterns(content));
      }
    } catch (_) {
      // 忽略读取错误
    }
    return patterns;
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
  final List<String> ignorePatterns;

  const _IndexRequest({
    required this.root,
    required this.ignorePatterns,
  });
}

class _IndexResult {
  // Each entry is `[relativePath: String, isDir: bool]`.
  final List<List<Object?>> entries;

  const _IndexResult({
    required this.entries,
  });
}

/// 在 Isolate 中构建文件索引
/// 使用 glob 模式匹配进行过滤
_IndexResult _buildIndexInIsolate(_IndexRequest request) {
  final root = request.root;
  final rootDir = Directory(root);
  if (!rootDir.existsSync()) {
    return const _IndexResult(entries: []);
  }

  // 编译 glob 模式
  final globs = <Glob>[];
  for (final pattern in request.ignorePatterns) {
    try {
      // 处理 gitignore 格式的模式（可能返回多个 glob 模式）
      final normalizedPatterns = _normalizeGitIgnorePatterns(pattern);
      for (final normalizedPattern in normalizedPatterns) {
        if (normalizedPattern.isNotEmpty) {
          globs.add(Glob(normalizedPattern));
        }
      }
    } catch (_) {
      // 忽略无效的 glob 模式
    }
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
    final relDir = _relativePath(normalizedRoot, dirPath);

    // 对目录进行模式匹配检查
    if (relDir.isNotEmpty) {
      final normalized = relDir.replaceAll('\\', '/');
      if (_shouldIgnore(normalized, globs, isDir: true)) {
        continue; // 跳过此目录及其子目录
      }
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
          // 对文件进行模式匹配检查
          if (_shouldIgnore(normalized, globs, isDir: false)) {
            continue;
          }
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

/// 将 gitignore 格式的模式转换为 glob 格式
/// 返回一个或多个 glob 模式字符串
List<String> _normalizeGitIgnorePatterns(String pattern) {
  var p = pattern.trim();
  if (p.isEmpty) return [];

  // 处理否定模式（暂不支持，直接忽略）
  if (p.startsWith('!')) return [];

  // 移除开头的斜杠（gitignore 中表示根目录相对路径）
  final isRootAnchored = p.startsWith('/');
  if (isRootAnchored) {
    p = p.substring(1);
  }

  // 如果模式以 / 结尾，表示只匹配目录
  // 移除尾部斜杠用于匹配
  if (p.endsWith('/')) {
    p = p.substring(0, p.length - 1);
  }

  if (p.isEmpty) return [];

  final results = <String>[];

  // 如果模式不包含 /，则匹配任意深度的目录/文件
  // 例如：.git 应该匹配 .git 和 foo/.git 和 bar/baz/.git
  if (!p.contains('/')) {
    // 匹配根目录下的
    results.add(p);
    // 匹配任意子目录下的
    results.add('**/$p');
    // 匹配目录内的所有内容
    results.add('$p/**');
    results.add('**/$p/**');
  } else {
    // 模式包含路径分隔符
    if (isRootAnchored) {
      // 根目录锚定的模式
      results.add(p);
      results.add('$p/**');
    } else {
      // 可以匹配任意位置
      results.add(p);
      results.add('**/$p');
      results.add('$p/**');
      results.add('**/$p/**');
    }
  }

  return results;
}

/// 检查路径是否应该被忽略
bool _shouldIgnore(String relativePath, List<Glob> globs,
    {required bool isDir}) {
  if (globs.isEmpty) return false;

  // 对于目录，需要同时检查带/和不带/的情况
  final pathsToCheck = <String>[relativePath];
  if (isDir) {
    pathsToCheck.add('$relativePath/');
  }

  for (final glob in globs) {
    for (final path in pathsToCheck) {
      if (glob.matches(path)) {
        return true;
      }
    }
  }
  return false;
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
