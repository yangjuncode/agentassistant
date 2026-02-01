import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum McpSlashSuggestContent {
  command,
  skill,
  commandAndSkill,
}

enum McpToolSuggestionType {
  skill,
  command,
}

class McpToolSuggestion {
  final McpToolSuggestionType type;
  final String name;
  final String filePath;

  const McpToolSuggestion({
    required this.type,
    required this.name,
    required this.filePath,
  });
}

class McpToolIndexProvider extends ChangeNotifier {
  static const String _slashSuggestContentKey = 'mcp_slash_suggest_content';
  static const String _slashCommandCompletionTextKey =
      'mcp_slash_command_completion_text';
  static const String _slashSkillCompletionTextKey =
      'mcp_slash_skill_completion_text';
  static const String defaultSlashCommandCompletionText =
      'user wants to follow the instruction in command(%name%)[File: %path%] with /%name%: ';
  static const String defaultSlashSkillCompletionText =
      'user wants to follow the instruction in skill(%name%)[File: %path%] with /%name%: ';
  static const int defaultTtlHours = 8;

  final Map<String, _ToolCache> _caches = {};
  Timer? _cleanupTimer;

  final int _ttlHours = defaultTtlHours;
  McpSlashSuggestContent _slashSuggestContent = McpSlashSuggestContent.command;
  String _slashCommandCompletionText = defaultSlashCommandCompletionText;
  String _slashSkillCompletionText = defaultSlashSkillCompletionText;

