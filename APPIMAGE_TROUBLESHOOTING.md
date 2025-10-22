# AppImage 故障排除指南

## ✅ 最新修复（v1.0.1+）

**EGL 错误已修复！** 最新版本已在应用启动时自动禁用硬件加速，解决了 `Could not create default EGL display: EGL_BAD_PARAMETER` 错误。

如果您仍然遇到问题，请尝试以下解决方案：

## 快速修复

### 方法 1: 禁用沙箱
```bash
./Chafa-GUI-*.AppImage --no-sandbox
```

### 方法 2: 设置环境变量
```bash
WEBKIT_DISABLE_COMPOSITING_MODE=1 ./Chafa-GUI-*.AppImage
```

### 方法 3: 强制使用 X11
```bash
GDK_BACKEND=x11 ./Chafa-GUI-*.AppImage
```

### 方法 4: 组合使用
```bash
WEBKIT_DISABLE_COMPOSITING_MODE=1 GDK_BACKEND=x11 ./Chafa-GUI-*.AppImage --no-sandbox
```

## 详细调试

### 查看详细日志
```bash
RUST_LOG=debug ./Chafa-GUI-*.AppImage 2>&1 | tee appimage-debug.log
```

### 检查依赖
```bash
# 提取 AppImage
./Chafa-GUI-*.AppImage --appimage-extract

# 检查缺失的依赖
ldd squashfs-root/usr/bin/chafa-gui | grep "not found"

# 手动运行
cd squashfs-root
./AppRun
```

## 推荐的替代方案

如果 AppImage 无法正常工作，建议使用：

### Debian/Ubuntu
```bash
sudo dpkg -i Chafa-GUI_*.deb
# 或
sudo apt install ./Chafa-GUI_*.deb
```

### Fedora/RHEL/CentOS
```bash
sudo dnf install Chafa-GUI-*.rpm
# 或
sudo rpm -i Chafa-GUI-*.rpm
```

### Arch Linux
```bash
# 使用 AUR helper
yay -S chafa-gui
```

## 常见问题

### Q: 为什么 AppImage 会出现空白窗口？
A: 这通常是由于 WebView (WebKit2GTK) 的兼容性问题引起的。不同的 Linux 发行版和桌面环境可能有不同的库版本。

### Q: 为什么 DEB/RPM 包能工作但 AppImage 不行？
A: DEB/RPM 包使用系统安装的库，而 AppImage 尝试打包所有依赖。这可能导致库版本冲突或兼容性问题。

### Q: 我应该报告这个问题吗？
A: 是的！如果以上方法都不起作用，请在 GitHub Issues 中报告：
1. 您的发行版和版本
2. 桌面环境（GNOME、KDE、XFCE 等）
3. 运行 `RUST_LOG=debug` 后的日志输出
4. 是否使用了 Wayland 或 X11

## 技术细节

AppImage 空白窗口通常由以下原因引起：

1. **WebView 沙箱问题** - WebKit 的沙箱机制可能与 AppImage 的沙箱冲突
2. **GPU 加速问题** - 硬件加速可能与某些图形驱动不兼容
3. **Wayland 兼容性** - WebKit 在 Wayland 下可能有问题
4. **库版本不匹配** - AppImage 打包的库与系统库冲突

建议优先使用发行版的原生包格式（DEB/RPM）以获得最佳兼容性。
