<template>
  <div class="loading-spinner">
    <q-spinner-dots
      :size="size"
      :color="color"
    />
    <div v-if="message" class="loading-message q-mt-sm">
      {{ message }}
    </div>
  </div>
</template>

<script setup lang="ts">
interface Props {
  size?: string;
  color?: string;
  message?: string;
}

withDefaults(defineProps<Props>(), {
  size: '40px',
  color: 'primary',
  message: ''
});
</script>

<style scoped>
.loading-spinner {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.loading-message {
  text-align: center;
  color: #666;
  font-size: 0.9rem;
}
</style>