  McpToolIndexProvider() {
    _loadSettings();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _cleanupExpired();
    });
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    super.dispose();
  }

  McpSlashSuggestContent get slashSuggestContent => _slashSuggestContent;
  String get slashCommandCompletionText => _slashCommandCompletionText;
  String get slashSkillCompletionText => _slashSkillCompletionText;

  Future<void> setSlashSuggestContent(McpSlashSuggestContent value) async {
    if (_slashSuggestContent == value) return;
    _slashSuggestContent = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_slashSuggestContentKey, value.index);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSlashCommandCompletionText(String value) async {
    if (_slashCommandCompletionText == value) return;
    _slashCommandCompletionText = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_slashCommandCompletionTextKey, value);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setSlashSkillCompletionText(String value) async {
    if (_slashSkillCompletionText == value) return;
    _slashSkillCompletionText = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_slashSkillCompletionTextKey, value);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> resetSlashCommandCompletionText() async {
    await setSlashCommandCompletionText(defaultSlashCommandCompletionText);
  }

  Future<void> resetSlashSkillCompletionText() async {
    await setSlashSkillCompletionText(defaultSlashSkillCompletionText);
  }

  bool rootExists(String root) {
    if (root.trim().isEmpty) return false;
    return Directory(root).existsSync();
  }

  void touchContext(String root, String? mcpClientName) {
    if (!rootExists(root)) return;

    final config = _resolveConfigForRoot(root, mcpClientName);
    final key = _cacheKey(root, config.clientNameKey);

    final now = DateTime.now();
    final cache = _caches[key];
    if (cache != null) {
      cache.lastSeenAt = now;
      return;
    }

    final newCache = _ToolCache(
      root: root,
      clientNameKey: config.clientNameKey,
      skillsRelativeDir: config.skillsRelativeDir,
      commandsRelativeDir: config.commandsRelativeDir,
      lastSeenAt: now,
    );

    _caches[key] = newCache;
    unawaited(_ensureIndexed(newCache));
    _cleanupExpired();
    notifyListeners();
  }

  List<McpToolSuggestion> search(
    String root,
    String? mcpClientName,
    String query, {
    int limit = 20,
  }) {
    if (!rootExists(root)) return const [];

    final config = _resolveConfigForRoot(root, mcpClientName);
    final key = _cacheKey(root, config.clientNameKey);

    touchContext(root, mcpClientName);

    final cache = _caches[key];
    if (cache == null) return const [];

    _ensureIndexed(cache);
    final out = cache.search(query, limit: limit);
    return _filterBySlashSuggestContent(out);
  }

  Future<void> refresh(String root, String? mcpClientName) async {
    if (!rootExists(root)) return;

    final config = _resolveConfigForRoot(root, mcpClientName);
    final key = _cacheKey(root, config.clientNameKey);
    final cache = _caches[key];
    if (cache == null) return;
    await _ensureIndexed(cache, force: true);
  }

  Future<void> _ensureIndexed(_ToolCache cache, {bool force = false}) async {
    final ttl = Duration(hours: _ttlHours);
    final expired = cache.builtAt == null ||
        DateTime.now().difference(cache.builtAt!) > ttl;

    if (!force && cache.isBuilding) return;
    if (!force && !expired && cache.isReady) return;

    if (!rootExists(cache.root)) return;

    final generation = ++cache.buildGeneration;
    cache.isBuilding = true;
    notifyListeners();

    try {
      final result = await compute<_ToolIndexRequest, _ToolIndexResult>(
        _buildToolIndexInIsolate,
        _ToolIndexRequest(
          root: cache.root,
          skillsRelativeDir: cache.skillsRelativeDir,
          commandsRelativeDir: cache.commandsRelativeDir,
        ),
      );

      if (cache.buildGeneration != generation) return;

      cache.applyIndex(_toIndexedToolEntries(result.entries));
      cache.builtAt = DateTime.now();
      cache.isBuilding = false;
      notifyListeners();
    } catch (_) {
      if (cache.buildGeneration != generation) return;
      cache.isBuilding = false;
      notifyListeners();
    }
  }

  void _cleanupExpired() {
    final ttl = Duration(hours: _ttlHours);
    final now = DateTime.now();

    final toRemove = <String>[];
    _caches.forEach((key, cache) {
      if (now.difference(cache.lastSeenAt) > ttl) {
        toRemove.add(key);
      }
    });

    if (toRemove.isEmpty) return;

    for (final key in toRemove) {
      _caches.remove(key);
    }
    notifyListeners();
  }

  List<McpToolSuggestion> _filterBySlashSuggestContent(
    List<McpToolSuggestion> input,
  ) {
    switch (_slashSuggestContent) {
      case McpSlashSuggestContent.command:
        return input
            .where((e) => e.type == McpToolSuggestionType.command)
            .toList();
      case McpSlashSuggestContent.skill:
        return input
            .where((e) => e.type == McpToolSuggestionType.skill)
            .toList();
      case McpSlashSuggestContent.commandAndSkill:
        return input;
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getInt(_slashSuggestContentKey);
      if (raw != null &&
          raw >= 0 &&
          raw < McpSlashSuggestContent.values.length) {
        _slashSuggestContent = McpSlashSuggestContent.values[raw];
      }
      final cmdText = prefs.getString(_slashCommandCompletionTextKey);
      if (cmdText != null) {
        _slashCommandCompletionText = cmdText;
      }
      final skillText = prefs.getString(_slashSkillCompletionTextKey);
      if (skillText != null) {
        _slashSkillCompletionText = skillText;
      }
    } catch (_) {}
    notifyListeners();
  }
}

class _ToolConfig {
  final String clientNameKey;
  final String skillsRelativeDir;
  final String commandsRelativeDir;

  const _ToolConfig({
    required this.clientNameKey,
    required this.skillsRelativeDir,
    required this.commandsRelativeDir,
  });
}

const _ToolConfig _defaultToolConfig = _ToolConfig(
  clientNameKey: 'default',
  skillsRelativeDir: '.agent/skills/',
  commandsRelativeDir: '.agent/workflows/',
);

