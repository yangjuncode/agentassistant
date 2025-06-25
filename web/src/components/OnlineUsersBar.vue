<template>
  <div v-if="chatStore.isConnected && filteredOnlineUsers.length > 0" class="online-users-bar">
    <div class="users-header">
      <div class="users-info">
        <Icon name="people" class="users-icon" />
        <span class="users-count">在线用户 ({{ filteredOnlineUsers.length }})</span>
      </div>
      <button @click="chatStore.requestOnlineUsers()" class="refresh-btn" title="刷新在线用户">
        <Icon name="refresh" />
      </button>
    </div>

    <div class="users-list">
      <div
        v-for="user in filteredOnlineUsers"
        :key="user.clientId"
        @click="openChatDialog(user)"
        class="user-chip"
        :class="{ active: chatStore.activeChatUser === user.clientId }"
      >
        <div class="user-status"></div>
        <span class="user-nickname">
          {{ user.nickname || `User_${user.clientId.substring(0, 8)}` }}
        </span>
        <div v-if="hasUnreadMessages(user.clientId)" class="unread-indicator"></div>
      </div>
    </div>

    <!-- Chat Dialog -->
    <div v-if="activeChatUser" class="chat-dialog-overlay" @click="closeChatDialog">
      <div class="chat-dialog" @click.stop>
        <div class="chat-header">
          <div class="chat-user-info">
            <div class="user-status"></div>
            <span class="chat-user-name">
              {{ activeChatUser.nickname || `User_${activeChatUser.clientId.substring(0, 8)}` }}
            </span>
          </div>
          <button @click="closeChatDialog" class="close-btn">
            <Icon name="close" />
          </button>
        </div>

        <!-- Input on top for mobile -->
        <div v-if="isMobile" class="chat-input chat-input-top">
          <div class="input-wrapper">
            <input
              v-model="messageInput"
              @keyup.enter="sendMessage"
              placeholder="输入消息..."
              class="message-input"
            />
            <button @click="sendMessage" class="send-btn" :disabled="!messageInput.trim()">
              <Icon name="send" />
            </button>
          </div>
        </div>

        <div class="chat-messages" ref="messagesContainer">
          <div v-if="chatMessages.length === 0" class="no-messages">
            <div class="no-messages-icon">💬</div>
            <div class="no-messages-text">还没有聊天消息</div>
            <div class="no-messages-subtitle">开始对话吧！</div>
          </div>
          <div
            v-for="message in chatMessages"
            :key="message.messageId"
            class="message-wrapper"
            :class="{ 'from-me': message.senderClientId !== activeChatUser.clientId }"
          >
            <div class="message-avatar">
              <div class="avatar-circle" :class="{ 'me': message.senderClientId !== activeChatUser.clientId }">
                {{ message.senderClientId !== activeChatUser.clientId ? '我' : (message.senderNickname?.charAt(0) || '用') }}
              </div>
            </div>
            <div class="message-bubble">
              <div class="message-content">
                {{ message.content }}
              </div>
              <div class="message-time">
                {{ formatTime(message.sentAt) }}
              </div>
            </div>
          </div>
        </div>

        <!-- Input on bottom for desktop -->
        <div v-if="!isMobile" class="chat-input chat-input-bottom">
          <div class="input-wrapper">
            <input
              v-model="messageInput"
              @keyup.enter="sendMessage"
              placeholder="输入消息..."
              class="message-input"
            />
            <button @click="sendMessage" class="send-btn" :disabled="!messageInput.trim()">
              <Icon name="send" />
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, watch, onMounted, onUnmounted } from 'vue'
import { useChatStore } from '../stores/chat'
import type { OnlineUser, ChatMessage } from '../proto/agentassist_pb'

import Icon from './Icon.vue'

const chatStore = useChatStore()

// Mobile detection
const isMobile = ref(false)

/**
 * Detects if the current browser is likely running on a mobile device.
 * It uses a combination of user agent, modern client hints, screen width,
 * touch support, and CSS media queries for a more robust check.
 *
 * @returns {boolean} True if the device is likely mobile, false otherwise.
 */
