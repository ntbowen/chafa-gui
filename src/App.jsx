import React, { useState, useEffect, useRef } from 'react';
import { 
  Upload, Settings, Copy, Download, Image as ImageIcon, 
  CheckCircle, AlertCircle, Loader, Palette, Grid3x3,
  Sliders, Eye, FileImage
} from 'lucide-react';
import { useTranslation } from 'react-i18next';
import AnsiRenderer from './components/AnsiRenderer';
import LanguageSwitcher from './components/LanguageSwitcher';
// Tauri API v2
import { invoke } from '@tauri-apps/api/core';
import { open, save } from '@tauri-apps/plugin-dialog';
import { readFile, writeTextFile } from '@tauri-apps/plugin-fs';

function App() {
  const { t } = useTranslation();
  const [imagePath, setImagePath] = useState('');
  const [imagePreview, setImagePreview] = useState('');
  const [imageFile, setImageFile] = useState(null);
  const [ansiOutput, setAnsiOutput] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [chafaVersion, setChafaVersion] = useState('');
  const [autoConvert, setAutoConvert] = useState(true);
  
  // Chafa 转换参数配置
  const [options, setOptions] = useState({
    // 输出格式: symbols(字符), sixels(Sixel图形), kitty(Kitty协议), iterm(iTerm2协议)
    format: 'symbols',
    
    // 颜色模式: none(单色), 2/8/16/240/256(对应色数), full(24位真彩色)
    colors: '256',
    
    // 输出尺寸: 格式为 "宽x高"，如 "80x24" 表示80列24行
    size: '80x24',
    
    // 缩放倍数: 数字(如4.0)或"max"(自动适配最大尺寸)
    scale: '4.0',
    
    // 符号集: all(全部), ascii(仅ASCII), block(方块), braille(盲文), half(半块), solid(实心块), space(空格)
    symbols: 'all',
    
    // 填充方式: none(无), block(方块), stipple(点彩), braille(盲文)
    fill: 'none',
    
    // 抖动算法: none(无), ordered(有序抖动), diffusion(误差扩散), noise(噪声)
    dither: 'none',
    
    // 抖动强度: 0.0-无限，1.0为默认强度
    ditherIntensity: '1.0',
    
    // 背景色: 十六进制颜色值(如#000000)或空字符串
    bg: '',
    
    // 前景色: 十六进制颜色值(如#ffffff)或空字符串
    fg: '',
    
    // 仅使用前景色: true表示只用前景色绘制，不使用背景色
    fgOnly: false,
    
    // 反转颜色: true表示反转前景色和背景色
    invert: false,
    
    // 拉伸适配: true表示忽略宽高比，拉伸图片以填满输出区域
    stretch: false,
    
    // 预处理: true表示启用图像预处理以获得更好的输出质量
    preprocess: true,
    
    // 处理质量级别: 1(快速)-9(最佳质量)，数字越大质量越好但速度越慢
    work: '5',
    
    // 色彩空间: rgb(RGB色彩空间，快速), din99d(DIN99d色彩空间，更准确的感知颜色)
    colorSpace: 'rgb',
    
    // 颜色提取器: average(平均值), median(中位数)
    colorExtractor: 'average'
  });

  useEffect(() => {
    checkChafa();
  }, []);

  useEffect(() => {
    if (imageFile && autoConvert) {
      convertImage();
    }
  }, [imageFile, options, autoConvert]);

  const checkChafa = async () => {
    try {
      const version = await invoke('check_chafa');
      setChafaVersion(version);
    } catch (err) {
      setError('未找到 Chafa。请先安装 Chafa。');
      console.error('Chafa check failed:', err);
    }
  };

  const handleFileSelect = async () => {
    try {
      const selected = await open({
        multiple: false,
        filters: [{
          name: 'Image',
          extensions: ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'webp', 'svg', 'tiff', 'ico']
        }]
      });
      
      if (selected && typeof selected === 'string') {
        await loadFile(selected);
      }
    } catch (err) {
      console.error('Failed to select file:', err);
      setError('文件选择失败');
    }
  };

  const handleDrop = (e) => {
    e.preventDefault();
    // Tauri不支持拖放，显示提示
    setError('请点击选择图片');
  };

  const handleDragOver = (e) => {
    e.preventDefault();
  };

  const loadFile = async (filePath) => {
    try {
      // 读取文件用于预览
      const contents = await readFile(filePath);
      const blob = new Blob([contents]);
      const url = URL.createObjectURL(blob);
      
      setImagePreview(url);
      setImagePath(filePath);
      setImageFile(filePath); // 存储文件路径而不是File对象
      setError('');
    } catch (err) {
      console.error('Failed to load file:', err);
      setError('文件加载失败');
    }
  };

  const convertImage = async () => {
    if (!imageFile) return;
    
    setLoading(true);
    setError('');
    setSuccess('');
    
    try {
      // 调用Tauri后端的convert_image命令
      const output = await invoke('convert_image', {
        imagePath: imageFile, // imageFile现在是文件路径字符串
        options: {
          format: options.format,
          colors: options.colors,
          size: options.size,
          scale: options.scale,
          symbols: options.symbols,
          fill: options.fill,
          dither: options.dither,
          ditherIntensity: options.ditherIntensity,
          bg: options.bg,
          fg: options.fg,
          fgOnly: options.fgOnly,
          invert: options.invert,
          stretch: options.stretch,
          preprocess: options.preprocess,
          work: options.work,
          colorSpace: options.colorSpace,
          colorExtractor: options.colorExtractor,
        }
      });
      
      console.log('转换成功，输出长度:', output.length);
      setAnsiOutput(output);
      setSuccess('转换成功！');
      setTimeout(() => setSuccess(''), 3000);
    } catch (err) {
      console.error('转换错误:', err);
      setError(String(err) || '转换失败');
    } finally {
      setLoading(false);
    }
  };

  const copyToClipboard = () => {
    navigator.clipboard.writeText(ansiOutput);
    setSuccess('已复制到剪贴板！');
    setTimeout(() => setSuccess(''), 2000);
  };

  const saveToFile = async () => {
    try {
      // 使用Tauri的保存对话框，让用户选择保存位置和文件名
      const filePath = await save({
        defaultPath: 'ansi-output.txt',
        filters: [{
          name: 'Text Files',
          extensions: ['txt', 'ansi']
        }]
      });
      
      if (filePath) {
        // 保存文件
        await writeTextFile(filePath, ansiOutput);
        setSuccess(`文件已保存到: ${filePath}`);
        setTimeout(() => setSuccess(''), 3000);
      }
    } catch (err) {
      console.error('Failed to save file:', err);
      setError('保存文件失败');
      setTimeout(() => setError(''), 3000);
    }
  };

  const updateOption = (key, value) => {
    setOptions(prev => ({ ...prev, [key]: value }));
  };

  return (
    <div className="flex h-screen bg-gradient-to-br from-gray-900 via-gray-900 to-gray-800 text-gray-100">
      {/* Left Panel - Controls */}
      <div className="w-96 bg-gray-800/95 backdrop-blur-sm border-r border-gray-700/50 overflow-y-auto shadow-2xl">
        <div className="p-6">
          {/* Header */}
          <div className="mb-6 pb-6 border-b border-gray-700/50">
            <div className="flex items-center justify-between gap-3 mb-3">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-gradient-to-br from-blue-500 to-blue-600 rounded-lg shadow-lg">
                  <ImageIcon className="w-7 h-7 text-white" />
                </div>
                <div>
                  <h1 className="text-2xl font-bold bg-gradient-to-r from-blue-400 to-cyan-400 bg-clip-text text-transparent">
                    {t('app.title')}
                  </h1>
                  <p className="text-xs text-gray-400">{t('app.description')}</p>
                </div>
              </div>
              <LanguageSwitcher />
            </div>
            {chafaVersion && (
              <div className="flex items-center gap-2 mt-3 px-3 py-2 bg-gray-700/30 rounded-lg border border-gray-600/30">
                <CheckCircle className="w-3 h-3 text-green-400" />
                <p className="text-xs text-gray-400">{chafaVersion.split('\n')[0]}</p>
              </div>
            )}
          </div>

          {/* File Upload */}
          <div className="mb-6">
            <label className="block text-sm font-medium mb-2 flex items-center gap-2">
              <Upload className="w-4 h-4" />
              上传图片
            </label>
            <div
              onClick={handleFileSelect}
              onDrop={handleDrop}
              onDragOver={handleDragOver}
              className="group border-2 border-dashed border-gray-600 rounded-xl p-8 text-center cursor-pointer hover:border-blue-500 hover:bg-blue-500/5 transition-all duration-300 relative overflow-hidden"
            >
              <div className="absolute inset-0 bg-gradient-to-r from-blue-500/0 via-blue-500/5 to-blue-500/0 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
              <div className="relative z-10">
                <div className="inline-flex p-3 bg-gray-700/50 rounded-full mb-3 group-hover:scale-110 transition-transform duration-300">
                  <FileImage className="w-8 h-8 text-gray-400 group-hover:text-blue-400 transition-colors" />
                </div>
                <p className="text-sm text-gray-300 font-medium mb-1">点击选择图片</p>
                <p className="text-xs text-gray-500">支持: JPG, PNG, GIF, WebP, SVG 等</p>
              </div>
            </div>
          </div>

          {/* Auto Convert Toggle */}
          <div className="mb-6">
            <label className="flex items-start gap-2 cursor-pointer">
              <input
                type="checkbox"
                checked={autoConvert}
                onChange={(e) => setAutoConvert(e.target.checked)}
                className="mt-0.5"
              />
              <div className="flex-1">
                <span className="text-sm font-medium">自动转换</span>
                <p className="text-xs text-gray-500 mt-0.5">
                  参数变化时自动重新转换图片。关闭后需手动点击转换按钮
                </p>
              </div>
            </label>
          </div>

          {/* Options */}
          <div className="space-y-6">
            {/* Format */}
            <div>
              <label className="block text-sm font-medium mb-2 flex items-center gap-2">
                <Grid3x3 className="w-4 h-4" />
                输出格式
              </label>
              <select
                value={options.format}
                onChange={(e) => updateOption('format', e.target.value)}
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
              >
                <option value="symbols">符号字符（字符艺术）</option>
                <option value="sixels">Sixels</option>
                <option value="kitty">Kitty</option>
                <option value="iterm">iTerm2</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                选择输出类型。symbols使用文字符号，其他为终端图形协议
              </p>
            </div>

            {/* Colors */}
            <div>
              <label className="block text-sm font-medium mb-2 flex items-center gap-2">
                <Palette className="w-4 h-4" />
                颜色模式
              </label>
              <select
                value={options.colors}
                onChange={(e) => updateOption('colors', e.target.value)}
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
              >
                <option value="none">无（单色）</option>
                <option value="2">2色</option>
                <option value="8">8色</option>
                <option value="16">16色</option>
                <option value="240">240色</option>
                <option value="256">256色</option>
                <option value="full">全彩色（24位）</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                颜色越多效果越好，但输出文件也越大。全彩色可显示1600万色
              </p>
            </div>

            {/* Size */}
            <div>
              <label className="block text-sm font-medium mb-2">
                尺寸（列 x 行）
              </label>
              <input
                type="text"
                value={options.size}
                onChange={(e) => updateOption('size', e.target.value)}
                placeholder="80x24"
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all hover:bg-gray-700/70 placeholder-gray-500"
              />
              <p className="text-xs text-gray-500 mt-1">
                控制输出的列数和行数。格式: 宽x高。常用: 80x24, 120x40, 160x60
              </p>
            </div>

            {/* Scale */}
            <div>
              <label className="block text-sm font-medium mb-2">
                缩放
              </label>
              <input
                type="text"
                value={options.scale}
                onChange={(e) => updateOption('scale', e.target.value)}
                placeholder="4.0 or max"
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all hover:bg-gray-700/70 placeholder-gray-500"
              />
              <p className="text-xs text-gray-500 mt-1">
                图片缩放倍数。"max"自动适配最大尺寸，数字越大图像越细致
              </p>
            </div>

            {/* Symbols (only for symbols format) */}
            {options.format === 'symbols' && (
              <>
                <div>
                  <label className="block text-sm font-medium mb-2">
                    符号集
                  </label>
                  <select
                    value={options.symbols}
                    onChange={(e) => updateOption('symbols', e.target.value)}
                    className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
                  >
                    <option value="all">全部符号</option>
                    <option value="ascii">仅ASCII</option>
                    <option value="block">方块元素</option>
                    <option value="braille">盲文</option>
                    <option value="half">半块</option>
                    <option value="solid">实心块</option>
                    <option value="space">空格</option>
                  </select>
                  <p className="text-xs text-gray-500 mt-1">
                    选择用于绘制的字符集。全部符号效果最好，ASCII兼容性最好
                  </p>
                </div>

                <div>
                  <label className="block text-sm font-medium mb-2">
                    填充字符
                  </label>
                  <select
                    value={options.fill}
                    onChange={(e) => updateOption('fill', e.target.value)}
                    className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
                  >
                    <option value="none">无</option>
                    <option value="block">方块</option>
                    <option value="stipple">点彩</option>
                    <option value="braille">盲文</option>
                  </select>
                  <p className="text-xs text-gray-500 mt-1">
                    用特定字符填充空白区域。无：不填充；其他：添加纹理效果
                  </p>
                </div>
              </>
            )}

            {/* Dither */}
            <div>
              <label className="block text-sm font-medium mb-2 flex items-center gap-2">
                <Sliders className="w-4 h-4" />
                抖动
              </label>
              <select
                value={options.dither}
                onChange={(e) => updateOption('dither', e.target.value)}
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
              >
                <option value="none">无</option>
                <option value="ordered">有序</option>
                <option value="diffusion">扩散</option>
                <option value="noise">噪声</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                抖动算法可改善颜色过渡。扩散效果最好，但较慢
              </p>
            </div>

            {/* Work Level */}
            <div>
              <label className="block text-sm font-medium mb-2">
                质量级别 (1-9)
              </label>
              <input
                type="range"
                min="1"
                max="9"
                value={options.work}
                onChange={(e) => updateOption('work', e.target.value)}
                className="w-full"
              />
              <div className="flex justify-between text-xs text-gray-500">
                <span>快速</span>
                <span className="text-gray-300">{options.work}</span>
                <span>最佳</span>
              </div>
              <p className="text-xs text-gray-500 mt-1">
                控制处理精度。数字越大质量越好，但转换速度越慢
              </p>
            </div>

            {/* Color Space */}
            <div>
              <label className="block text-sm font-medium mb-2">
                色彩空间
              </label>
              <select
                value={options.colorSpace}
                onChange={(e) => updateOption('colorSpace', e.target.value)}
                className="w-full bg-gray-700/50 border border-gray-600 rounded-lg px-3 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/50 focus:border-blue-500 transition-all cursor-pointer hover:bg-gray-700/70"
              >
                <option value="rgb">RGB（更快）</option>
                <option value="din99d">DIN99d（更准确）</option>
              </select>
              <p className="text-xs text-gray-500 mt-1">
                颜色计算方式。RGB速度快，DIN99d颜色感知更符合人眼
              </p>
            </div>

            {/* Additional Options */}
            <div className="space-y-3">
              <div className="text-sm font-medium mb-2">额外选项</div>
              
              <label className="flex items-start gap-2 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={options.stretch}
                  onChange={(e) => updateOption('stretch', e.target.checked)}
                  className="mt-0.5"
                />
                <div className="flex-1">
                  <span className="text-sm">拉伸适配</span>
                  <p className="text-xs text-gray-500 mt-0.5">忽略宽高比，拉伸图片以填满输出区域</p>
                </div>
              </label>
              
              <label className="flex items-start gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={options.invert}
                  onChange={(e) => updateOption('invert', e.target.checked)}
                  className="mt-0.5"
                />
                <div className="flex-1">
                  <span className="text-sm">反转颜色</span>
                  <p className="text-xs text-gray-500 mt-0.5">交换前景色和背景色，适用于深色背景</p>
                </div>
              </label>
              
              <label className="flex items-start gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={options.fgOnly}
                  onChange={(e) => updateOption('fgOnly', e.target.checked)}
                  className="mt-0.5"
                />
                <div className="flex-1">
                  <span className="text-sm">仅前景色</span>
                  <p className="text-xs text-gray-500 mt-0.5">不设置背景色，使用透明背景</p>
                </div>
              </label>
              
              <label className="flex items-start gap-2 cursor-pointer">
                <input
                  type="checkbox"
                  checked={options.preprocess}
                  onChange={(e) => updateOption('preprocess', e.target.checked)}
                  className="mt-0.5"
                />
                <div className="flex-1">
                  <span className="text-sm">预处理</span>
                  <p className="text-xs text-gray-500 mt-0.5">启用图像预处理以获得更好的输出质量</p>
                </div>
              </label>
            </div>

            {/* Convert Button */}
            {!autoConvert && (
              <button
                onClick={convertImage}
                disabled={!imagePath || loading}
                className="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 disabled:from-gray-600 disabled:to-gray-700 disabled:cursor-not-allowed text-white font-medium py-3 px-4 rounded-xl flex items-center justify-center gap-2 transition-all duration-300 shadow-lg hover:shadow-blue-500/50 transform hover:scale-[1.02] disabled:transform-none"
              >
                {loading ? (
                  <>
                    <Loader className="w-5 h-5 animate-spin" />
                    转换中...
                  </>
                ) : (
                  <>
                    <Settings className="w-5 h-5" />
                    转换图片
                  </>
                )}
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Right Panel - Preview */}
      <div className="flex-1 flex flex-col bg-gradient-to-br from-gray-900 to-gray-800">
        {/* Top Bar */}
        <div className="bg-gray-800/80 backdrop-blur-sm border-b border-gray-700/50 px-6 py-4 shadow-lg">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <h2 className="text-lg font-semibold flex items-center gap-2">
                <Eye className="w-5 h-5" />
                预览
              </h2>
              {loading && (
                <span className="text-sm text-blue-400 flex items-center gap-2">
                  <Loader className="w-4 h-4 animate-spin" />
                  转换中...
                </span>
              )}
            </div>
            
            {ansiOutput && (
              <div className="flex gap-2">
                <button
                  onClick={copyToClipboard}
                  className="bg-gray-700/50 hover:bg-gray-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 text-sm transition-all hover:scale-105 shadow-md"
                >
                  <Copy className="w-4 h-4" />
                  复制
                </button>
                <button
                  onClick={saveToFile}
                  className="bg-gray-700/50 hover:bg-gray-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 text-sm transition-all hover:scale-105 shadow-md"
                >
                  <Download className="w-4 h-4" />
                  保存
                </button>
              </div>
            )}
          </div>

          {/* Status Messages */}
          {error && (
            <div className="mt-3 bg-red-500/10 border border-red-500/50 text-red-400 px-4 py-3 rounded-xl flex items-center gap-2 text-sm shadow-lg animate-[fadeIn_0.3s_ease-in-out] backdrop-blur-sm">
              <AlertCircle className="w-5 h-5 flex-shrink-0" />
              <span className="flex-1">{error}</span>
            </div>
          )}
          {success && (
            <div className="mt-3 bg-green-500/10 border border-green-500/50 text-green-400 px-4 py-3 rounded-xl flex items-center gap-2 text-sm shadow-lg animate-[fadeIn_0.3s_ease-in-out] backdrop-blur-sm">
              <CheckCircle className="w-5 h-5 flex-shrink-0" />
              <span className="flex-1">{success}</span>
            </div>
          )}
        </div>

        {/* Content Area */}
        <div className="flex-1 overflow-auto p-6">
          {!imagePath ? (
            <div className="h-full flex items-center justify-center text-gray-500">
              <div className="text-center animate-[fadeIn_0.5s_ease-in-out]">
                <div className="inline-flex p-6 bg-gray-800/50 rounded-full mb-4">
                  <ImageIcon className="w-16 h-16 opacity-50" />
                </div>
                <p className="text-lg font-medium mb-2">未选择图片</p>
                <p className="text-sm text-gray-600">上传图片开始使用</p>
              </div>
            </div>
          ) : (
            <div className="space-y-8 animate-[fadeIn_0.5s_ease-in-out]">
              {/* Original Image Preview */}
              <div>
                <h3 className="text-sm font-medium text-gray-300 mb-3 flex items-center gap-2">
                  <div className="w-1 h-4 bg-blue-500 rounded-full"></div>
                  原始图片
                </h3>
                <div className="bg-gray-800/50 backdrop-blur-sm rounded-xl p-4 inline-block border border-gray-700/50 shadow-xl">
                  <img src={imagePreview} alt="Preview" className="max-w-md max-h-64 rounded-lg shadow-lg" />
                </div>
              </div>

              {/* ANSI Output */}
              {ansiOutput && (
                <div className="animate-[slideIn_0.5s_ease-in-out]">
                  <h3 className="text-sm font-medium text-gray-300 mb-3 flex items-center gap-2">
                    <div className="w-1 h-4 bg-green-500 rounded-full"></div>
                    ANSI 输出
                  </h3>
                  <AnsiRenderer content={ansiOutput} />
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default App;
