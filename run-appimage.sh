#!/bin/bash
# 临时包装脚本 - 在 Tauri AppImage 打包支持自定义 AppRun 之前使用

# 设置环境变量
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export GDK_BACKEND=x11
export LIBGL_ALWAYS_SOFTWARE=1
export WEBKIT_DISABLE_SANDBOX=1

echo "🔧 Setting environment variables for AppImage compatibility..."
echo "   - WEBKIT_DISABLE_COMPOSITING_MODE=1"
echo "   - WEBKIT_DISABLE_DMABUF_RENDERER=1"
echo "   - GDK_BACKEND=x11"
echo "   - LIBGL_ALWAYS_SOFTWARE=1"
echo "   - WEBKIT_DISABLE_SANDBOX=1"
echo ""

# 查找 AppImage 文件
APPIMAGE=$(find ~/linux-appimage -name "Chafa-GUI*.AppImage" -type f | head -1)

if [ -z "$APPIMAGE" ]; then
    echo "❌ No AppImage found in ~/linux-appimage/"
    echo "Please download the AppImage first."
    exit 1
fi

echo "▶️  Launching: $APPIMAGE"
exec "$APPIMAGE" "$@"
