<template>
  <div class="markdown-content" v-html="renderedHtml"></div>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { marked } from 'marked';

interface Props {
  content: string;
}

const props = defineProps<Props>();

const renderedHtml = computed(() => {
  if (!props.content) return '';
  // Use gfm: true for GitHub Flavored Markdown
  return marked.parse(props.content, { gfm: true, breaks: true });
});
</script>

<style scoped>
.markdown-content :deep(p) {
  margin-bottom: 8px;
}
.markdown-content :deep(p:last-child) {
  margin-bottom: 0;
}
.markdown-content :deep(code) {
  background-color: rgba(0, 0, 0, 0.05);
  padding: 2px 4px;
  border-radius: 4px;
  font-family: monospace;
}
.markdown-content :deep(pre) {
  background-color: rgba(0, 0, 0, 0.05);
  padding: 12px;
  border-radius: 8px;
  overflow-x: auto;
  margin: 8px 0;
}
.markdown-content :deep(pre code) {
  padding: 0;
  background-color: transparent;
}
.markdown-content :deep(ul), .markdown-content :deep(ol) {
  padding-left: 20px;
  margin-bottom: 8px;
}
.markdown-content :deep(h1), .markdown-content :deep(h2), .markdown-content :deep(h3) {
  font-weight: bold;
  margin-top: 12px;
  margin-bottom: 8px;
}
.markdown-content :deep(h1) { font-size: 1.5rem; }
.markdown-content :deep(h2) { font-size: 1.3rem; }
.markdown-content :deep(h3) { font-size: 1.1rem; }
.markdown-content :deep(blockquote) {
  border-left: 4px solid #ccc;
  padding-left: 12px;
  margin-left: 0;
  color: #666;
}
</style>
