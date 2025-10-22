# 🔄 CI/CD 工作流说明

## 📋 概述

项目使用单一的 GitHub Actions 工作流：**Build and Release**

---

## 🚀 工作流：Build and Release

**文件位置**: `.github/workflows/build-all-platforms.yml`

### 功能

一次构建所有平台：
- ✅ Linux x86-64（RPM + DEB + AppImage）
- ✅ Windows x86-64（ZIP）
- ✅ macOS Intel（DMG）
- ✅ macOS Apple Silicon（DMG）

---

## 🎯 触发条件

### 1. 推送到主分支（main/master）

```bash
git push origin main
```

**行为**:
- ✅ 构建所有平台
- ✅ 生成构建产物（Artifacts）
- ❌ 不创建 Release

**用途**: 日常开发，验证构建是否正常

---

### 2. 推送版本标签（v*）

```bash
git tag v1.0.0
git push origin v1.0.0
```

**行为**:
- ✅ 构建所有平台
- ✅ 生成构建产物
- ✅ **自动创建 GitHub Release**
- ✅ 上传所有文件
- ✅ 生成发布说明

**用途**: 正式发布版本

---

### 3. Pull Request

**行为**:
- ✅ 构建所有平台
- ✅ 测试构建是否通过
- ❌ 不创建 Release

**用途**: 代码审查时验证构建

---

### 4. 手动触发

在 GitHub Actions 页面点击 "Run workflow"

**行为**:
- ✅ 构建所有平台
- ✅ 生成构建产物
- ❌ 不创建 Release

**用途**: 按需构建测试

---

## 📦 构建产物

### 所有触发方式都会生成 Artifacts

访问: `https://github.com/ntbowen/chafa-gui/actions`

**Artifacts 列表**:
- `linux-deb` - Debian/Ubuntu 包
- `linux-rpm` - Fedora/RHEL 包
- `linux-appimage` - Universal Linux 包
- `windows-x64` - Windows ZIP 包
- `macos-x64-dmg` - Intel Mac DMG
- `macos-aarch64-dmg` - Apple Silicon DMG

**保留时间**: 90 天（GitHub 默认）

---

## 🏷️ Release 创建

### 只有推送 tag 时才创建 Release

**Release 包含**:
- ✅ 所有 6 个平台的构建文件
- ✅ 详细的安装说明
- ✅ 功能列表
- ✅ 文档链接
- ✅ 系统要求

**命名规范**:
- `Chafa GUI-1.0.0-1.x86_64.rpm`
- `chafa-gui_1.0.0_amd64.deb`
- `Chafa-GUI-1.0.0-x86_64.AppImage`
- `chafa-gui-windows-x64.zip`
- `chafa-gui-macos-intel.dmg`
- `chafa-gui-macos-apple-silicon.dmg`

---

## ⏱️ 构建时间

| 平台 | 预计时间 |
|------|---------|
| Linux | 5-8 分钟 |
| Windows | 3-5 分钟 |
| macOS Intel | 5-10 分钟 |
| macOS Apple Silicon | 5-10 分钟 |

**总计**: ~15-20 分钟（并行执行）

---

## 💰 成本

### 公开仓库
- **完全免费** ✅
- GitHub Actions 对公开仓库无限制使用

### 私有仓库
- Linux: 免费（分钟数不计费）
- macOS: $0.08/分钟
- 估计成本: ~$1.20/次发布（~15 分钟 macOS 构建）

---

## 📊 工作流结构

```
Build and Release
├── build-linux
│   ├── Install dependencies
│   ├── Build application
│   └── Upload artifacts (RPM, DEB, AppImage)
│
├── build-windows
│   ├── Setup MinGW cross-compiler
│   ├── Build Windows binary
│   └── Upload artifact (ZIP)
│
├── build-macos
│   ├── Matrix: [Intel, Apple Silicon]
│   ├── Install Chafa via Homebrew
│   ├── Build application
│   └── Upload artifacts (DMG)
│
└── create-release (only on tag push)
    ├── Download all artifacts
    ├── Organize release files
    ├── Generate release notes
    └── Create GitHub Release
```

---

## 🔧 常见场景

### 场景 1: 日常开发测试

```bash
# 提交代码
git add .
git commit -m "feat: Add new feature"
git push

# 自动触发构建，生成 Artifacts
# 访问 Actions 页面下载测试
```

### 场景 2: 发布正式版本

```bash
# 1. 更新版本号
vim package.json
vim src-tauri/Cargo.toml
vim src-tauri/tauri.conf.json

# 2. 提交更改
git add .
git commit -m "chore: Bump version to 1.0.0"
git push

# 3. 创建并推送标签
git tag v1.0.0
git push origin v1.0.0

# 4. 自动构建并创建 Release
# 访问 Releases 页面查看
```

### 场景 3: 测试特定分支

```bash
# 在 GitHub Actions 页面
# 1. 选择 "Build and Release" 工作流
# 2. 点击 "Run workflow"
# 3. 选择要构建的分支
# 4. 点击 "Run workflow" 按钮
```

### 场景 4: 重新发布

```bash
# 1. 删除旧的 Release 和 tag
git push origin --delete v1.0.0
git tag -d v1.0.0

# 2. 重新创建 tag
git tag v1.0.0
git push origin v1.0.0

# 3. 自动重新构建和发布
```

---

## 🐛 故障排除

### 构建失败

1. **检查日志**:
   - 访问 Actions 页面
   - 点击失败的工作流运行
   - 查看具体的失败步骤

2. **常见问题**:
   - 依赖安装失败: 检查系统依赖
   - 编译错误: 检查代码语法
   - 图标问题: 确保图标是 8-bit PNG
   - 权限问题: 检查 GITHUB_TOKEN 权限

### Release 未创建

**原因**: 只有推送 tag 时才创建 Release

**解决**:
```bash
# 确认是推送 tag，不是推送分支
git push origin v1.0.0  # ✅ 正确
git push origin main     # ❌ 不会创建 Release
```

### Artifacts 找不到

**Artifacts 保留时间**: 90 天

**下载方法**:
1. 访问 Actions 页面
2. 点击工作流运行
3. 滚动到底部的 "Artifacts" 部分
4. 点击下载

---

## 📚 相关文档

- **发布指南**: `如何发布版本.md`
- **完整总结**: `docs/最终跨平台构建总结.md`
- **macOS 构建**: `docs/使用GitHub-Actions构建macOS.md`
- **Windows 构建**: `docs/Windows版本使用指南.md`

---

## 🎉 总结

**一个工作流，全平台构建**:
- 🔄 自动化程度 100%
- 🌍 支持 5 个平台
- 📦 生成 6 种格式
- 🚀 一条命令发布
- 💰 开源项目免费

**发布就是这么简单**:
```bash
git tag v1.0.0 && git push origin v1.0.0
```

15-20 分钟后，所有平台的构建产物自动发布到 GitHub Releases！🎊
