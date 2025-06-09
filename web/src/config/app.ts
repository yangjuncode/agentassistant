// Application configuration
export const APP_CONFIG = {
  // WebSocket configuration
  websocket: {
    reconnectAttempts: 5,
    reconnectDelay: 1000,
    heartbeatInterval: 30000,
    connectionTimeout: 10000
  },

  // UI configuration
  ui: {
    messageMaxLength: 5000,
    autoScrollDelay: 100,
    notificationDuration: 5000
  },

  // Default timeouts (in seconds)
  timeouts: {
    defaultQuestion: 600,
    defaultTask: 600,
    maxTimeout: 3600
  },

  // Application metadata
  app: {
    name: 'Agent Assistant',
    version: '1.0.0',
    description: 'AI Agent Assistant Web Interface'
  }
} as const;

// Environment-specific configuration
export const ENV_CONFIG = {
  isDevelopment: process.env.NODE_ENV === 'development',
  isProduction: process.env.NODE_ENV === 'production',
  baseUrl: '/'
} as const;

// WebSocket endpoint paths
export const WS_ENDPOINTS = {
  main: '/ws',
  health: '/health'
} as const;
