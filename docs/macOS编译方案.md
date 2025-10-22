# 🍎 macOS 版本编译方案

## 📅 创建时间
2025-10-22 09:16

---

## ⚠️ macOS 交叉编译的挑战

从 Linux 交叉编译到 macOS 比 Windows 复杂得多：

### 主要障碍

1. **需要 macOS SDK**
   - Apple 不允许在非 Mac 设备上使用 macOS SDK
   - SDK 大小 ~1GB+
   - 法律灰色地带

2. **需要专门的工具链**
   - osxcross（非官方）
   - 配置复杂

3. **Tauri 支持限制**
   - Tauri 官方推荐在 macOS 上构建 macOS 应用
   - 交叉编译支持有限

4. **代码签名和公证**
   - macOS 应用需要签名
   - 需要 Apple Developer 账号
   - 需要在 macOS 上执行

---

## 🎯 推荐方案

### 方案1: 使用 GitHub Actions ⭐⭐⭐⭐⭐

**推荐指数**: ⭐⭐⭐⭐⭐ **强烈推荐**

**优点**:
- ✅ 完全免费（公开仓库）
- ✅ 官方 macOS 环境
- ✅ 自动化构建
- ✅ 可以签名和公证
- ✅ 支持多架构（Intel + Apple Silicon）

**缺点**:
- 需要 GitHub 仓库
- 需要推送代码

**适用场景**:
- 开源项目
- 想要 CI/CD
- 没有 Mac 硬件

**实现**: 见下方 GitHub Actions 配置

---

### 方案2: 租用 macOS 云服务器 ⭐⭐⭐⭐

**推荐指数**: ⭐⭐⭐⭐

**服务商**:
- MacStadium
- MacinCloud
- AWS Mac instances

**优点**:
- ✅ 真实的 macOS 环境
- ✅ 可以长期使用
- ✅ 适合频繁构建

**缺点**:
- 💰 需要付费（$20-100/月）
- 需要配置环境

**适用场景**:
- 商业项目
- 频繁构建
- 需要完全控制

---

### 方案3: 借用朋友的 Mac ⭐⭐⭐

**推荐指数**: ⭐⭐⭐

**优点**:
- ✅ 免费
- ✅ 真实环境

**缺点**:
- 需要物理访问
- 不适合自动化

**适用场景**:
- 一次性构建
- 有 Mac 朋友

---

### 方案4: osxcross 交叉编译 ⭐⭐

**推荐指数**: ⭐⭐ **不推荐**

**优点**:
- 可以在 Linux 上完成
- 不需要 Mac 硬件

**缺点**:
- ❌ 法律灰色地带（SDK）
- ❌ 配置极其复杂
- ❌ Tauri 支持有限
- ❌ 无法签名和公证
- ❌ 容易失败

**不推荐原因**:
- 配置成本远高于收益
- 构建产物可能无法在现代 macOS 上运行
- Apple 经常更新系统，导致兼容性问题

---

## 🚀 推荐方案：GitHub Actions

这是**最佳解决方案**，免费且专业！

### 步骤1: 创建 GitHub Actions 工作流

创建 `.github/workflows/build-macos.yml`:

```yaml
name: Build macOS

on:
  push:
    branches: [ main ]
    tags:
      - 'v*'
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  build-macos:
    strategy:
      matrix:
        platform: [macos-13, macos-14]  # macos-13=Intel, macos-14=Apple Silicon
        
    runs-on: ${{ matrix.platform }}
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable

      - name: Install Chafa (macOS)
        run: brew install chafa

      - name: Install dependencies
        run: npm install

      - name: Build application
        run: npm run tauri:build

      - name: Upload DMG
        uses: actions/upload-artifact@v4
        with:
          name: macos-${{ matrix.platform }}-dmg
          path: src-tauri/target/release/bundle/dmg/*.dmg

      - name: Upload App
        uses: actions/upload-artifact@v4
        with:
          name: macos-${{ matrix.platform }}-app
          path: src-tauri/target/release/bundle/macos/*.app
```

### 步骤2: 推送到 GitHub

