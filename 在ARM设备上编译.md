# 🚀 在ARM设备上直接编译

## 推荐方案：在ARM设备上构建

交叉编译Tauri应用比较复杂，需要ARM版本的所有系统库。
最简单的方法是**在ARM设备上直接编译**。

---

## 📋 步骤

### 1. 传输源码到ARM设备

```bash
# 在x86_64机器上打包源码
tar czf chafa-gui-source.tar.gz \
  src/ src-tauri/ package.json package-lock.json \
  vite.config.js tailwind.config.js postcss.config.js index.html \
  build-appimage.sh README.md

# 传输到ARM设备
scp chafa-gui-source.tar.gz user@arm-device:~/
```

### 2. 在ARM设备上安装依赖

```bash
# SSH到ARM设备
ssh user@arm-device

# 解压源码
cd ~
tar xzf chafa-gui-source.tar.gz
cd chafa-gui

# 安装系统依赖 (Raspberry Pi OS/Debian)
sudo apt update
sudo apt install -y \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    libgtk-3-dev \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    chafa

# 或 Fedora ARM
sudo dnf install -y \
    curl \
    gcc \
    gcc-c++ \
    make \
    pkg-config \
    openssl-devel \
    gtk3-devel \
    webkit2gtk4.1-devel \
    chafa

# 安装Node.js (如果没有)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# 安装Rust (如果没有)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### 3. 构建应用

```bash
# 安装npm依赖
npm install

# 构建 (大约10-20分钟)
npm run tauri:build

# 或手动构建AppImage
./build-appimage.sh
```

### 4. 查看构建产物

```bash
# RPM (如果在Fedora ARM上)
ls -lh src-tauri/target/release/bundle/rpm/

# DEB (如果在Debian/Ubuntu ARM上)
ls -lh src-tauri/target/release/bundle/deb/

# AppImage
ls -lh *.AppImage

# 二进制
ls -lh src-tauri/target/release/chafa-gui
```

---

## ⏱️ 预计时间

| 设备 | 编译时间 |
|------|----------|
| Raspberry Pi 4 (4GB) | ~15-20分钟 |
| Raspberry Pi 5 | ~10-15分钟 |
| ARM服务器 | ~5-10分钟 |

---

## 💡 优化建议

### 减少内存使用

如果设备内存较小（<2GB），修改 `src-tauri/Cargo.toml`:

```toml
[profile.release]
codegen-units = 1  # 减少并行编译
```

### 使用交换空间

```bash
# 创建2GB交换文件
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

---

## ✅ 优势

- ✅ 不需要交叉编译工具链
- ✅ 不需要ARM版本的开发库
- ✅ 构建产物保证兼容
- ✅ 可以直接测试运行
- ✅ 过程简单可靠

---

## 🔄 传输回x86机器（可选）

```bash
# 在ARM设备上
scp *.AppImage user@x86-machine:~/

# 或RPM/DEB包
scp src-tauri/target/release/bundle/rpm/*.rpm user@x86-machine:~/
```