const Map<String, _ToolConfig> _toolConfigs = {
  'Amazon Q Developer': _ToolConfig(
    clientNameKey: 'amazonq',
    skillsRelativeDir: '.amazonq/skills/',
    commandsRelativeDir: '.amazonq/prompts/',
  ),
  'Antigravity': _ToolConfig(
    clientNameKey: 'agent',
    skillsRelativeDir: '.agent/skills/',
    commandsRelativeDir: '.agent/workflows/',
  ),
  'Auggie (Augment CLI)': _ToolConfig(
    clientNameKey: 'augment',
    skillsRelativeDir: '.augment/skills/',
    commandsRelativeDir: '.augment/commands/',
  ),
  'Claude Code': _ToolConfig(
    clientNameKey: 'claude',
    skillsRelativeDir: '.claude/skills/',
    commandsRelativeDir: '.claude/commands/opsx/',
  ),
  'Cline': _ToolConfig(
    clientNameKey: 'cline',
    skillsRelativeDir: '.cline/skills/',
    commandsRelativeDir: '.clinerules/workflows/',
  ),
  'CodeBuddy': _ToolConfig(
    clientNameKey: 'codebuddy',
    skillsRelativeDir: '.codebuddy/skills/',
    commandsRelativeDir: '.codebuddy/commands/opsx/',
  ),
  'Codex': _ToolConfig(
    clientNameKey: 'codex',
    skillsRelativeDir: '.codex/skills/',
    commandsRelativeDir: '.codex/prompts/',
  ),
  'Continue': _ToolConfig(
    clientNameKey: 'continue',
    skillsRelativeDir: '.continue/skills/',
    commandsRelativeDir: '.continue/prompts/',
  ),
  'CoStrict': _ToolConfig(
    clientNameKey: 'cospec',
    skillsRelativeDir: '.cospec/skills/',
    commandsRelativeDir: '.cospec/openspec/commands/',
  ),
  'Crush': _ToolConfig(
    clientNameKey: 'crush',
    skillsRelativeDir: '.crush/skills/',
    commandsRelativeDir: '.crush/commands/opsx/',
  ),
  'Cursor': _ToolConfig(
    clientNameKey: 'cursor',
    skillsRelativeDir: '.cursor/skills/',
    commandsRelativeDir: '.cursor/commands/',
  ),
  'Factory Droid': _ToolConfig(
    clientNameKey: 'factory',
    skillsRelativeDir: '.factory/skills/',
    commandsRelativeDir: '.factory/commands/',
  ),
  'Gemini CLI': _ToolConfig(
    clientNameKey: 'gemini',
    skillsRelativeDir: '.gemini/skills/',
    commandsRelativeDir: '.gemini/commands/opsx/',
  ),
  'GitHub Copilot': _ToolConfig(
    clientNameKey: 'github',
    skillsRelativeDir: '.github/skills/',
    commandsRelativeDir: '.github/prompts/',
  ),
  'iFlow': _ToolConfig(
    clientNameKey: 'iflow',
    skillsRelativeDir: '.iflow/skills/',
    commandsRelativeDir: '.iflow/commands/',
  ),
  'Kilo Code': _ToolConfig(
    clientNameKey: 'kilocode',
    skillsRelativeDir: '.kilocode/skills/',
    commandsRelativeDir: '.kilocode/workflows/',
  ),
  'OpenCode': _ToolConfig(
    clientNameKey: 'opencode',
    skillsRelativeDir: '.opencode/skills/',
    commandsRelativeDir: '.opencode/command/',
  ),
  'Qoder': _ToolConfig(
    clientNameKey: 'qoder',
    skillsRelativeDir: '.qoder/skills/',
    commandsRelativeDir: '.qoder/commands/opsx/',
  ),
  'Qwen Code': _ToolConfig(
    clientNameKey: 'qwen',
    skillsRelativeDir: '.qwen/skills/',
    commandsRelativeDir: '.qwen/commands/',
  ),
  'RooCode': _ToolConfig(
    clientNameKey: 'roo',
    skillsRelativeDir: '.roo/skills/',
    commandsRelativeDir: '.roo/commands/',
  ),
  'Windsurf': _ToolConfig(
    clientNameKey: 'windsurf',
    skillsRelativeDir: '.windsurf/skills/',
    commandsRelativeDir: '.windsurf/workflows/',
  ),
};

