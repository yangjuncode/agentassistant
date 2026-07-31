import 'dart:async';

import 'package:flutter/widgets.dart';

/// Debounces chat auto-send while respecting text still owned by the IME.
class ChatInputAutoSendController {
  ChatInputAutoSendController({
    required this.idleDelay,
    required this.onReady,
    this.imeCommitSettleDelay = const Duration(milliseconds: 1500),
  });

  final Duration Function() idleDelay;
  final VoidCallback onReady;
  final Duration imeCommitSettleDelay;

  Timer? _timer;
  TextEditingValue _previousValue = TextEditingValue.empty;
  int _revision = 0;
  bool _disposed = false;

  static bool hasActiveComposition(TextEditingValue value) {
    final composing = value.composing;
    return composing.isValid && !composing.isCollapsed;
  }

  void handleValueChanged(TextEditingValue value) {
    if (_disposed) return;

    final previousWasComposing = hasActiveComposition(_previousValue);
    final isComposing = hasActiveComposition(value);
    _previousValue = value;
    _revision++;
    _timer?.cancel();
    _timer = null;

    if (value.text.trim().isEmpty || isComposing) return;

    final revision = _revision;
    final text = value.text;
    final settleDelay =
        previousWasComposing ? imeCommitSettleDelay : Duration.zero;
    _timer = Timer(idleDelay() + settleDelay, () {
      _timer = null;
      if (_disposed || revision != _revision) return;
      if (_previousValue.text != text || hasActiveComposition(_previousValue)) {
        return;
      }
      onReady();
    });
  }

  void cancel() {
    _revision++;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    cancel();
  }
}
