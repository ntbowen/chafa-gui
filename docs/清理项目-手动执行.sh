#!/bin/bash
# 分步清理项目

BACKUP_DIR="已清理文件-备份-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🧹 开始清理..."

# 安全移动函数
safe_move() {
    if [ -e "$1" ]; then
        mv "$1" "$BACKUP_DIR/" 2>/dev/null && echo "✓ $1" || echo "✗ $1 (跳过)"
    fi
}

# Electron
safe_move "scripts"
safe_move ".electron-vite.config.js"
safe_move "build-electron.sh"

# Web
safe_move "server.js"
safe_move "start-web.sh"
safe_move "package-web.sh"
safe_move "chafa-gui-web-v1.0.0.tar.gz"
safe_move "chafa-gui-web-v1.0.0.zip"

# 构建
safe_move "build.sh"
safe_move "build.log"
safe_move "build-output.log"
safe_move "tauri-build.log"
safe_move "tauri-final-build.log"
safe_move "chafa-gui.spec"

# 文档
safe_move "WEB版本使用指南.md"
safe_move "已完成-静态Web版本.md"
safe_move "使用说明.md"
safe_move "打包说明.md"
safe_move "README_PACKAGING.md"
safe_move "BUILD.md"
safe_move "CHANGELOG.md"
safe_move "RELEASE.md"
safe_move "QUICKSTART.md"
safe_move "README.md"
safe_move "跨平台构建指南.md"
safe_move "轻量级方案-Tauri.md"
safe_move "Tauri构建进度.md"
safe_move "TAURI迁移完成状态.md"
safe_move "Tauri迁移实现.md"
safe_move "问题已全部解决.md"
safe_move "全部程序已生成.md"
safe_move "可执行程序已完成.md"

# 示例
safe_move "src-example-tauri"
safe_move "src-tauri-example"
safe_move "已废弃的文件-备份-20251021"

# 临时
safe_move "uploads"
safe_move "release"
safe_move "build"
safe_move "package.json.bak"
safe_move "test-appimage.sh"

# 脚本
safe_move "开始Tauri迁移.sh"
safe_move "清理过时文件.sh"
safe_move "彻底清理Web启动器.sh"
safe_move "重新生成图标.sh"
safe_move "彻底清理为纯Tauri项目.sh"

echo "✅ 清理完成！备份到: $BACKUP_DIR"
