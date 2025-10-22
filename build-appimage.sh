#!/bin/bash
# 手动构建AppImage

set -e

echo "🔨 手动构建Chafa GUI AppImage..."

# 构建变量
APP_NAME="Chafa-GUI"
VERSION="1.0.0"
ARCH="x86_64"
BINARY="src-tauri/target/release/chafa-gui"
APPDIR="/tmp/${APP_NAME}.AppDir"

# 清理旧的AppDir
rm -rf "$APPDIR"
mkdir -p "$APPDIR"

# 创建目录结构
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/128x128/apps"

# 复制二进制文件
echo "📦 复制可执行文件..."
cp "$BINARY" "$APPDIR/usr/bin/chafa-gui"
chmod +x "$APPDIR/usr/bin/chafa-gui"

# 创建desktop文件
echo "📝 创建desktop文件..."
cat > "$APPDIR/usr/share/applications/chafa-gui.desktop" << 'EOF'
[Desktop Entry]
Name=Chafa GUI
Comment=Image to ANSI Art Converter
Exec=chafa-gui
Icon=chafa-gui
Type=Application
Categories=Graphics;
Terminal=false
EOF

# 复制图标
echo "🎨 复制图标..."
if [ -f "src-tauri/icons/128x128.png" ]; then
    cp "src-tauri/icons/128x128.png" "$APPDIR/usr/share/icons/hicolor/128x128/apps/chafa-gui.png"
elif [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APPDIR/usr/share/icons/hicolor/128x128/apps/chafa-gui.png"
fi

# 创建AppRun
echo "⚙️  创建AppRun..."
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/chafa-gui" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# 复制desktop和icon到根目录
cp "$APPDIR/usr/share/applications/chafa-gui.desktop" "$APPDIR/"
cp "$APPDIR/usr/share/icons/hicolor/128x128/apps/chafa-gui.png" "$APPDIR/"

# 使用appimagetool打包
echo "📦 打包AppImage..."
OUTPUT_NAME="Chafa-GUI-${VERSION}-${ARCH}.AppImage"

# 方法1: 使用linuxdeploy
if [ -x ~/.cache/tauri/linuxdeploy-x86_64.AppImage ]; then
    echo "使用linuxdeploy..."
    # 设置环境变量
    export ARCH=x86_64
    
    # 下载appimagetool如果不存在
    if [ ! -f ~/.cache/tauri/appimagetool-x86_64.AppImage ]; then
        echo "下载appimagetool..."
        wget -q -O ~/.cache/tauri/appimagetool-x86_64.AppImage \
            "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
        chmod +x ~/.cache/tauri/appimagetool-x86_64.AppImage
    fi
    
    # 打包
    ~/.cache/tauri/appimagetool-x86_64.AppImage "$APPDIR" "$OUTPUT_NAME"
else
    # 方法2: 使用tar打包
    echo "使用tar打包..."
    cd "$APPDIR"
    tar czf "../${APP_NAME}-${VERSION}-${ARCH}.tar.gz" .
    cd -
    echo "✅ 已创建: ${APP_NAME}-${VERSION}-${ARCH}.tar.gz"
fi

if [ -f "$OUTPUT_NAME" ]; then
    chmod +x "$OUTPUT_NAME"
    echo ""
    echo "✅ AppImage构建成功！"
    echo "📦 文件: $OUTPUT_NAME"
    echo "📏 大小: $(du -h "$OUTPUT_NAME" | cut -f1)"
    echo ""
    echo "🚀 运行: ./$OUTPUT_NAME"
else
    echo "⚠️  AppImage构建失败，但已创建AppDir"
    echo "📂 位置: $APPDIR"
fi

echo ""
echo "✅ 构建完成！"
