import { Notify } from 'quasar';
import { APP_CONFIG } from '../config/app';

export type NotificationType = 'positive' | 'negative' | 'warning' | 'info';

export interface NotificationOptions {
  message: string;
  type?: NotificationType;
  timeout?: number;
  actions?: Array<{
    label: string;
    color?: string;
    handler: () => void;
  }>;
}

export class NotificationService {
  static show(options: NotificationOptions) {
    const {
      message,
      type = 'info',
      timeout = APP_CONFIG.ui.notificationDuration,
      actions = []
    } = options;

    const notifyActions = actions.map(action => ({
      label: action.label,
      color: action.color || 'white',
      handler: action.handler
    }));

    const notifyOptions: Record<string, unknown> = {
      type,
      message,
      timeout,
      position: 'top',
      multiLine: true
    };

    if (notifyActions.length > 0) {
      notifyOptions.actions = notifyActions;
    }

    Notify.create(notifyOptions);
  }

  static success(message: string, timeout?: number) {
    this.show({
      message,
      type: 'positive',
      timeout: timeout || APP_CONFIG.ui.notificationDuration
    });
  }

  static error(message: string, timeout?: number) {
    this.show({
      message,
      type: 'negative',
      timeout: timeout || APP_CONFIG.ui.notificationDuration
    });
  }

  static warning(message: string, timeout?: number) {
    this.show({
      message,
      type: 'warning',
      timeout: timeout || APP_CONFIG.ui.notificationDuration
    });
  }

  static info(message: string, timeout?: number) {
    this.show({
      message,
      type: 'info',
      timeout: timeout || APP_CONFIG.ui.notificationDuration
    });
  }

  static connectionSuccess() {
    this.success('已成功连接到 Agent Assistant 服务器');
  }

  static connectionError(error?: string) {
    this.error(error || '连接到服务器失败，请检查网络连接');
  }

  static connectionLost() {
    this.warning('与服务器的连接已断开，正在尝试重新连接...');
  }

  static questionReceived() {
    this.info('收到新的问题，请查看并回复');
  }

  static taskReceived() {
    this.info('收到新的任务完成通知');
  }

  static replySent() {
    this.success('回复已发送');
  }

  static confirmationSent() {
    this.success('确认已发送');
  }
}
