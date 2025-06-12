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

        <div class="chat-messages" ref="messagesContainer">
          <div v-if="chatMessages.length === 0" class="no-messages">
            还没有聊天消息
          </div>
          <div
            v-for="message in chatMessages"
            :key="message.messageId"
            class="message"
            :class="{ 'from-me': message.senderClientId !== activeChatUser.clientId }"
          >
            <div class="message-content">
              {{ message.content }}
            </div>
            <div class="message-time">
              {{ formatTime(message.sentAt) }}
            </div>
          </div>
        </div>

        <div class="chat-input">
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
</template>

<script setup lang="ts">
import { ref, computed, nextTick, watch } from 'vue'
import { useChatStore } from '../stores/chat'
import type { OnlineUser, ChatMessage } from '../proto/agentassist_pb'
import Icon from './Icon.vue'

const chatStore = useChatStore()

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
  width: 400px;
  height: 500px;
  background-color: rgb(var(--color-surface));
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);
}

.chat-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 16px;
  border-bottom: 1px solid rgba(var(--color-outline), 0.2);
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
  padding: 16px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.no-messages {
  text-align: center;
  color: rgb(var(--color-on-surface-variant));
  margin-top: 50%;
}

.message {
  display: flex;
  flex-direction: column;
  max-width: 70%;
}

.message.from-me {
  align-self: flex-end;
}

.message-content {
  padding: 12px;
  border-radius: 12px;
  background-color: rgba(var(--color-surface-container-highest), 1);
  color: rgb(var(--color-on-surface));
}

.message.from-me .message-content {
  background-color: rgb(var(--color-primary));
  color: rgb(var(--color-on-primary));
}

.message-time {
  font-size: 0.75rem;
  color: rgb(var(--color-on-surface-variant));
  margin-top: 4px;
  align-self: flex-end;
}

.message.from-me .message-time {
  align-self: flex-start;
}

.chat-input {
  display: flex;
  padding: 16px;
  gap: 8px;
  border-top: 1px solid rgba(var(--color-outline), 0.2);
}

.message-input {
  flex: 1;
  padding: 8px 12px;
  border: 1px solid rgba(var(--color-outline), 0.3);
  border-radius: 8px;
  background-color: rgb(var(--color-surface));
  color: rgb(var(--color-on-surface));
}

.message-input:focus {
  outline: none;
  border-color: rgb(var(--color-primary));
}

.send-btn {
  padding: 8px 12px;
  border: none;
  background-color: rgb(var(--color-primary));
  color: rgb(var(--color-on-primary));
  border-radius: 8px;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

.send-btn:hover:not(:disabled) {
  background-color: rgba(var(--color-primary), 0.8);
}

.send-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
