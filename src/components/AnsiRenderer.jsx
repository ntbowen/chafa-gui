import React, { useEffect, useRef } from 'react';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import 'xterm/css/xterm.css';

/**
 * ANSI渲染器组件
 * 使用xterm.js渲染ANSI转义序列和终端图形
 * @param {string} content - 要渲染的ANSI内容
 */
const AnsiRenderer = ({ content }) => {
  const terminalRef = useRef(null);  // 终端容器DOM引用
  const xtermRef = useRef(null);     // xterm.js实例引用
  const fitAddonRef = useRef(null);  // FitAddon插件引用

  // 初始化终端实例（仅在组件挂载时执行一次）
  useEffect(() => {
    if (!terminalRef.current) return;

    // 创建终端实例，使用默认配置以确保真彩色正常渲染
    const term = new Terminal({
      convertEol: true,              // 自动转换行尾符
      fontFamily: 'Courier New, monospace',  // 等宽字体
      fontSize: 14,                  // 字体大小
      cursorBlink: false,            // 禁用光标闪烁
      cursorStyle: 'block',          // 块状光标
      scrollback: 1000,              // 回滚缓冲区行数
      rows: 30,                      // 初始行数
      cols: 80                       // 初始列数
    });

    // 加载自动适配插件（自动调整终端大小以适应容器）
    const fitAddon = new FitAddon();
    term.loadAddon(fitAddon);

    // 将终端挂载到DOM并自动适配大小
    term.open(terminalRef.current);
    fitAddon.fit();

    // 保存实例引用供后续使用
    xtermRef.current = term;
    fitAddonRef.current = fitAddon;

    // 清理函数：组件卸载时销毁终端实例
    return () => {
      term.dispose();
    };
  }, []);

  // 当content变化时更新终端显示
  useEffect(() => {
    if (xtermRef.current && content) {
      // 清空终端显示
      xtermRef.current.clear();
      
      // 写入新的ANSI内容
      xtermRef.current.write(content);
      
      // 延迟调整大小以确保内容已渲染
      if (fitAddonRef.current) {
        setTimeout(() => fitAddonRef.current.fit(), 100);
      }
    }
  }, [content]);

  return (
    <div 
      ref={terminalRef}
      style={{
        borderRadius: '0.375rem',
        overflow: 'hidden',
        backgroundColor: '#000'
      }}
    />
  );
};

export default AnsiRenderer;
