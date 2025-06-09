#!/bin/bash

# Agent Assistant Web Development Server Startup Script

echo "🚀 Starting Agent Assistant Web Development Server..."
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    pnpm install
    echo ""
fi

# Check if dependencies are installed
if [ ! -f "node_modules/.pnpm/lock.yaml" ] && [ ! -f "pnpm-lock.yaml" ]; then
    echo "❌ Dependencies not properly installed. Please run 'pnpm install' manually."
    exit 1
fi

echo "🌐 Starting development server..."
echo "📍 Server will be available at: http://localhost:9000"
echo "🔗 Access with token: http://localhost:9000?token=your-token"
echo ""
echo "💡 Make sure agentassistant-srv is running on the same host"
echo "⚡ Press Ctrl+C to stop the server"
echo ""

# Start the development server
pnpm dev --host 0.0.0.0 --port 9000
