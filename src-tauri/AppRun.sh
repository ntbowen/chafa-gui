#!/bin/bash
# AppImage启动脚本 - 设置环境变量以修复WebView问题

SELF=$(readlink -f "$0")
HERE=${SELF%/*}

# 设置WebView相关环境变量
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_FORCE_SANDBOX=0
export GDK_BACKEND=x11

# 如果还有问题，取消注释下面这行
# export WEBKIT_DISABLE_DMABUF_RENDERER=1

# 运行实际程序
exec "${HERE}/chafa-gui" "$@"