function isMobileDevice(): boolean {
  try {
    const win = window
    const navigator = win.navigator as unknown as {
      userAgentData?: {
        mobile: boolean;
      };
      maxTouchPoints?: number;
    } & Navigator;

    // 1. Check for modern Client Hints API (most reliable)
    const userAgentData = navigator.userAgentData
    if (userAgentData?.mobile !== undefined) {
      return userAgentData.mobile;
    }

    // 2. Check for mobile-specific features
    if (
      'standalone' in window.navigator ||
      'msstandalone' in window.navigator ||
      'maxTouchPoints' in navigator && navigator.maxTouchPoints > 0
    ) {
      return true;
    }

    // 3. Check for mobile-specific APIs
    if (
      'orientation' in window ||
      'onorientationchange' in window ||
      'ontouchstart' in window ||
      'ontouchmove' in window ||
      'ontouchend' in window
    ) {
      return true;
    }

    // 4. Check for mobile-specific media queries
    const mediaQuery = (query: string) => {
      return window.matchMedia?.(query)?.matches ?? false;
    };

    if (
      mediaQuery('(any-pointer: coarse)') ||
      mediaQuery('(hover: none)')
    ) {
      return true;
    }

    // 5. Check for mobile-specific user agent strings
    const userAgent = navigator.userAgent || '';
    const mobilePatterns = [
      /Android/i,
      /iPhone/i,
      /iPad/i,
      /iPod/i,
      /BlackBerry/i,
      /IEMobile/i,
      /Opera Mini/i,
      /Windows Phone/i,
      /Mobile Safari/i,
      /CriOS/i,
      /FxiOS/i
    ];

    if (mobilePatterns.some(pattern => pattern.test(userAgent))) {
      return true;
    }

    // 6. Check for small screen size (last resort)
    const screenWidth = document.documentElement?.clientWidth ||
      document.body?.clientWidth ||
      1000;
    return screenWidth < 768;

  } catch (error) {
    console.error('Error detecting mobile device:', error);
    // If detection fails, assume desktop to avoid false positives
    return false;
  }
}

function checkIsMobile() {
  isMobile.value = isMobileDevice()
}

onMounted(() => {
  checkIsMobile()
  window.addEventListener('resize', checkIsMobile)
})

onUnmounted(() => {
  window.removeEventListener('resize', checkIsMobile)
})

// Filter out current user
const filteredOnlineUsers = computed(() => {
  return chatStore.onlineUsers.filter(user => user.clientId !== chatStore.currentClientId)
})

// Chat dialog state
const activeChatUser = ref<OnlineUser | null>(null)
const messageInput = ref('')
const messagesContainer = ref<HTMLElement>()

// Get chat messages for active user
const chatMessages = computed((): ChatMessage[] => {
  if (!activeChatUser.value) return []
  return chatStore.getChatMessages(activeChatUser.value.clientId)
})

function hasUnreadMessages(clientId: string): boolean {
  return chatStore.getChatMessages(clientId).length > 0
}

function openChatDialog(user: OnlineUser) {
  activeChatUser.value = user
  chatStore.setActiveChatUser(user.clientId)
  void nextTick(() => {
    scrollToBottom()
  })
}

function closeChatDialog() {
  activeChatUser.value = null
  chatStore.setActiveChatUser(null)
}

function sendMessage() {
  const content = messageInput.value.trim()
  if (!content || !activeChatUser.value) return

  chatStore.sendChatMessage(activeChatUser.value.clientId, content)
  messageInput.value = ''

  void nextTick(() => {
    scrollToBottom()
  })
}

function scrollToBottom() {
  if (messagesContainer.value) {
    messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
  }
}

function formatTime(timestamp: bigint): string {
  return new Date(Number(timestamp) * 1000).toLocaleTimeString()
}

// Auto scroll when new messages arrive
watch(chatMessages, () => {
  void nextTick(() => {
    scrollToBottom()
  })
}, { deep: true })