```bash
# 初始化 git（如果还没有）
git init
git add .
git commit -m "feat: Add macOS build workflow"

# 添加远程仓库
git remote add origin https://github.com/yourusername/chafa-gui.git

# 推送
git push -u origin main
```

### 步骤3: 触发构建

**方式1: 推送代码**
```bash
git push
```

**方式2: 创建 tag**
```bash
git tag v1.0.0
git push --tags
```

**方式3: 手动触发**
- 访问 GitHub 仓库
- 点击 "Actions" 标签
- 选择 "Build macOS" 工作流
- 点击 "Run workflow"

### 步骤4: 下载构建产物

1. 访问 GitHub Actions 页面
2. 选择完成的工作流运行
3. 在 "Artifacts" 部分下载：
   - `macos-13-dmg` - Intel 版本 DMG
   - `macos-14-dmg` - Apple Silicon 版本 DMG

---

## 📦 macOS 构建产物

### Intel (x86_64)

```
src-tauri/target/release/bundle/macos/
└── Chafa GUI.app

src-tauri/target/release/bundle/dmg/
└── Chafa GUI_1.0.0_x64.dmg
```

### Apple Silicon (aarch64)

```
src-tauri/target/release/bundle/macos/
└── Chafa GUI.app

src-tauri/target/release/bundle/dmg/
└── Chafa GUI_1.0.0_aarch64.dmg
```

---

## 🍎 在 Mac 上本地构建

如果你有 Mac 电脑，可以直接构建：

### 安装依赖

```bash
# 安装 Homebrew（如果没有）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 Chafa
brew install chafa

# 安装 Node.js
brew install node

# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### 构建应用

```bash
# 克隆代码
git clone <your-repo>
cd chafa-gui

# 安装依赖
npm install

# 构建
npm run tauri:build

# 查看产物
ls -lh src-tauri/target/release/bundle/dmg/
ls -lh src-tauri/target/release/bundle/macos/
```

### 构建时间

- MacBook Pro (M1): ~3-5 分钟
- MacBook Pro (Intel): ~5-10 分钟

---

## 🔐 代码签名（可选但推荐）

### 为什么需要签名？

- ✅ 避免 "来自不受信任的开发者" 警告
- ✅ 允许分发给其他用户
- ✅ 支持 Gatekeeper

### 签名要求

1. **Apple Developer 账号**
   - 个人: $99/年
   - 组织: $99/年

2. **开发者证书**
   - Developer ID Application Certificate

### 签名步骤

```bash
# 1. 创建证书（在 Mac 上）
# 访问: https://developer.apple.com/account/resources/certificates/list

# 2. 下载并安装证书到钥匙串

# 3. 配置 Tauri
# 编辑 src-tauri/tauri.conf.json
{
  "bundle": {
    "macOS": {
      "signingIdentity": "Developer ID Application: Your Name (TEAM_ID)"
    }
  }
}

# 4. 构建（会自动签名）
npm run tauri:build
```

### GitHub Actions 中签名

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

- name: Build with signing
  env:
    APPLE_SIGNING_IDENTITY: ${{ secrets.APPLE_SIGNING_IDENTITY }}
  run: npm run tauri:build
```

---

## 📊 macOS vs 其他平台

| 特性 | macOS Intel | macOS ARM | Linux | Windows |
|------|-------------|-----------|-------|---------|
| **构建方式** | Mac/GitHub | Mac/GitHub | 原生 | 交叉编译 |
| **需要硬件** | Mac | Mac | 否 | 否 |
| **云构建** | ✅ GitHub | ✅ GitHub | ❌ | ❌ |
| **签名要求** | 推荐 | 推荐 | 否 | 否 |
| **分发** | DMG | DMG | RPM/DEB | ZIP/MSI |

---

## 💰 成本分析

### GitHub Actions (推荐)

- **开源项目**: 免费
- **私有项目**: 2000分钟/月免费
- macOS 构建: 10x 倍率（1分钟 = 10分钟额度）
- 单次构建: ~5分钟实际 = 50分钟额度
- 免费额度可以构建: ~40次/月

