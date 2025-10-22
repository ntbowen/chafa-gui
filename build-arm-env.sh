#!/bin/bash
# ARM交叉编译环境变量

export TARGET_ARCH=aarch64-unknown-linux-gnu
export TARGET_CC=aarch64-linux-gnu-gcc
export TARGET_CXX=aarch64-linux-gnu-g++
export TARGET_AR=aarch64-linux-gnu-ar
export TARGET_RANLIB=aarch64-linux-gnu-ranlib

# PKG_CONFIG配置（可能需要根据实际情况调整）
export PKG_CONFIG_ALLOW_CROSS=1
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig

echo "✅ ARM交叉编译环境已加载"
echo "   目标: $TARGET_ARCH"
echo "   编译器: $TARGET_CC"
