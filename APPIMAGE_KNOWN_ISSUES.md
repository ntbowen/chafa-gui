# AppImage 已知问题

## ⚠️ Wayland 兼容性问题

AppImage 版本在某些 Wayland 环境下存在已知问题，可能出现空白窗口。

### 受影响的系统
- Fedora 43 + GNOME Wayland
- 其他使用 Wayland 的现代 Linux 发行版
- 系统 WebKit 版本 >= 2.50.0

### 问题表现
- 窗口能打开，显示标题栏
- 内容区域完全空白
- 控制台显示 `Could not create default EGL display: EGL_BAD_PARAMETER`

### 根本原因
AppImage 打包了来自 Ubuntu 20.04 的旧版本 WebKit 库，与现代 Wayland 环境不兼容。特别是：
- AppImage 的 WebKit 2.36.x vs 系统的 WebKit 2.50.x
- EGL (OpenGL ES) 硬件加速在 AppImage 容器中初始化失败
- 即使禁用硬件加速，打包的 WebKit 进程路径也可能不正确

## ✅ 推荐解决方案

### 1. 使用原生包格式（强烈推荐）

#### Fedora/RHEL/CentOS
```bash
sudo dnf install ./Chafa-GUI-*.rpm
```

#### Debian/Ubuntu  
```bash
sudo apt install ./Chafa-GUI_*.deb
```

**优势**：
- 使用系统安装的 WebKit 库
- 完全兼容系统环境
- 与系统更好集成
- ✅ 已验证在 Fedora 43 + Wayland 上完美工作

### 2. AppImage 临时解决方案

如果必须使用 AppImage，请使用以下包装脚本：

```bash
#!/bin/bash
# save as: run-chafa-gui.sh

# 检测会话类型
if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    # Wayland: 尝试使用系统 WebKit
    unset LD_LIBRARY_PATH
    export WEBKIT_DISABLE_COMPOSITING_MODE=1
    export LIBGL_ALWAYS_SOFTWARE=1
    
    # 强制使用 XWayland 作为后备
    # export GDK_BACKEND=x11
else
    # X11: 禁用硬件加速
    export WEBKIT_DISABLE_COMPOSITING_MODE=1
    export GDK_BACKEND=x11
    export LIBGL_ALWAYS_SOFTWARE=1
fi

exec ./Chafa-GUI-*.AppImage "$@"
```

**使用方法**：
```bash
chmod +x run-chafa-gui.sh
./run-chafa-gui.sh
```

### 3. 从源码构建（开发者）

```bash
git clone https://github.com/ntbowen/chafa-gui.git
cd chafa-gui
npm install
npm run tauri build
```

这将使用你系统的 WebKit 库构建，完全兼容。

## 🔬 技术细节

### 为什么 RPM/DEB 能工作？

```
RPM/DEB 包:
├── 应用二进制
├── 依赖声明: webkit2gtk4.1
└── 使用系统库 → ✅ 与系统完全兼容

AppImage:
├── 应用二进制  
├── 打包的 WebKit 库 (Ubuntu 20.04, 旧版本)
├── 打包的其他依赖
└── 可能与系统冲突 → ❌ 特别是在 Wayland 下
```

### WebKit 版本对比

| 环境 | WebKit 版本 | Wayland 支持 | 状态 |
|------|------------|-------------|------|
| AppImage (Ubuntu 20.04) | 2.36.x | 有限 | ❌ |
| Fedora 43 系统 | 2.50.0 | 完整 | ✅ |
| RPM 包 | 使用系统版本 | 完整 | ✅ |

### 为什么不能简单修复？

1. **Tauri 的 AppImage 打包**
   - 使用 Ubuntu 20.04 作为构建环境
   - 必须打包 WebKit（不能假设系统有）
   - 难以支持所有发行版的 Wayland 实现

2. **Wayland 协议变化**
   - 不同发行版的 Wayland 实现差异
   - EGL/硬件加速在沙箱环境中的限制
   - 旧版本库与新协议不兼容

3. **AppImage 的设计限制**
   - 必须尽可能自包含
   - 与系统库版本可能冲突
   - 特别是复杂的图形栈（WebKit/GTK/Wayland）

## 📊 兼容性矩阵

| 发行版 | RPM/DEB | AppImage X11 | AppImage Wayland |
|--------|---------|--------------|------------------|
| Fedora 43 | ✅ 完美 | 🟡 可能可用 | ❌ 已知问题 |
| Ubuntu 24.04 | ✅ 完美 | ✅ 可用 | 🟡 可能有问题 |
| Debian 12 | ✅ 完美 | ✅ 可用 | 🟡 可能有问题 |
| Arch Linux | 🔧 AUR | ✅ 可用 | 🟡 可能有问题 |

**图例**：
- ✅ 完美：已测试，完全工作
- 🟡 可能：理论上应该工作，但未完全测试
- ❌ 问题：已知不工作或有严重问题
- 🔧 其他：需要其他安装方式

## 💡 建议

### 对于用户
1. **优先使用 RPM/DEB 包** - 最佳兼容性和性能
2. 如果必须使用 AppImage，在 X11 会话下运行
3. 报告问题时请包含系统信息（发行版、DE、X11/Wayland）

### 对于发行版打包者
考虑为你的发行版创建原生包：
- Fedora: 已提供 RPM
- Debian/Ubuntu: 已提供 DEB  
- Arch: 欢迎贡献 AUR 包
- 其他: 欢迎贡献

## 🐛 报告问题

如果遇到其他问题，请在 GitHub Issues 中报告，包含：
- 发行版和版本
- 桌面环境
- 会话类型 (`echo $XDG_SESSION_TYPE`)
- WebKit 版本 (`rpm -qa | grep webkit` 或 `dpkg -l | grep webkit`)
- 完整的错误日志

## 🔗 相关链接

- [Tauri AppImage 文档](https://tauri.app/v1/guides/building/linux/)
- [WebKit Wayland 支持](https://webkit.org/blog/)
- [AppImage 最佳实践](https://docs.appimage.org/)

---

**最后更新**: 2025-01-22  
**状态**: AppImage 在 Wayland 下的支持仍在改进中
