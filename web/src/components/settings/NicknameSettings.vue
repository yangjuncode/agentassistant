<template>
  <q-card class="nickname-settings">
    <q-card-section>
      <div class="text-h6">昵称设置</div>
      <div class="text-caption text-grey-6">设置您在聊天中显示的昵称</div>
    </q-card-section>

    <q-card-section>
      <q-input
        v-model="localNickname"
        label="昵称"
        outlined
        dense
        maxlength="20"
        counter
        :rules="[
          val => !!val || '昵称不能为空',
          val => val.length >= 2 || '昵称至少需要2个字符',
          val => val.length <= 20 || '昵称不能超过20个字符'
        ]"
        @keyup.enter="saveNickname"
      >
        <template v-slot:prepend>
          <q-icon name="person" />
        </template>
      </q-input>
    </q-card-section>

    <q-card-actions align="right">
      <q-btn
        flat
        label="重置"
        color="grey"
        @click="resetNickname"
      />
      <q-btn
        unelevated
        label="保存"
        color="primary"
        :disable="!isValidNickname"
        @click="saveNickname"
      />
    </q-card-actions>
  </q-card>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue';
import { useQuasar } from 'quasar';

const $q = useQuasar();

// Props
interface Props {
  modelValue?: string;
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: ''
});

// Emits
const emit = defineEmits<{
  'update:modelValue': [value: string];
  'save': [nickname: string];
}>();

// Local state
const localNickname = ref('');

// Computed
const isValidNickname = computed(() => {
  return localNickname.value.length >= 2 && localNickname.value.length <= 20;
});

// Methods
function saveNickname() {
  if (!isValidNickname.value) {
    $q.notify({
      type: 'negative',
      message: '请输入有效的昵称（2-20个字符）'
    });
    return;
  }

  // Save to localStorage
  localStorage.setItem('user-nickname', localNickname.value);
  
  // Emit events
  emit('update:modelValue', localNickname.value);
  emit('save', localNickname.value);

  $q.notify({
    type: 'positive',
    message: '昵称已保存',
    timeout: 2000
  });
}

function resetNickname() {
  localNickname.value = generateDefaultNickname();
}

function generateDefaultNickname(): string {
  const adjectives = ['聪明的', '勤奋的', '友善的', '活跃的', '创新的', '专业的'];
  const nouns = ['开发者', '用户', '助手', '伙伴', '同事', '朋友'];
  
  const adjective = adjectives[Math.floor(Math.random() * adjectives.length)];
  const noun = nouns[Math.floor(Math.random() * nouns.length)];
  const number = Math.floor(Math.random() * 1000);
  
  return `${adjective}${noun}${number}`;
}

function loadNickname() {
  const saved = localStorage.getItem('user-nickname');
  if (saved) {
    localNickname.value = saved;
  } else if (props.modelValue) {
    localNickname.value = props.modelValue;
  } else {
    localNickname.value = generateDefaultNickname();
  }
}

// Lifecycle
onMounted(() => {
  loadNickname();
});
</script>

<style scoped>
.nickname-settings {
  max-width: 400px;
  margin: 0 auto;
}
</style>