// Watch for active chat user changes (e.g., when user disconnects)
watch(() => chatStore.activeChatUser, (newActiveChatUser) => {
  if (newActiveChatUser === null && activeChatUser.value) {
    // Active chat user was cleared (likely due to disconnection)
    activeChatUser.value = null
  }
})
</script>

<style scoped>
.online-users-bar {
  width: 100%;
  padding: 12px 16px;
  background-color: rgba(var(--color-surface-container-highest), 0.3);
  border-bottom: 1px solid rgba(var(--color-outline), 0.2);
}

.users-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.users-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.users-icon {
  width: 16px;
  height: 16px;
  color: rgb(var(--color-primary));
}

.users-count {
  font-size: 0.875rem;
  font-weight: 500;
  color: rgb(var(--color-on-surface-variant));
}

.refresh-btn {
  padding: 4px;
  border: none;
  background: none;
  cursor: pointer;
  border-radius: 4px;
  color: rgb(var(--color-on-surface-variant));
}

.refresh-btn:hover {
  background-color: rgba(var(--color-on-surface), 0.1);
}

.users-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.user-chip {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background-color: rgb(var(--color-surface));
  border: 1px solid rgba(var(--color-outline), 0.3);
  border-radius: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.user-chip:hover {
  background-color: rgba(var(--color-primary), 0.1);
  border-color: rgb(var(--color-primary));
}

.user-chip.active {
  background-color: rgba(var(--color-primary), 0.1);
  border-color: rgb(var(--color-primary));
  border-width: 2px;
}

.user-status {
  width: 8px;
  height: 8px;
  background-color: rgb(var(--color-primary));
  border-radius: 50%;
}

.user-nickname {
  font-size: 0.875rem;
  font-weight: 500;
}

.user-chip.active .user-nickname {
  color: rgb(var(--color-primary));
  font-weight: 600;
}

.unread-indicator {
  width: 6px;
  height: 6px;
  background-color: rgb(var(--color-error));
  border-radius: 50%;
}

/* Chat Dialog Styles */
.chat-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.chat-dialog {
  width: 450px;
  height: 600px;
  background: linear-gradient(135deg, rgb(var(--color-surface)) 0%, rgba(var(--color-surface-container), 0.8) 100%);
  border-radius: 16px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 12px 48px rgba(0, 0, 0, 0.15), 0 4px 16px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px;
  background: linear-gradient(135deg, rgba(var(--color-primary), 0.1) 0%, rgba(var(--color-primary), 0.05) 100%);
  border-bottom: 1px solid rgba(var(--color-outline), 0.1);
  backdrop-filter: blur(10px);
}

.chat-user-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.chat-user-name {
  font-weight: 600;
  color: rgb(var(--color-on-surface));
}

.close-btn {
  padding: 8px;
  border: none;
  background: none;
  cursor: pointer;
  border-radius: 4px;
  color: rgb(var(--color-on-surface-variant));
}

.close-btn:hover {
  background-color: rgba(var(--color-on-surface), 0.1);
}

.chat-messages {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 16px;
  background: linear-gradient(180deg, rgba(var(--color-surface-container), 0.3) 0%, rgba(var(--color-surface-container), 0.1) 100%);
}

.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: transparent;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: rgba(var(--color-on-surface-variant), 0.3);
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: rgba(var(--color-on-surface-variant), 0.5);
}

.no-messages {
  text-align: center;
  color: rgb(var(--color-on-surface-variant));
  margin-top: 40%;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
}

.no-messages-icon {
  font-size: 3rem;
  opacity: 0.6;
}

.no-messages-text {
  font-size: 1.1rem;
  font-weight: 500;
}

.no-messages-subtitle {
  font-size: 0.9rem;
  opacity: 0.7;
}

.message-wrapper {
  display: flex;
  align-items: flex-end;
  gap: 8px;
  max-width: 80%;
  margin-bottom: 4px;
}

.message-wrapper.from-me {
  align-self: flex-end;
  flex-direction: row-reverse;
}

