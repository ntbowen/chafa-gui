# 🚀 使用 GitHub Actions 构建 macOS 版本

## 📅 创建时间
2025-10-22 09:18

---

## ✅ 已完成配置

已创建两个 GitHub Actions 工作流：

1. **`.github/workflows/build-macos.yml`**
   - 专门构建 macOS 版本
   - 支持 Intel (x64) 和 Apple Silicon (aarch64)
   - 每次推送代码或手动触发

2. **`.github/workflows/build-all-platforms.yml`**
   - 构建所有平台（Linux + Windows + macOS）
   - 仅在创建 tag 时自动运行
   - 自动创建 GitHub Release

---

## 🚀 快速开始

### 步骤1: 推送到 GitHub

```bash
# 初始化 git（如果还没有）
cd /home/zag/zag/chafa-gui
git init
git add .
git commit -m "feat: Add GitHub Actions workflows for cross-platform build"

# 创建 GitHub 仓库（在网页上创建）
# 然后添加远程仓库
git remote add origin https://github.com/yourusername/chafa-gui.git

# 推送代码
git branch -M main
git push -u origin main
```

### 步骤2: 触发 macOS 构建

**方式1: 自动触发（推荐）**
```bash
# 推送代码会自动触发
git push
```

**方式2: 手动触发**
1. 访问: `https://github.com/yourusername/chafa-gui/actions`
2. 选择 "Build macOS" 工作流
3. 点击 "Run workflow" 按钮
4. 选择分支（main）
5. 点击绿色 "Run workflow" 按钮

**方式3: 创建版本标签**
```bash
# 创建版本标签
git tag v1.0.0
git push origin v1.0.0

# 这会触发 "Build All Platforms" 工作流
# 并自动创建 GitHub Release
```

### 步骤3: 等待构建完成

- 构建时间: 5-10 分钟
- 可以在 Actions 页面查看实时日志
- 两个版本会并行构建（Intel + Apple Silicon）

### 步骤4: 下载构建产物

**从 Actions 页面下载**:
1. 访问: `https://github.com/yourusername/chafa-gui/actions`
2. 点击最近完成的工作流运行
3. 滚动到底部 "Artifacts" 部分
4. 下载:
   - `macos-x64-dmg` - Intel 版本 DMG
   - `macos-aarch64-dmg` - Apple Silicon 版本 DMG

**从 Releases 下载（如果使用 tag）**:
1. 访问: `https://github.com/yourusername/chafa-gui/releases`
2. 找到最新版本
3. 下载对应的 DMG 文件

---

## 📦 构建产物

### Intel (x86_64)

```
Chafa GUI_1.0.0_x64.dmg
- 大小: ~15-20MB
- 适用于: Intel Mac (MacBook Pro/Air 2020及以前)
- 系统要求: macOS 10.15+
```

### Apple Silicon (aarch64)

```
Chafa GUI_1.0.0_aarch64.dmg
- 大小: ~15-20MB  
- 适用于: Apple Silicon Mac (M1/M2/M3)
- 系统要求: macOS 11.0+
```

---

## 🎯 工作流说明

### build-macos.yml

**触发条件**:
- 推送到 `main` 或 `master` 分支
- 创建 Pull Request
- 创建 tag（`v*`）
- 手动触发

**构建内容**:
- macOS Intel (x86_64)
- macOS Apple Silicon (aarch64)

**输出**:
- DMG 安装包
- .app 应用包

**构建时间**: ~5-10 分钟

---

### build-all-platforms.yml

**触发条件**:
- 创建 tag（`v*`）
- 手动触发

**构建内容**:
- Linux x86-64 (DEB + RPM + AppImage)
- Windows x86-64 (ZIP)
- macOS Intel (DMG)
- macOS Apple Silicon (DMG)

**自动功能**:
- 创建 GitHub Release
- 上传所有构建产物
- 生成下载链接

**构建时间**: ~15-20 分钟

---

## 💰 成本

### 开源项目（公开仓库）
- ✅ **完全免费**
- ✅ 无限制使用 macOS runners

### 私有仓库
- **免费额度**: 2000 分钟/月
- **macOS 倍率**: 10x
- **实际可用**: 200 分钟 macOS 构建时间/月
- **单次构建**: ~5 分钟实际 = 50 分钟额度
- **可构建次数**: ~40 次/月

**超额费用**:
- 每分钟 $0.08（macOS）
- 实际每分钟 $0.008（10倍率）

---

## 🔧 自定义配置

### 修改触发条件

编辑 `.github/workflows/build-macos.yml`:

```yaml
on:
  push:
    branches: [ main ]  # 修改为你的分支名
  # 禁用 PR 触发
  # pull_request:
  #   branches: [ main ]
```

### 添加代码签名

如果你有 Apple Developer 账号：

```yaml
- name: Import signing certificate
  env:
    CERTIFICATE_BASE64: ${{ secrets.MACOS_CERTIFICATE }}
    CERTIFICATE_PASSWORD: ${{ secrets.MACOS_CERTIFICATE_PWD }}
  run: |
    echo $CERTIFICATE_BASE64 | base64 --decode > certificate.p12
    security create-keychain -p actions build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p actions build.keychain
    security import certificate.p12 -k build.keychain -P $CERTIFICATE_PASSWORD -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k actions build.keychain
```

