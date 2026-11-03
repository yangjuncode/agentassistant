import 'package:flutter/foundation.dart';
import 'package:agentassistant/providers/chat_provider.dart';

/// 不构造真实 ChatProvider（其字段初始化会创建 AudioPlayer，
/// 在测试环境触发 audioplayers 平台通道异常）。用 noSuchMethod 兜底。
class FakeChatProvider extends ChangeNotifier implements ChatProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isGetter) {
      if (invocation.memberName == #autoReplyAskQuestion) return false;
      if (invocation.memberName == #useInteractiveAskQuestion) return true;
      return null;
    }
    if (invocation.isMethod) {
      if (invocation.memberName == #getAskQuestionDraft) return null;
      if (invocation.memberName == #replyToQuestion) return Future.value();
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}
