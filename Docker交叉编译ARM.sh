#!/bin/bash
# 使用Docker进行ARM64交叉编译

set -e

echo "🐳 使用Docker交叉编译ARM64版本..."
echo ""

# 检查Docker
if ! command -v docker &> /dev/null; then
    echo "❌ 请先安装Docker"
    echo "   Fedora: sudo dnf install docker"
    echo "   Ubuntu: sudo apt install docker.io"
    exit 1
fi

# 创建Dockerfile
cat > Dockerfile.arm64 << 'EOF'
FROM --platform=linux/arm64 rust:1.90-slim

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 安装Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

WORKDIR /app

# 复制源码
COPY . .

# 安装npm依赖
RUN npm install

# 构建
RUN npm run build && \
    cd src-tauri && \
    cargo build --release
EOF

echo "✅ Dockerfile已创建"
echo ""
echo "🔨 开始构建（这需要很长时间...）"
echo ""

# 使用buildx进行多架构构建
docker buildx build --platform linux/arm64 -t chafa-gui-arm64 -f Dockerfile.arm64 .

echo ""
echo "📦 提取构建产物..."
CONTAINER_ID=$(docker create chafa-gui-arm64)
docker cp $CONTAINER_ID:/app/src-tauri/target/release/chafa-gui ./chafa-gui-arm64
docker rm $CONTAINER_ID

echo ""
echo "================================"
echo "✅ ARM64二进制已构建！"
echo "================================"
echo "文件: ./chafa-gui-arm64"
echo "大小: $(du -h ./chafa-gui-arm64 | cut -f1)"
echo ""
echo "⚠️  注意: 此文件只能在ARM64设备上运行"