_ToolConfig _resolveConfigForRoot(String root, String? mcpClientName) {
  final name = (mcpClientName ?? '').trim();
  if (name.isEmpty) return _defaultToolConfig;

  final mapped = _toolConfigs[name];
  if (mapped == null) return _defaultToolConfig;

  final skillsOk = _relativeDirExists(root, mapped.skillsRelativeDir);
  final commandsOk = _relativeDirExists(root, mapped.commandsRelativeDir);
  if (!skillsOk && !commandsOk) return _defaultToolConfig;

  return mapped;
}

bool _relativeDirExists(String root, String relativeDir) {
  var rel = relativeDir.trim();
  while (rel.startsWith('/') || rel.startsWith('\\')) {
    rel = rel.substring(1);
  }
  final sep = Platform.pathSeparator;
  final full = root.endsWith(sep) ? '$root$rel' : '$root$sep$rel';
  return Directory(full).existsSync();
}

String _cacheKey(String root, String clientNameKey) {
  return '$root|$clientNameKey';
}

class _ToolCache {
  final String root;
  final String clientNameKey;
  final String skillsRelativeDir;
  final String commandsRelativeDir;

  DateTime lastSeenAt;

  DateTime? builtAt;
  bool isBuilding = false;
  int buildGeneration = 0;

  final List<_IndexedToolEntry> entries = [];

  _ToolCache({
    required this.root,
    required this.clientNameKey,
    required this.skillsRelativeDir,
    required this.commandsRelativeDir,
    required this.lastSeenAt,
  });

  bool get isReady => builtAt != null;

  void applyIndex(List<_IndexedToolEntry> newEntries) {
    entries
      ..clear()
      ..addAll(newEntries);
  }

  List<McpToolSuggestion> search(String query, {int limit = 20}) {
    final q = query.trim().toLowerCase();
    if (entries.isEmpty) return const [];

    if (q.isEmpty) {
      final out = <McpToolSuggestion>[];
      for (final e in entries) {
        out.add(McpToolSuggestion(
          type: e.type,
          name: e.name,
          filePath: e.filePath,
        ));
        if (out.length >= limit) break;
      }
      return out;
    }

    final scored = <_ScoredToolEntry>[];
    for (final e in entries) {
      final score = _subsequenceScore(q, e.lower);
      if (score == null) continue;
      scored.add(_ScoredToolEntry(score: score, entry: e));
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      final byType = a.entry.type.index.compareTo(b.entry.type.index);
      if (byType != 0) return byType;
      return a.entry.name.compareTo(b.entry.name);
    });

    final out = <McpToolSuggestion>[];
    for (final s in scored) {
      out.add(McpToolSuggestion(
        type: s.entry.type,
        name: s.entry.name,
        filePath: s.entry.filePath,
      ));
      if (out.length >= limit) break;
    }

    return out;
  }
}

class _IndexedToolEntry {
  final McpToolSuggestionType type;
  final String name;
  final String filePath;
  final String lower;

  const _IndexedToolEntry({
    required this.type,
    required this.name,
    required this.filePath,
    required this.lower,
  });
}

class _ScoredToolEntry {
  final int score;
  final _IndexedToolEntry entry;

  const _ScoredToolEntry({
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
  }

  final contiguousBonus = contiguous * 12;

  return 1000 -
      lenPenalty -
      startPenalty -
      spreadPenalty +
      segmentBonus +
      contiguousBonus;
}

class _ToolIndexRequest {
  final String root;
  final String skillsRelativeDir;
  final String commandsRelativeDir;

  const _ToolIndexRequest({
    required this.root,
    required this.skillsRelativeDir,
    required this.commandsRelativeDir,
  });
}

class _ToolIndexResult {
  final List<List<Object?>> entries;

