// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Agent Assistant';

  @override
  String get settings => '设置';

  @override
  String get connection => '连接';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '未连接';

  @override
  String get connectedToServer => '与服务器连接正常';

  @override
  String get connectionClosed => '连接已断开';

  @override
  String get serverAddress => '服务器地址';

  @override
  String get notSet => '未设置';

  @override
  String get clientId => '客户端 ID';

  @override
  String get accessToken => '访问令牌';

  @override
  String get disconnect => '断开连接';

  @override
  String get disconnectFromServer => '断开与服务器的连接';

  @override
  String get disconnectConfirmTitle => '断开连接';

  @override
  String get disconnectConfirmMessage => '确定要断开与服务器的连接吗？';

  @override
  String get cancel => '取消';

  @override
  String get userSettings => '用户设置';

  @override
  String get systemInput => '系统输入';

  @override
  String get autoForwardMessages => '自动转发聊天消息';

  @override
  String get autoForwardMessagesDesc => '收到聊天消息时自动发送到系统输入';

  @override
  String get autoForwardEnabled => '已开启自动转发';

  @override
  String get autoForwardDisabled => '已关闭自动转发';

  @override
  String get messages => '消息';

  @override
  String get messageStats => '消息统计';

  @override
  String totalMessages(int count) {
    return '总计 $count 条消息';
  }

  @override
  String pendingQuestions(int count) {
    return '待处理问题 $count 个';
  }

  @override
  String pendingTasks(int count) {
    return '待处理任务 $count 个';
  }

  @override
  String get clearMessages => '清除消息';

  @override
  String get clearMessagesDesc => '删除所有聊天记录';

  @override
  String get clearMessagesConfirmTitle => '清除消息';

  @override
  String get clearMessagesConfirmMessage => '确定要清除所有聊天记录吗？此操作无法撤销。';

  @override
  String get clear => '清除';

  @override
  String get messagesCleared => '聊天记录已清除';

  @override
  String get app => '应用';

  @override
  String get about => '关于';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String buildTime(String time) {
    return '编译时间 $time';
  }

  @override
  String get feedback => '反馈问题';

  @override
  String get feedbackDesc => '报告 Bug 或提出建议';

  @override
  String get feedbackMessage => '请联系您的系统管理员反馈问题';

  @override
  String get aboutAppDescription => 'Agent Assistant 是一个移动客户端应用，用于与 AI Agent 进行实时通信。';

  @override
  String get features => '功能特性：';

  @override
  String get featureWebSocket => '实时 WebSocket 通信';

  @override
  String get featureMultiContent => '支持多种内容类型';

  @override
  String get featureAutoReconnect => '自动重连机制';

  @override
  String get featureLocalStorage => '本地消息存储';

  @override
  String get language => '语言';

  @override
  String get languageSettings => '语言设置';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get languageAuto => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String nicknameUpdated(String nickname) {
    return '昵称已更新为: $nickname';
  }

  @override
  String get pathAutocomplete => '路径补全';

  @override
  String ignoredDirectory(String dir) {
    return '忽略目录: $dir';
  }

  @override
  String get slashCommands => 'Slash Commands';

  @override
  String get slashCommandsShow => '显示';

  @override
  String get slashCommandsOptionCommands => '命令';

  @override
  String get slashCommandsOptionSkills => '技能';

  @override
  String get slashCommandsOptionCommandsAndSkills => '命令+技能';

  @override
  String get slashCommandCompletionText => '/ 命令 (Command) 补全文本';

  @override
  String get slashSkillCompletionText => '/ 技能 (Skill) 补全文本';

  @override
  String get slashCompletionTextDesc => '定制 / 命令自动补全时的输入文本。可用变量: %name%, %path%, %type%';

  @override
  String get resetToDefault => '恢复默认';

  @override
  String get desktop => '桌面端';

  @override
  String get mcpMessageAttention => 'MCP 消息提醒';

  @override
  String get mcpAskQuestionAttention => 'Ask Question 提醒模式';

  @override
  String get mcpWorkReportAttention => 'Work Report 提醒模式';

  @override
  String get mcpAttentionModeNone => '无';

  @override
  String get mcpAttentionModeTray => '仅系统托盘通知';

  @override
  String get mcpAttentionModePopup => '仅弹窗';

  @override
  String get mcpAttentionModePopupOnTop => '弹窗 + 置顶';

  @override
  String get mcpAttentionModeTrayPopupOnTop => '系统托盘通知 + 弹窗 + 置顶';

  @override
  String get webSocketUrlHint => 'ws://host:port/ws';

  @override
  String get chatAutoSendInterval => '聊天自动发送间隔';

  @override
  String chatAutoSendIntervalSeconds(int seconds) {
    return '$seconds 秒';
  }

  @override
  String profileClientIdLabel(String clientId) {
    return '客户端 ID: $clientId';
  }

  @override
  String get online => '在线';

  @override
  String get notConnected => '未连接';

  @override
  String get loginSubtitle => '连接到您的 AI Agent 助手';

  @override
  String loginFailed(String error) {
    return '登录失败: $error';
  }

  @override
  String get loginTokenLabel => '访问令牌';

  @override
  String get loginTokenHint => '请输入您的访问令牌';

  @override
  String get loginAdvancedSettings => '高级设置';

  @override
  String get loginServerLabel => '服务器地址';

  @override
  String get loginRememberSettingsTitle => '记住设置';

  @override
  String get loginRememberSettingsSubtitle => '下次启动时自动填充';

  @override
  String get loginButton => '连接';

  @override
  String get loginHelp => '需要帮助？请联系您的系统管理员获取访问令牌。';

  @override
  String get errorTokenRequired => '请输入访问令牌';

  @override
  String get errorTokenInvalid => '令牌格式无效（至少1个字符）';

  @override
  String get errorServerRequired => '请输入服务器地址';

  @override
  String get errorServerProtocol => '服务器地址必须以 ws:// 或 wss:// 开头';

  @override
  String get chatConnecting => '正在连接到 Agent Assistant 服务器...';

  @override
  String get chatConnectionLost => '连接已断开';

  @override
  String get chatUnableConnect => '无法连接到服务器';

  @override
  String get chatReconnect => '重新连接';

  @override
  String get chatEmptyTitle => '等待 AI Agent 的消息...';

  @override
  String get chatEmptySubtitle => '连接成功后，AI Agent 的问题和任务将在这里显示';

  @override
  String get splashInitializing => '正在初始化...';

  @override
  String get splashConnecting => '正在连接服务器...';

  @override
  String get splashConnected => '连接成功！';

  @override
  String get splashManualConnect => '需要手动连接';

  @override
  String get splashInitFailed => '初始化失败';

  @override
  String get splashRetrying => '正在重试...';

  @override
  String get splashTitle => '智能助手客户端';

  @override
  String get splashRetryButton => '重试';

  @override
  String get copyTooltip => '复制';

  @override
  String get messageCopied => '消息已复制到剪贴板';

  @override
  String get replyCopied => '回复已复制到剪贴板';

  @override
  String get statusPending => '待处理';

  @override
  String get statusReplied => '已回复';

  @override
  String get statusConfirmed => '已确认';

  @override
  String get statusError => '错误';

  @override
  String get statusExpired => '已过期';

  @override
  String get statusCancelled => '已取消';

  @override
  String get yourReply => '您的回复';

  @override
  String get otherUser => '其他用户';

  @override
  String replyFrom(String nickname) {
    return '$nickname的回复';
  }

  @override
  String get nicknameSettingsTitle => '昵称设置';

  @override
  String get nicknameSettingsSubtitle => '设置您在聊天中显示的昵称';

  @override
  String get nicknameLabel => '昵称';

  @override
  String get nicknameHint => '请输入您的昵称';

  @override
  String get nicknameRegenerate => '重新生成';

  @override
  String get nicknameClear => '清空';

  @override
  String get nicknameSaving => '保存中...';

  @override
  String get nicknameSave => '保存';

  @override
  String get nicknameTipsTitle => '提示：';

  @override
  String get nicknameTipsBody => '• 昵称长度为2-20个字符\n• 昵称将显示在您的回复中\n• 其他用户可以看到您的昵称';

  @override
  String nicknameLoadFailed(String error) {
    return '加载昵称失败: $error';
  }

  @override
  String nicknameSaveFailed(String error) {
    return '保存昵称失败: $error';
  }

  @override
  String get nicknameEmptyError => '昵称不能为空';

  @override
  String get nicknameTooShortError => '昵称至少需要2个字符';

  @override
  String get nicknameTooLongError => '昵称不能超过20个字符';

  @override
  String get nicknameSaved => '昵称已保存并同步到服务器';

  @override
  String get servers => '服务器';

  @override
  String get addServer => '添加服务器';

  @override
  String get editServer => '编辑服务器';

  @override
  String get serverAlias => '别名（可选）';

  @override
  String get webSocketUrl => 'WebSocket 地址';

  @override
  String get enabled => '已启用';

  @override
  String get save => '保存';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get noServersConfigured => '未配置服务器，请添加服务器进行连接。';

  @override
  String get noEnabledServers => '没有启用的服务器，请至少启用一个服务器。';

  @override
  String get deleteServerConfirmTitle => '删除服务器';

  @override
  String deleteServerConfirmMessage(String serverName) {
    return '确定要删除服务器 \"$serverName\" 吗？';
  }

  @override
  String get close => '关闭';

  @override
  String get serverConnectionsTooltip => '服务器连接';

  @override
  String get serverConnectionsTitle => '服务器连接';

  @override
  String serverStatusLine(String status) {
    return '状态：$status';
  }

  @override
  String serverErrorLine(String error) {
    return '错误：$error';
  }

  @override
  String get serverStatusConnected => '已连接';

  @override
  String get serverStatusConnecting => '连接中';

  @override
  String get serverStatusReconnecting => '重连中';

  @override
  String get serverStatusError => '错误';

  @override
  String get serverStatusDisconnected => '未连接';
}
