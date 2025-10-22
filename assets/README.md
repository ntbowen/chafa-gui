# 应用图标

请在此目录放置应用图标文件：

## 所需图标

### Linux
- **文件名**: `icon.png`
- **尺寸**: 512x512 像素
- **格式**: PNG
- **用途**: AppImage 和 Deb 包图标

### Windows
- **文件名**: `icon.ico`
- **尺寸**: 包含 16x16, 32x32, 48x48, 256x256
- **格式**: ICO
- **用途**: Windows 应用程序图标

### macOS
- **文件名**: `icon.icns`
- **格式**: ICNS
- **用途**: macOS 应用程序图标

## 创建图标工具

### 从 PNG 创建图标

**Windows ICO**
```bash
# 使用 ImageMagick
convert icon.png -define icon:auto-resize=256,128,96,64,48,32,16 icon.ico
```

**macOS ICNS**
```bash
# 使用 png2icns
png2icns icon.icns icon.png
```

### 在线工具
- [ICO Convert](https://www.icoconverter.com/)
- [CloudConvert](https://cloudconvert.com/)

## 临时占位符

如果暂时没有图标，构建工具会使用默认图标。
建议尽快添加自定义图标以提升应用专业度。