  const _ToolIndexResult({
    required this.entries,
  });
}

_ToolIndexResult _buildToolIndexInIsolate(_ToolIndexRequest request) {
  final root = request.root;
  final rootDir = Directory(root);
  if (!rootDir.existsSync()) {
    return const _ToolIndexResult(entries: []);
  }

  final sep = Platform.pathSeparator;

  String join(String a, String b) {
    if (a.endsWith(sep)) return '$a$b';
    return '$a$sep$b';
  }

  String normalizeRel(String rel) {
    var r = rel.trim();
    while (r.startsWith('/') || r.startsWith('\\')) {
      r = r.substring(1);
    }
    return r;
  }

  String relativeToRoot(String fullPath) {
    var p = fullPath;
    final rootWithSep = root.endsWith(sep) ? root : '$root$sep';
    if (p == root) return '';
    if (p.startsWith(rootWithSep)) {
      p = p.substring(rootWithSep.length);
    }
    while (p.startsWith('/') || p.startsWith('\\')) {
      p = p.substring(1);
    }
    return p;
  }

  final skillsDir =
      Directory(join(root, normalizeRel(request.skillsRelativeDir)));
  final commandsDir =
      Directory(join(root, normalizeRel(request.commandsRelativeDir)));

  final raw = <List<Object?>>[];

  if (skillsDir.existsSync()) {
    try {
      final children = skillsDir.listSync(followLinks: false);
      for (final child in children) {
        if (child is! Directory) continue;
        final name = _baseName(child.path, sep);
        if (name.trim().isEmpty) continue;

        final skillMd = File(join(child.path, 'SKILL.md'));
        if (!skillMd.existsSync()) continue;

        raw.add([
          McpToolSuggestionType.skill.index,
          name,
          relativeToRoot(skillMd.path),
        ]);
      }
    } catch (_) {}
  }

  if (commandsDir.existsSync()) {
    try {
      final children =
          commandsDir.listSync(followLinks: false, recursive: true);
      for (final child in children) {
        if (child is! File) continue;
        final path = child.path;
        if (!path.toLowerCase().endsWith('.md')) continue;

        final base = _baseName(path, sep);
        final name =
            base.endsWith('.md') ? base.substring(0, base.length - 3) : base;
        if (name.trim().isEmpty) continue;

        raw.add([
          McpToolSuggestionType.command.index,
          name,
          relativeToRoot(path),
        ]);
      }
    } catch (_) {}
  }

  raw.sort((a, b) {
    final aType = (a[0] as int?) ?? 0;
    final bType = (b[0] as int?) ?? 0;
    if (aType != bType) return aType.compareTo(bType);
    final aName = (a[1] as String?) ?? '';
    final bName = (b[1] as String?) ?? '';
    return aName.compareTo(bName);
  });

  return _ToolIndexResult(entries: raw);
}

List<_IndexedToolEntry> _toIndexedToolEntries(List<List<Object?>> raw) {
  final out = <_IndexedToolEntry>[];
  for (final row in raw) {
    if (row.length < 3) continue;
    final typeIndex = row[0];
    final name = row[1];
    final filePath = row[2];
    if (typeIndex is! int || name is! String || filePath is! String) continue;

    if (typeIndex < 0 || typeIndex >= McpToolSuggestionType.values.length) {
      continue;
    }

    out.add(_IndexedToolEntry(
      type: McpToolSuggestionType.values[typeIndex],
      name: name,
      filePath: filePath,
      lower: name.toLowerCase(),
    ));
  }
  return out;
}

String _baseName(String path, String sep) {
  final normalized =
      path.endsWith(sep) ? path.substring(0, path.length - 1) : path;
  final idx = normalized.lastIndexOf(sep);
  if (idx == -1) return normalized;
  return normalized.substring(idx + 1);
}