然后在 GitHub 仓库设置中添加 Secrets:
1. `MACOS_CERTIFICATE` - Base64 编码的证书
2. `MACOS_CERTIFICATE_PWD` - 证书密码

### 禁用某个架构

如果只想构建 Intel 版本：

```yaml
strategy:
  matrix:
    include:
      - os: macos-13
        target: x86_64-apple-darwin
        arch: x64
      # 注释掉 Apple Silicon
      # - os: macos-14
      #   target: aarch64-apple-darwin
      #   arch: aarch64
```

---

## 📊 构建状态徽章

添加到 README.md 中显示构建状态：

```markdown
[![Build macOS](https://github.com/yourusername/chafa-gui/actions/workflows/build-macos.yml/badge.svg)](https://github.com/yourusername/chafa-gui/actions/workflows/build-macos.yml)

[![Build All Platforms](https://github.com/yourusername/chafa-gui/actions/workflows/build-all-platforms.yml/badge.svg)](https://github.com/yourusername/chafa-gui/actions/workflows/build-all-platforms.yml)
```

---

## 🐛 故障排除

### 问题1: 构建失败 - "找不到 chafa"

**原因**: Homebrew 安装失败

**解决方案**:
```yaml
- name: Install Chafa
  run: |
    brew update
    brew install chafa || brew upgrade chafa
```

### 问题2: 构建超时

**原因**: 依赖下载慢或编译时间过长

**解决方案**: 启用缓存（已配置）
```yaml
- name: Rust cache
  uses: swatinem/rust-cache@v2
```

### 问题3: DMG 未生成

**原因**: Tauri 配置问题

**检查**: `src-tauri/tauri.conf.json`
```json
{
  "bundle": {
    "active": true,
    "targets": ["dmg"],
    "macOS": {
      "minimumSystemVersion": "10.15"
    }
  }
}
```

### 问题4: 权限错误

**解决方案**: 添加到工作流
```yaml
- name: Fix permissions
  run: |
    chmod +x src-tauri/target/release/chafa-gui
```

---

## 📖 完整发布流程

### 1. 准备发布

```bash
# 1. 更新版本号
# 编辑 package.json, src-tauri/Cargo.toml, src-tauri/tauri.conf.json

# 2. 更新 CHANGELOG
echo "## v1.0.0 - 2025-10-22" >> CHANGELOG.md
echo "- 新功能..." >> CHANGELOG.md

# 3. 提交更改
git add .
git commit -m "chore: Prepare v1.0.0 release"
git push
```

### 2. 创建版本

```bash
# 创建带注释的 tag
git tag -a v1.0.0 -m "Release version 1.0.0

Features:
- macOS Intel support
- macOS Apple Silicon support
- Cross-platform build automation

Platforms:
- Linux x86-64 (RPM, DEB, AppImage)
- Windows x86-64
- macOS x86-64 (Intel)
- macOS aarch64 (Apple Silicon)
"

# 推送 tag
git push origin v1.0.0
```

### 3. 等待自动构建

GitHub Actions 会自动：
1. 构建所有平台
2. 创建 GitHub Release
3. 上传所有文件
4. 生成下载链接

### 4. 完善 Release 说明

访问 Release 页面，编辑自动生成的 Release，添加：
- 安装说明
- 系统要求
- 已知问题
- 致谢

---

## ✅ 优势

### vs 本地构建

| 特性 | GitHub Actions | 本地构建 |
|------|----------------|----------|
| **需要 Mac** | ❌ 否 | ✅ 是 |
| **成本** | 免费 | $599+ |
| **自动化** | ✅ 完全 | ❌ 手动 |
| **多架构** | ✅ 同时 | ❌ 分别 |
| **CI/CD** | ✅ 内置 | ❌ 需配置 |

### vs 云服务器

| 特性 | GitHub Actions | 云服务器 |
|------|----------------|----------|
| **月费用** | $0 | $30-100 |
| **配置** | ✅ 简单 | ❌ 复杂 |
| **维护** | ✅ 无需 | ❌ 需要 |
| **可用性** | ✅ 高 | ❌ 依赖供应商 |

---

## 🎉 总结

### ✅ 已完成

- ✅ macOS Intel 构建配置
- ✅ macOS Apple Silicon 构建配置
- ✅ 全平台自动构建
- ✅ 自动 Release 创建
- ✅ 完整的 CI/CD 流程

### 📊 成果

**一次 `git push` 即可获得**:
- Linux RPM
- Linux DEB  
- Linux AppImage
- Windows ZIP
- macOS Intel DMG
- macOS Apple Silicon DMG

**6个平台，0台物理机！** 🚀

---

## 🚀 下一步

1. **推送代码到 GitHub**
   ```bash
   git push origin main
   ```

2. **创建第一个版本**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

3. **查看构建结果**
   - 访问 Actions 页面
   - 等待构建完成
   - 下载 DMG 文件

4. **在 Mac 上测试**
   - 下载 DMG
   - 双击安装
   - 测试所有功能

---

**使用 GitHub Actions，无需 Mac 也能构建 macOS 应用！** 🎉
