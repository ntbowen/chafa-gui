#!/bin/bash
# 配置ARM架构交叉编译环境

set -e

echo "🔧 配置ARM架构交叉编译..."
echo ""

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 检查当前架构
CURRENT_ARCH=$(uname -m)
echo -e "${BLUE}当前架构: ${CURRENT_ARCH}${NC}"
echo ""

# 选择目标架构
echo "请选择目标ARM架构:"
echo "1) aarch64 (ARM64/AArch64) - Raspberry Pi 3/4/5, 服务器"
echo "2) armv7 (ARM32 hard-float) - Raspberry Pi 2/3 (32位)"
echo ""
read -p "选择 [1-2]: " choice

case $choice in
    1)
        TARGET="aarch64-unknown-linux-gnu"
        CROSS_PREFIX="aarch64-linux-gnu"
        echo -e "${GREEN}✓ 目标: ARM64 (aarch64)${NC}"
        ;;
    2)
        TARGET="armv7-unknown-linux-gnueabihf"
        CROSS_PREFIX="arm-linux-gnueabihf"
        echo -e "${GREEN}✓ 目标: ARM32 (armv7)${NC}"
        ;;
    *)
        echo "无效选择，默认使用 aarch64"
        TARGET="aarch64-unknown-linux-gnu"
        CROSS_PREFIX="aarch64-linux-gnu"
        ;;
esac

echo ""
echo "================================"
echo "目标架构: $TARGET"
echo "交叉编译前缀: $CROSS_PREFIX"
echo "================================"
echo ""

# 1. 安装Rust目标
echo -e "${YELLOW}1️⃣  安装Rust目标...${NC}"
rustup target add $TARGET
echo -e "${GREEN}   ✓ Rust目标已安装${NC}"
echo ""

# 2. 安装交叉编译工具链
echo -e "${YELLOW}2️⃣  安装交叉编译工具链...${NC}"
if command -v dnf &> /dev/null; then
    # Fedora/RHEL
    if [ "$TARGET" = "aarch64-unknown-linux-gnu" ]; then
        echo "   安装: gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu"
        sudo dnf install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
    else
        echo "   安装: gcc-arm-linux-gnu binutils-arm-linux-gnu"
        sudo dnf install -y gcc-arm-linux-gnu binutils-arm-linux-gnu
    fi
elif command -v apt &> /dev/null; then
    # Debian/Ubuntu
    echo "   安装: gcc-${CROSS_PREFIX} g++-${CROSS_PREFIX}"
    sudo apt update
    sudo apt install -y gcc-${CROSS_PREFIX} g++-${CROSS_PREFIX}
fi
echo -e "${GREEN}   ✓ 交叉编译工具链已安装${NC}"
echo ""

# 3. 配置Cargo
echo -e "${YELLOW}3️⃣  配置Cargo交叉编译...${NC}"
mkdir -p ~/.cargo

if [ "$TARGET" = "aarch64-unknown-linux-gnu" ]; then
    cat >> ~/.cargo/config.toml << EOF

[target.aarch64-unknown-linux-gnu]
linker = "aarch64-linux-gnu-gcc"
EOF
else
    cat >> ~/.cargo/config.toml << EOF

[target.armv7-unknown-linux-gnueabihf]
linker = "arm-linux-gnueabihf-gcc"
EOF
fi

echo -e "${GREEN}   ✓ Cargo配置已更新${NC}"
echo ""

# 4. 配置环境变量
echo -e "${YELLOW}4️⃣  配置环境变量...${NC}"
cat > build-arm-env.sh << EOF
#!/bin/bash
# ARM交叉编译环境变量

export TARGET_ARCH=$TARGET
export TARGET_CC=${CROSS_PREFIX}-gcc
export TARGET_CXX=${CROSS_PREFIX}-g++
export TARGET_AR=${CROSS_PREFIX}-ar
export TARGET_RANLIB=${CROSS_PREFIX}-ranlib

# PKG_CONFIG配置（可能需要根据实际情况调整）
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_PATH=/usr/lib/${CROSS_PREFIX}/pkgconfig

echo "✅ ARM交叉编译环境已加载"
echo "   目标: \$TARGET_ARCH"
echo "   编译器: \$TARGET_CC"
EOF
chmod +x build-arm-env.sh
echo -e "${GREEN}   ✓ 环境变量配置已创建: build-arm-env.sh${NC}"
echo ""

# 5. 创建ARM构建脚本
echo -e "${YELLOW}5️⃣  创建ARM构建脚本...${NC}"
cat > build-arm.sh << 'EOFSCRIPT'
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
EOFSCRIPT
chmod +x build-arm.sh
echo -e "${GREEN}   ✓ ARM构建脚本已创建: build-arm.sh${NC}"
echo ""

# 6. 显示使用说明
echo ""
echo "================================"
echo -e "${GREEN}✅ ARM交叉编译环境配置完成！${NC}"
echo "================================"
echo ""
echo -e "${BLUE}📋 使用说明:${NC}"
echo ""
echo "1️⃣  构建ARM版本:"
echo "   ./build-arm.sh"
echo ""
echo "2️⃣  手动构建:"
echo "   source build-arm-env.sh"
echo "   npm run build"
echo "   cd src-tauri"
echo "   cargo build --release --target $TARGET"
echo ""
echo "3️⃣  传输到ARM设备:"
echo "   scp src-tauri/target/$TARGET/release/chafa-gui user@arm-device:~/"
echo ""
echo -e "${YELLOW}⚠️  注意事项:${NC}"
echo "1. 编译出的二进制只能在ARM设备上运行"
echo "2. 需要确保目标设备安装了依赖: chafa, gtk3, webkit2gtk"
echo "3. 如果遇到链接错误，可能需要安装ARM版本的开发库"
echo ""
echo -e "${BLUE}🔧 安装目标设备依赖 (在ARM设备上):${NC}"
echo "   # Fedora/RHEL"
echo "   sudo dnf install chafa gtk3 webkit2gtk4.1"
echo ""
echo "   # Debian/Ubuntu"
echo "   sudo apt install chafa libgtk-3-0 libwebkit2gtk-4.1-0"
echo ""