### macOS 云服务器

- **MacStadium**: $79/月起
- **MacinCloud**: $30/月起
- **AWS Mac**: $1.10/小时（~$800/月）

### 购买 Mac Mini

- **Mac Mini M2**: $599
- **Mac Mini M2 Pro**: $1,299
- 一次性投资，适合频繁构建

---

## 🎯 最佳实践

### 对于开源项目

```
使用 GitHub Actions
  ├── 完全免费
  ├── 自动化
  └── 支持多架构
```

### 对于商业项目

```
有 Mac 硬件？
  ├── Yes → 本地构建
  └── No → GitHub Actions 或 云服务器
```

### 对于个人项目

```
发布频率？
  ├── 低频 (<1次/月) → GitHub Actions
  ├── 中频 (1-10次/月) → GitHub Actions 或 借用 Mac
  └── 高频 (>10次/月) → 考虑购买 Mac Mini
```

---

## 🚫 不推荐的方案

### ❌ osxcross 交叉编译

虽然技术上可行，但：
- 配置极其复杂（需要数小时）
- 法律风险（SDK 授权）
- Tauri 支持有限
- 无法签名
- 经常失败

**结论**: 不值得投入时间

### ❌ 虚拟机方案

- macOS 许可证不允许在非 Apple 硬件上虚拟化
- 性能差
- 不稳定

---

## 📖 完整 GitHub Actions 示例

创建 `.github/workflows/build-all-platforms.yml`:

```yaml
name: Build All Platforms

on:
  push:
    tags:
      - 'v*'

jobs:
  build-linux:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y libgtk-3-dev libwebkit2gtk-4.1-dev \
            libjavascriptcoregtk-4.1-dev libsoup-3.0-dev chafa
      - run: npm install
      - run: npm run tauri:build
      - uses: actions/upload-artifact@v4
        with:
          name: linux-x64
          path: |
            src-tauri/target/release/bundle/deb/*.deb
            src-tauri/target/release/bundle/rpm/*.rpm

  build-windows:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Setup Windows cross-compile
        run: |
          sudo apt update
          sudo apt install -y gcc-mingw-w64-x86-64
          rustup target add x86_64-pc-windows-gnu
      - run: npm install
      - run: npm run build
      - run: |
          cd src-tauri
          cargo build --release --target x86_64-pc-windows-gnu
      - uses: actions/upload-artifact@v4
        with:
          name: windows-x64
          path: src-tauri/target/x86_64-pc-windows-gnu/release/chafa-gui.exe

  build-macos:
    strategy:
      matrix:
        include:
          - os: macos-13
            target: x86_64-apple-darwin
            arch: x64
          - os: macos-14
            target: aarch64-apple-darwin
            arch: aarch64
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          targets: ${{ matrix.target }}
      - name: Install Chafa
        run: brew install chafa
      - run: npm install
      - run: npm run tauri:build -- --target ${{ matrix.target }}
      - uses: actions/upload-artifact@v4
        with:
          name: macos-${{ matrix.arch }}
          path: src-tauri/target/${{ matrix.target }}/release/bundle/dmg/*.dmg

  create-release:
    needs: [build-linux, build-windows, build-macos]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/download-artifact@v4
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            linux-x64/*
            windows-x64/*
            macos-x64/*
            macos-aarch64/*
```

---

## 🎉 总结

### ✅ 推荐方案

**最佳选择**: GitHub Actions
- 免费（开源项目）
- 自动化
- 支持所有平台
- 专业且可靠

### 📊 对比

| 方案 | 成本 | 难度 | 推荐度 |
|------|------|------|--------|
| **GitHub Actions** | 免费 | ⭐ | ⭐⭐⭐⭐⭐ |
| **云服务器** | $30+/月 | ⭐⭐ | ⭐⭐⭐⭐ |
| **购买Mac** | $599+ | ⭐⭐ | ⭐⭐⭐ |
| **osxcross** | 免费 | ⭐⭐⭐⭐⭐ | ⭐ |

---

**对于 macOS 构建，强烈推荐使用 GitHub Actions！** 🚀
