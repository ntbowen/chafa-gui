#!/bin/bash
# 打包源码以便传输到ARM设备编译

set -e

echo "📦 打包Chafa GUI源码..."
echo ""

# 创建源码包
tar czf chafa-gui-source.tar.gz \
  --exclude='node_modules' \
  --exclude='dist' \
  --exclude='src-tauri/target' \
  --exclude='.git' \
  --exclude='*.AppImage' \
  --exclude='已清理文件-备份-*' \
  src/ \
  src-tauri/ \
  assets/ \
  docs/ \
  package.json \
  package-lock.json \
  vite.config.js \
  tailwind.config.js \
  postcss.config.js \
  index.html \
  build-appimage.sh \
  README.md \
  .gitignore

echo "✅ 源码包已创建"
echo ""
echo "文件: chafa-gui-source.tar.gz"
echo "大小: $(du -h chafa-gui-source.tar.gz | cut -f1)"
echo ""
echo "================================"
echo "📋 下一步操作"
echo "================================"
echo ""
echo "1️⃣  传输到ARM设备:"
echo "   scp chafa-gui-source.tar.gz user@arm-device:~/"
echo ""
echo "2️⃣  在ARM设备上解压并编译:"
echo "   ssh user@arm-device"
echo "   tar xzf chafa-gui-source.tar.gz"
echo "   cd chafa-gui"
echo ""
echo "3️⃣  安装依赖 (Raspberry Pi OS/Debian):"
echo "   sudo apt update"
echo "   sudo apt install -y build-essential pkg-config libssl-dev \\"
echo "     libgtk-3-dev libwebkit2gtk-4.1-dev libjavascriptcoregtk-4.1-dev \\"
echo "     libsoup-3.0-dev chafa"
echo ""
echo "   # 安装Node.js"
echo "   curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
echo "   sudo apt install -y nodejs"
echo ""
echo "   # 安装Rust"
echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
echo "   source \$HOME/.cargo/env"
echo ""
echo "4️⃣  构建:"
echo "   npm install"
echo "   npm run tauri:build"
echo ""
echo "5️⃣  查看构建产物:"
echo "   ls -lh src-tauri/target/release/chafa-gui"
echo "   ls -lh *.AppImage"
echo ""
echo "📖 详细文档: docs/ARM编译方案对比.md"
echo ""
