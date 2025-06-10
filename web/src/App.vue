<template>
  <router-view />
  <StagewiseToolbar v-if="isDev" :config="{ plugins: [] }" />
</template>

<script setup lang="ts">
import { StagewiseToolbar } from '@stagewise/toolbar-vue';

const isDev = process.env.NODE_ENV === 'development';
</script>
