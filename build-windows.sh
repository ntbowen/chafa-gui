#!/bin/bash
# Windows x86-64构建脚本

set -e

echo "🪟 构建Windows x86-64版本..."
echo ""

TARGET="x86_64-pc-windows-gnu"

# 1. 构建前端
echo "1️⃣  构建前端..."
npm run build
echo "✅ 前端构建完成"
echo ""

# 2. 构建Windows二进制
echo "2️⃣  构建Windows二进制..."
cd src-tauri
cargo build --release --target $TARGET
cd ..

BINARY_PATH="src-tauri/target/$TARGET/release/chafa-gui.exe"

if [ -f "$BINARY_PATH" ]; then
    echo ""
    echo "================================"
    echo "✅ Windows二进制构建成功！"
    echo "================================"
    echo "位置: $BINARY_PATH"
    echo "大小: $(du -h $BINARY_PATH | cut -f1)"
    echo "类型: $(file $BINARY_PATH | cut -d: -f2)"
    echo ""
    echo "📦 创建发布包..."
    
    # 创建Windows发布目录
    RELEASE_DIR="chafa-gui-windows-x64"
    rm -rf $RELEASE_DIR
    mkdir -p $RELEASE_DIR
    
    # 复制文件
    cp $BINARY_PATH $RELEASE_DIR/
    cp README.md $RELEASE_DIR/
    
    # 创建README
    cat > $RELEASE_DIR/README.txt << 'EOF'
Chafa GUI - Windows x64 版本
============================

运行要求:
1. 安装 Chafa for Windows
   下载地址: https://hpjansson.org/chafa/download/
   
2. 确保 chafa.exe 在系统 PATH 中

3. 双击 chafa-gui.exe 运行

如果遇到问题，请访问:
https://github.com/yourusername/chafa-gui

EOF
    
    # 打包
    zip -r ${RELEASE_DIR}.zip $RELEASE_DIR/
    
    echo ""
    echo "📦 发布包已创建:"
    echo "   目录: $RELEASE_DIR/"
    echo "   压缩包: ${RELEASE_DIR}.zip ($(du -h ${RELEASE_DIR}.zip | cut -f1))"
    echo ""
    echo "⚠️  注意:"
    echo "1. 此程序只能在Windows上运行"
    echo "2. 需要在Windows上安装 Chafa"
    echo "3. WebView2运行时需要Windows 10 1809+或已安装WebView2"
else
    echo ""
    echo "❌ 构建失败: 找不到二进制文件"
    exit 1
fi
