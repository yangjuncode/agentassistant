<template>
  <div class="chat-message">
    <!-- Agent Question -->
    <q-card v-if="message.type === 'question'" class="agent-message">
      <q-card-section class="bg-blue-1">
        <div class="row items-center q-mb-sm">
          <q-icon name="smart_toy" color="blue" class="q-mr-sm" />
          <span class="text-subtitle2 text-blue-8">AI Agent 提问</span>
          <q-space />
          <q-chip 
            v-if="message.isAnswered" 
            color="green" 
            text-color="white" 
            size="sm"
            icon="check"
          >
            已回复
          </q-chip>
          <q-chip 
            v-else 
            color="orange" 
            text-color="white" 
            size="sm"
            icon="help"
          >
            待回复
          </q-chip>
        </div>
        
        <div class="text-body1 q-mb-sm">{{ message.content }}</div>
        
        <div class="text-caption text-grey-6">
          <div v-if="message.projectDirectory">
            <q-icon name="folder" class="q-mr-xs" />
            项目目录: {{ message.projectDirectory }}
          </div>
          <div>
            <q-icon name="schedule" class="q-mr-xs" />
            {{ formatTime(message.timestamp) }}
            <span v-if="message.timeout"> • 超时: {{ message.timeout }}秒</span>
          </div>
        </div>
      </q-card-section>

      <!-- Reply Section -->
      <q-card-section v-if="!message.isAnswered" class="bg-white">
        <div class="reply-section">
          <q-input
            v-model="replyText"
            type="textarea"
            label="输入您的回复..."
            outlined
            rows="3"
            class="q-mb-sm"
            @keydown.ctrl.enter="submitReply"
          />
          <div class="row justify-end">
            <q-btn
              color="primary"
              label="发送回复"
              icon="send"
              @click="submitReply"
              :disable="!replyText.trim()"
            />
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- Agent Task Finish -->
    <q-card v-else-if="message.type === 'task'" class="agent-message">
      <q-card-section class="bg-green-1">
        <div class="row items-center q-mb-sm">
          <q-icon name="task_alt" color="green" class="q-mr-sm" />
          <span class="text-subtitle2 text-green-8">任务完成</span>
          <q-space />
          <q-chip 
            v-if="message.isAnswered" 
            color="green" 
            text-color="white" 
            size="sm"
            icon="check"
          >
            已确认
          </q-chip>
          <q-chip 
            v-else 
            color="orange" 
            text-color="white" 
            size="sm"
            icon="pending"
          >
            待确认
          </q-chip>
        </div>
        
        <div class="text-body1 q-mb-sm">{{ message.content }}</div>
        
        <div class="text-caption text-grey-6">
          <div v-if="message.projectDirectory">
            <q-icon name="folder" class="q-mr-xs" />
            项目目录: {{ message.projectDirectory }}
          </div>
          <div>
            <q-icon name="schedule" class="q-mr-xs" />
            {{ formatTime(message.timestamp) }}
            <span v-if="message.timeout"> • 超时: {{ message.timeout }}秒</span>
          </div>
        </div>
      </q-card-section>

      <!-- Confirm Section -->
      <q-card-section v-if="!message.isAnswered" class="bg-white">
        <div class="confirm-section">
          <q-input
            v-model="confirmText"
            label="确认信息 (可选)"
            outlined
            class="q-mb-sm"
            placeholder="任务已确认"
          />
          <div class="row justify-end q-gutter-sm">
            <q-btn
              color="positive"
              label="确认完成"
              icon="check"
              @click="submitConfirm"
            />
          </div>
        </div>
      </q-card-section>
    </q-card>

    <!-- User Reply -->
    <div v-else-if="message.type === 'reply'" class="user-message">
      <q-card class="bg-primary text-white">
        <q-card-section>
          <div class="row items-center q-mb-sm">
            <q-icon name="person" class="q-mr-sm" />
            <span class="text-subtitle2">您的回复</span>
            <q-space />
            <span class="text-caption">{{ formatTime(message.timestamp) }}</span>
          </div>
          <div class="text-body1">{{ message.content }}</div>
        </q-card-section>
      </q-card>
    </div>

    <!-- Notification -->
    <div v-else-if="message.type === 'notification'" class="notification-message">
      <q-banner class="bg-orange-1 text-orange-8">
        <template v-slot:avatar>
          <q-icon name="notifications" />
        </template>
        {{ message.content }}
        <template v-slot:action>
          <span class="text-caption">{{ formatTime(message.timestamp) }}</span>
        </template>
      </q-banner>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import type { ChatMessage } from '../../stores/chat';

interface Props {
  message: ChatMessage;
}

interface Emits {
  (e: 'reply', messageId: string, replyText: string): void;
  (e: 'confirm', messageId: string, confirmText?: string): void;
}

const props = defineProps<Props>();
const emit = defineEmits<Emits>();

const replyText = ref('');
const confirmText = ref('任务已确认');

function submitReply() {
  if (replyText.value.trim()) {
    emit('reply', props.message.id, replyText.value.trim());
    replyText.value = '';
  }
}

function submitConfirm() {
  emit('confirm', props.message.id, confirmText.value.trim() || undefined);
  confirmText.value = '任务已确认';
}

function formatTime(date: Date): string {
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  });
}
</script>

<style scoped>
.chat-message {
  max-width: 800px;
  margin: 0 auto;
}

.agent-message {
  margin-right: 20%;
}

.user-message {
  margin-left: 20%;
  display: flex;
  justify-content: flex-end;
}

.notification-message {
  margin: 0 10%;
}

.reply-section,
.confirm-section {
  border-top: 1px solid #e0e0e0;
  padding-top: 16px;
}

@media (max-width: 600px) {
  .agent-message {
    margin-right: 5%;
  }
  
  .user-message {
    margin-left: 5%;
  }
  
  .notification-message {
    margin: 0 2%;
  }
}
</style>
