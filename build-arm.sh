#!/bin/bash
# ARM架构构建脚本

set -e

# 加载环境变量
source build-arm-env.sh

echo "🔨 构建ARM版本..."
echo "目标架构: $TARGET_ARCH"
echo ""

# 构建前端
echo "1️⃣  构建前端..."
npm run build
echo "✅ 前端构建完成"
echo ""

# 构建Tauri (只构建二进制，不打包)
echo "2️⃣  构建ARM二进制..."
cd src-tauri
cargo build --release --target $TARGET_ARCH
cd ..

BINARY_PATH="src-tauri/target/$TARGET_ARCH/release/chafa-gui"

if [ -f "$BINARY_PATH" ]; then
    echo ""
    echo "================================"
    echo "✅ ARM二进制构建成功！"
    echo "================================"
    echo "位置: $BINARY_PATH"
    echo "大小: $(du -h $BINARY_PATH | cut -f1)"
    echo "架构: $(file $BINARY_PATH | cut -d: -f2)"
    echo ""
    echo "⚠️  注意: 此二进制只能在ARM设备上运行"
    echo ""
    echo "📦 传输到ARM设备:"
    echo "   scp $BINARY_PATH user@arm-device:/path/to/destination/"
else
    echo "❌ 构建失败: 找不到二进制文件"
    exit 1
fi
