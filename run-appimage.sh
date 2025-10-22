#!/bin/bash
# 临时包装脚本 - 在 Tauri AppImage 打包支持自定义 AppRun 之前使用

# 检测会话类型
SESSION_TYPE="${XDG_SESSION_TYPE:-x11}"

echo "🔧 Detected session type: $SESSION_TYPE"

# 设置环境变量
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export LIBGL_ALWAYS_SOFTWARE=1

# Wayland 特定设置
if [ "$SESSION_TYPE" = "wayland" ]; then
    echo "🔧 Applying Wayland compatibility settings..."
    # 不设置 GDK_BACKEND，让它使用 Wayland
    # 但禁用硬件加速
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
    export WEBKIT_DISABLE_SANDBOX=1
    # 如果 Wayland 还是有问题，强制使用 XWayland
    # export GDK_BACKEND=x11
else
    echo "🔧 Applying X11 compatibility settings..."
    export GDK_BACKEND=x11
fi

echo "   - WEBKIT_DISABLE_COMPOSITING_MODE=1"
echo "   - WEBKIT_DISABLE_DMABUF_RENDERER=1"
echo "   - LIBGL_ALWAYS_SOFTWARE=1"
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