.message-avatar {
  flex-shrink: 0;
  margin-bottom: 4px;
}

.avatar-circle {
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 600;
  background: linear-gradient(135deg, rgba(var(--color-secondary), 0.8) 0%, rgba(var(--color-secondary), 0.6) 100%);
  color: rgb(var(--color-on-secondary));
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.avatar-circle.me {
  background: linear-gradient(135deg, rgba(var(--color-primary), 0.9) 0%, rgba(var(--color-primary), 0.7) 100%);
  color: rgb(var(--color-on-primary));
}

.message-bubble {
  display: flex;
  flex-direction: column;
  max-width: 100%;
}

.message-content {
  padding: 12px 16px;
  border-radius: 18px;
  background: linear-gradient(135deg, rgba(var(--color-surface-container-highest), 0.9) 0%, rgba(var(--color-surface-container), 0.8) 100%);
  color: rgb(var(--color-on-surface));
  box-shadow: 0 2px 12px rgba(0, 0, 0, 0.08);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(var(--color-outline), 0.1);
  position: relative;
  word-wrap: break-word;
}

.message-wrapper.from-me .message-content {
  background: linear-gradient(135deg, rgb(var(--color-primary)) 0%, rgba(var(--color-primary), 0.9) 100%);
  color: rgb(var(--color-on-primary));
  box-shadow: 0 3px 16px rgba(var(--color-primary), 0.3);
}

.message-wrapper.from-me .message-content::before {
  content: '';
  position: absolute;
  top: 50%;
  right: -6px;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-left: 6px solid rgb(var(--color-primary));
  border-top: 6px solid transparent;
  border-bottom: 6px solid transparent;
}

.message-wrapper:not(.from-me) .message-content::before {
  content: '';
  position: absolute;
  top: 50%;
  left: -6px;
  transform: translateY(-50%);
  width: 0;
  height: 0;
  border-right: 6px solid rgba(var(--color-surface-container-highest), 0.9);
  border-top: 6px solid transparent;
  border-bottom: 6px solid transparent;
}

.message-time {
  font-size: 0.7rem;
  color: rgba(var(--color-on-surface-variant), 0.7);
  margin-top: 4px;
  padding: 0 4px;
}

.message-wrapper.from-me .message-time {
  align-self: flex-start;
}

.message-wrapper:not(.from-me) .message-time {
  align-self: flex-end;
}

.chat-input {
  padding: 20px;
  background: linear-gradient(135deg, rgba(var(--color-surface-container), 0.5) 0%, rgba(var(--color-surface), 0.8) 100%);
  backdrop-filter: blur(10px);
}

.chat-input-top {
  border-bottom: 1px solid rgba(var(--color-outline), 0.1);
}

.chat-input-bottom {
  border-top: 1px solid rgba(var(--color-outline), 0.1);
}

.input-wrapper {
  display: flex;
  gap: 12px;
  align-items: flex-end;
  background: rgba(var(--color-surface), 0.9);
  border-radius: 24px;
  padding: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border: 1px solid rgba(var(--color-outline), 0.1);
}

.message-input {
  flex: 1;
  padding: 12px 16px;
  border: none;
  border-radius: 20px;
  background-color: transparent;
  color: rgb(var(--color-on-surface));
  font-size: 0.95rem;
  resize: none;
  outline: none;
}

.message-input::placeholder {
  color: rgba(var(--color-on-surface-variant), 0.6);
}

.send-btn {
  width: 40px;
  height: 40px;
  border: none;
  background: linear-gradient(135deg, rgb(var(--color-primary)) 0%, rgba(var(--color-primary), 0.8) 100%);
  color: rgb(var(--color-on-primary));
  border-radius: 50%;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: 0 2px 12px rgba(var(--color-primary), 0.3);
}

.send-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 16px rgba(var(--color-primary), 0.4);
}

.send-btn:active:not(:disabled) {
  transform: translateY(0);
}

.send-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
  box-shadow: 0 2px 8px rgba(var(--color-primary), 0.1);
}
</style>
