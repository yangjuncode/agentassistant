<template>
  <q-page class="chat-page">
    <!-- Header -->
    <div class="chat-header q-pa-md bg-primary text-white">
      <div class="row items-center justify-between">
        <div class="col">
          <h5 class="q-ma-none">Agent Assistant</h5>
          <div class="text-caption">
            <q-icon
              :name="connectionIcon"
              :color="connectionColor"
              class="q-mr-xs"
            />
            {{ connectionStatus }}
          </div>
        </div>
        <div class="col-auto">
          <q-btn
            flat
            round
            icon="settings"
            @click="showSettings = true"
            class="q-mr-sm"
          />
          <q-btn
            v-if="isConnected"
            flat
            round
            icon="refresh"
            @click="reconnect"
            :loading="isConnecting"
          />
        </div>
      </div>
    </div>

    <!-- Online Users Bar -->
    <online-users-bar />

    <!-- Messages Area -->
    <div class="chat-messages q-pa-md" ref="messagesContainer">
      <!-- Loading State -->
      <div v-if="isConnecting" class="text-center q-mt-xl">
        <loading-spinner
          message="正在连接到 Agent Assistant 服务器..."
          color="primary"
          size="50px"
        />
      </div>

      <!-- Empty State -->
      <div v-else-if="messages.length === 0 && isConnected" class="text-center text-grey-6 q-mt-xl">
        <q-icon name="chat" size="4rem" class="q-mb-md" />
        <div class="text-h6">等待 AI Agent 的消息...</div>
        <div class="text-body2">连接成功后，AI Agent 的问题和任务将在这里显示</div>
      </div>

      <!-- Error State -->
      <div v-else-if="connectionError && !isConnected" class="text-center text-red-6 q-mt-xl">
        <q-icon name="error" size="4rem" class="q-mb-md" />
        <div class="text-h6">连接失败</div>
        <div class="text-body2">{{ connectionError }}</div>
      </div>

      <!-- Messages -->
      <div v-else-if="messages.length > 0">
        <chat-message
          v-for="message in messages"
          :key="message.id"
          :message="message"
          @reply="handleReply"
          @confirm="handleConfirm"
          class="q-mb-md"
        />
      </div>
    </div>

    <!-- Pending Actions -->
    <div v-if="pendingQuestions.length > 0 || pendingTasks.length > 0" class="pending-actions q-pa-md bg-orange-1">
      <div class="text-subtitle2 text-orange-8 q-mb-sm">
        <q-icon name="pending_actions" class="q-mr-xs" />
        待处理项目
      </div>

      <div v-if="pendingQuestions.length > 0" class="q-mb-sm">
        <div class="text-body2 text-orange-7">
          {{ pendingQuestions.length }} 个问题等待回复
        </div>
      </div>

      <div v-if="pendingTasks.length > 0">
        <div class="text-body2 text-orange-7">
          {{ pendingTasks.length }} 个任务等待确认
        </div>
      </div>
    </div>

    <!-- Connection Error -->
    <div v-if="connectionError" class="connection-error q-pa-md bg-red-1">
      <div class="text-red-8">
        <q-icon name="error" class="q-mr-xs" />
        {{ connectionError }}
      </div>
      <q-btn
        flat
        color="red"
        label="重新连接"
        @click="reconnect"
        :loading="isConnecting"
        class="q-mt-sm"
      />
    </div>

    <!-- Settings Dialog -->
    <q-dialog v-model="showSettings" persistent>
      <q-card style="min-width: 400px">
        <q-card-section>
          <div class="text-h6">设置</div>
        </q-card-section>

        <q-card-section>
          <nickname-settings
            v-model="userNickname"
            @save="handleNicknameSave"
          />
        </q-card-section>

        <q-card-actions align="right">
          <q-btn flat label="关闭" color="primary" @click="showSettings = false" />
        </q-card-actions>
      </q-card>
    </q-dialog>
  </q-page>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, nextTick, watch } from 'vue';
import { useRoute } from 'vue-router';
import { useChatStore } from '../stores/chat';
import ChatMessage from '../components/chat/ChatMessage.vue';
import LoadingSpinner from '../components/LoadingSpinner.vue';
import NicknameSettings from '../components/settings/NicknameSettings.vue';
import OnlineUsersBar from '../components/OnlineUsersBar.vue';
import { getTokenFromUrl, buildWebSocketUrl, isValidToken } from '../utils/url';

const route = useRoute();
const chatStore = useChatStore();
const messagesContainer = ref<HTMLElement>();
const showSettings = ref(false);

// Computed properties
const messages = computed(() => chatStore.messages);
const isConnected = computed(() => chatStore.isConnected);
const isConnecting = computed(() => chatStore.isConnecting);
const connectionError = computed(() => chatStore.connectionError);
const pendingQuestions = computed(() => chatStore.pendingQuestions);
const pendingTasks = computed(() => chatStore.pendingTasks);
const userNickname = computed(() => chatStore.userNickname);

const connectionStatus = computed(() => {
  if (isConnecting.value) return '连接中...';
  if (isConnected.value) return '已连接';
  if (connectionError.value) return '连接失败';
  return '未连接';
});

const connectionIcon = computed(() => {
  if (isConnecting.value) return 'sync';
  if (isConnected.value) return 'wifi';
  return 'wifi_off';
});

const connectionColor = computed(() => {
  if (isConnecting.value) return 'orange';
  if (isConnected.value) return 'green';
  return 'red';
});

// Methods
function handleReply(messageId: string, replyText: string) {
  chatStore.replyToQuestion(messageId, replyText);
}

function handleConfirm(messageId: string, confirmText?: string) {
  chatStore.confirmTask(messageId, confirmText);
}

function handleNicknameSave(nickname: string) {
  chatStore.setNickname(nickname);
  // The setNickname method now automatically updates the server if connected
}

async function reconnect() {
  const token = route.query.token as string;
  if (token) {
    await initializeConnection(token);
  }
}

async function initializeConnection(token: string): Promise<void> {
  if (!isValidToken(token)) {
    console.error('Invalid token provided');
    return;
  }

  const wsUrl = buildWebSocketUrl();
  console.log('Connecting to WebSocket:', wsUrl);

  return chatStore.initializeWebSocket(token, wsUrl).catch(error => {
    console.error('Failed to connect to WebSocket:', error);
  });
}

function scrollToBottom() {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
    }
  }).catch(err => console.error('scrollToBottom nextTick error:', err));
}

// Watch for new messages and scroll to bottom
watch(messages, () => {
  scrollToBottom();
}, { deep: true });

// Lifecycle
onMounted(async () => {
  // Load nickname first
  chatStore.loadNickname();

  // Try to get token from URL query parameters first, then from utility function
  let token = route.query.token as string;
  if (!token) {
    token = getTokenFromUrl() || '';
  }

  if (!token) {
    console.error('No token provided in URL query parameters');
    chatStore.setConnectionError('缺少访问令牌，请检查URL参数');
    return;
  }

  if (!isValidToken(token)) {
    console.error('Invalid token format');
    chatStore.setConnectionError('无效的访问令牌格式');
    return;
  }

  await initializeConnection(token);
});

onUnmounted(() => {
  chatStore.disconnect();
});
</script>

<style scoped>
.chat-page {
  height: 100vh;
  display: flex;
  flex-direction: column;
}

.chat-header {
  flex-shrink: 0;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  background-color: #f5f5f5;
}

.pending-actions,
.connection-error {
  flex-shrink: 0;
}

.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>
