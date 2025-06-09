import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      "@": path.resolve(__dirname, "./src"),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/agentassistproto.SrvAgentAssist': {
        target: 'http://localhost:22080',
        changeOrigin: true,
      },
      '/agentassistproto.SrvAgentAssistReply': {
        target: 'http://localhost:22080',
        changeOrigin: true,
      },
      '/ws': {
        target: 'ws://localhost:22080',
        ws: true,
        changeOrigin: true,
      }
    }
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  }
})
