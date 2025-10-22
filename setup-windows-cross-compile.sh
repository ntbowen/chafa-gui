#!/bin/bash
# 配置Windows x86-64交叉编译环境

set -e

echo "🪟 配置Windows x86-64交叉编译环境..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查当前系统
CURRENT_ARCH=$(uname -m)
CURRENT_OS=$(uname -s)
echo -e "${BLUE}当前系统: ${CURRENT_OS} ${CURRENT_ARCH}${NC}"
echo ""

# 1. 安装Rust Windows目标
echo -e "${YELLOW}1️⃣  安装Rust Windows目标...${NC}"
rustup target add x86_64-pc-windows-gnu
echo -e "${GREEN}   ✓ Rust目标已安装: x86_64-pc-windows-gnu${NC}"
echo ""

# 2. 安装MinGW交叉编译工具链
echo -e "${YELLOW}2️⃣  安装MinGW工具链...${NC}"
if command -v dnf &> /dev/null; then
    # Fedora/RHEL
    echo "   检测到Fedora/RHEL系统"
    sudo dnf install -y mingw64-gcc mingw64-gcc-c++ mingw64-winpthreads-static
    echo -e "${GREEN}   ✓ MinGW工具链已安装${NC}"
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu
    echo "   检测到Debian/Ubuntu系统"
    sudo apt update
    sudo apt install -y gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64
    echo -e "${GREEN}   ✓ MinGW工具链已安装${NC}"
else
    echo "   ⚠️  未检测到包管理器，请手动安装MinGW工具链"
fi
echo ""

# 3. 配置Cargo
echo -e "${YELLOW}3️⃣  配置Cargo交叉编译...${NC}"
mkdir -p ~/.cargo

# 检查配置是否已存在
if ! grep -q "\[target.x86_64-pc-windows-gnu\]" ~/.cargo/config.toml 2>/dev/null; then
    cat >> ~/.cargo/config.toml << 'EOF'

[target.x86_64-pc-windows-gnu]
linker = "x86_64-w64-mingw32-gcc"
ar = "x86_64-w64-mingw32-ar"
EOF
    echo -e "${GREEN}   ✓ Cargo配置已更新${NC}"
else
    echo -e "${GREEN}   ✓ Cargo配置已存在${NC}"
fi
echo ""

# 4. 创建Windows构建脚本
echo -e "${YELLOW}4️⃣  创建Windows构建脚本...${NC}"
cat > build-windows.sh << 'EOFSCRIPT'
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
EOFSCRIPT
chmod +x build-windows.sh
echo -e "${GREEN}   ✓ Windows构建脚本已创建: build-windows.sh${NC}"
echo ""

# 5. 验证工具链
echo -e "${YELLOW}5️⃣  验证工具链...${NC}"
if command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    echo -e "${GREEN}   ✓ MinGW GCC: $(x86_64-w64-mingw32-gcc --version | head -1)${NC}"
else
    echo -e "${YELLOW}   ⚠️  找不到 x86_64-w64-mingw32-gcc${NC}"
fi

if rustup target list | grep -q "x86_64-pc-windows-gnu (installed)"; then
    echo -e "${GREEN}   ✓ Rust目标已安装${NC}"
else
    echo -e "${YELLOW}   ⚠️  Rust目标未安装${NC}"
fi
echo ""

# 显示使用说明
echo ""
echo "================================"
echo -e "${GREEN}✅ Windows交叉编译环境配置完成！${NC}"
echo "================================"
echo ""
echo -e "${BLUE}📋 使用说明:${NC}"
echo ""
echo "1️⃣  构建Windows版本:"
echo "   ./build-windows.sh"
echo ""
echo "2️⃣  手动构建:"
echo "   npm run build"
echo "   cd src-tauri"
echo "   cargo build --release --target x86_64-pc-windows-gnu"
echo ""
echo "3️⃣  测试（需要Wine）:"
echo "   wine src-tauri/target/x86_64-pc-windows-gnu/release/chafa-gui.exe"
echo ""
echo -e "${YELLOW}⚠️  注意事项:${NC}"
echo "1. 编译出的 .exe 只能在Windows上运行"
echo "2. Windows系统需要安装 Chafa for Windows"
echo "3. 需要 Windows 10 1809+ 或已安装 Microsoft Edge WebView2"
echo ""
echo -e "${BLUE}🔧 Windows系统依赖安装:${NC}"
echo "1. Chafa for Windows:"
echo "   https://hpjansson.org/chafa/download/"
echo ""
echo "2. WebView2 Runtime (通常已预装):"
echo "   https://developer.microsoft.com/microsoft-edge/webview2/"
echo ""
