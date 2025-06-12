<template>
  <svg
    :width="String(size)"
    :height="String(size)"
    :viewBox="viewBox"
    :class="['icon', `icon-${name}`]"
    fill="currentColor"
  >
    <path :d="iconPath || ''" />
  </svg>
</template>

<script setup lang="ts">
import { computed, defineOptions } from 'vue'

defineOptions({
  name: 'IconComponent'
})

interface Props {
  name: string
  size?: number | string
}

const props = withDefaults(defineProps<Props>(), {
  size: 24
})

const viewBox = computed(() => '0 0 24 24')

const iconPaths: Record<string, string> = {
  people: 'M16 4c0-1.11.89-2 2-2s2 .89 2 2-.89 2-2 2-2-.89-2-2zm4 18v-6h2.5l-2.54-7.63A1.5 1.5 0 0 0 18.54 8H17c-.8 0-1.54.37-2.01 1.01L14 10l-1-1.99C12.54 7.37 11.8 7 11 7H9.46c-.8 0-1.51.37-1.96 1.01L5 16h2.5v6h4V11.5h1v10.5h4zM12.5 11.5c.83 0 1.5-.67 1.5-1.5s-.67-1.5-1.5-1.5S11 9.17 11 10s.67 1.5 1.5 1.5zM7 4c0-1.11.89-2 2-2s2 .89 2 2-.89 2-2 2-2-.89-2-2z',
  refresh: 'M17.65 6.35C16.2 4.9 14.21 4 12 4c-4.42 0-7.99 3.58-7.99 8s3.57 8 7.99 8c3.73 0 6.84-2.55 7.73-6h-2.08c-.82 2.33-3.04 4-5.65 4-3.31 0-6-2.69-6-6s2.69-6 6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z',
  close: 'M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z',
  send: 'M2.01 21L23 12 2.01 3 2 10l15 2-15 2z',
  chat: 'M20 2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h4l4 4 4-4h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2z'
}

const iconPath = computed(() => {
  return iconPaths[props.name] || iconPaths.chat
})
</script>

<style scoped>
.icon {
  display: inline-block;
  vertical-align: middle;
  transition: all 0.2s ease;
}
</style>
