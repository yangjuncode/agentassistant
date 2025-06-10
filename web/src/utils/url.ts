import  { Platform } from 'quasar';

console.log('Platform:', Platform, process.env);

/**
 * Extract token from URL query parameters
 */
export function getTokenFromUrl(): string | null {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get('token');
}

/**
 * Build WebSocket URL from current location
 */
export function buildWebSocketUrl(): string {
  const protocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
  const host = window.location.hostname;
  const port = window.location.port || (window.location.protocol === 'https:' ? '443' : '80');
  //if set env.agentServerUrl, use it
  console.log('process.env:', process.env.agentServerUrl);
  if (process.env.agentServerUrl) {
    return process.env.agentServerUrl;
  }
  return `${protocol}//${host}:${port}/ws`;
}

/**
 * Validate token format (basic validation)
 */
export function isValidToken(token: string): boolean {
  return Boolean(token && token.length > 0 && token.trim() === token);
}

/**
 * Get server info from current URL
 */
export function getServerInfo() {
  return {
    host: window.location.hostname,
    port: parseInt(window.location.port) || (window.location.protocol === 'https:' ? 443 : 80),
    protocol: window.location.protocol === 'https:' ? 'https' : 'http'
  };
}
