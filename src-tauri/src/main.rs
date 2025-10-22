// Tauri Rust后端 - 替代Express服务器
// 这是真正的原生应用后端，不是JavaScript

#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::process::Command;
use std::path::PathBuf;
use serde::{Deserialize, Serialize};
use tauri::Manager;

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct ChafaOptions {
    format: Option<String>,
    colors: Option<String>,
    size: Option<String>,
    scale: Option<String>,
    symbols: Option<String>,
    fill: Option<String>,
    dither: Option<String>,
    dither_intensity: Option<String>,
    bg: Option<String>,
    fg: Option<String>,
    fg_only: Option<bool>,
    invert: Option<bool>,
    stretch: Option<bool>,
    preprocess: Option<bool>,
    work: Option<String>,
    color_space: Option<String>,
    color_extractor: Option<String>,
}

#[derive(Debug, Serialize)]
struct ChafaResult {
    success: bool,
    output: Option<String>,
    error: Option<String>,
}

/// 查找 chafa 可执行文件路径
fn find_chafa() -> Option<PathBuf> {
    // 首先尝试 PATH 中的 chafa
    if which::which("chafa").is_ok() {
        return Some(PathBuf::from("chafa"));
    }
    
    // macOS Homebrew 常见路径
    #[cfg(target_os = "macos")]
    {
        let homebrew_paths = vec![
            "/opt/homebrew/bin/chafa",      // Apple Silicon
            "/usr/local/bin/chafa",          // Intel Mac
            "/opt/local/bin/chafa",          // MacPorts
        ];
        
        for path in homebrew_paths {
            let path_buf = PathBuf::from(path);
            if path_buf.exists() {
                println!("Found chafa at: {}", path);
                return Some(path_buf);
            }
        }
    }
    
    // Linux 常见路径
    #[cfg(target_os = "linux")]
    {
        let linux_paths = vec![
            "/usr/bin/chafa",
            "/usr/local/bin/chafa",
        ];
        
        for path in linux_paths {
            let path_buf = PathBuf::from(path);
            if path_buf.exists() {
                return Some(path_buf);
            }
        }
    }
    
    None
}

/// 检查chafa是否安装
#[tauri::command]
fn check_chafa() -> Result<String, String> {
    println!("Checking chafa installation...");
    
    let chafa_path = find_chafa().ok_or_else(|| {
        "Chafa not found. Please install chafa:\n\nmacOS: brew install chafa\nLinux: sudo apt install chafa (or sudo dnf install chafa)\nWindows: Download from https://hpjansson.org/chafa/download/".to_string()
    })?;
    
    println!("Using chafa at: {:?}", chafa_path);
    
    match Command::new(&chafa_path).arg("--version").output() {
        Ok(output) => {
            if output.status.success() {
                let version = String::from_utf8_lossy(&output.stdout).trim().to_string();
                println!("Chafa found: {}", version);
                Ok(version)
            } else {
                let error = "Chafa command failed".to_string();
                eprintln!("{}", error);
                Err(error)
            }
        }
        Err(e) => {
            let error = format!("Chafa not found: {}", e);
            eprintln!("{}", error);
            Err(error)
        }
    }
}

/// 转换图片为ANSI艺术
#[tauri::command]
fn convert_image(image_path: String, options: ChafaOptions) -> Result<String, String> {
    println!("Converting image: {}", image_path);
    
    let chafa_path = find_chafa().ok_or_else(|| {
        "Chafa not found. Please install chafa first.".to_string()
    })?;
    
    let mut cmd = Command::new(&chafa_path);
    
    // 构建命令参数
    if let Some(format) = options.format {
        if format != "symbols" {
            cmd.arg("-f").arg(format);
        }
    }
    
    if let Some(colors) = options.colors {
        cmd.arg("-c").arg(colors);
    }
    
    if let Some(size) = options.size {
        cmd.arg("-s").arg(size);
    }
    
    if let Some(scale) = options.scale {
        cmd.arg("--scale").arg(scale);
    }
    
    if let Some(symbols) = options.symbols {
        cmd.arg("--symbols").arg(symbols);
    }
    
    if let Some(fill) = options.fill {
        cmd.arg("--fill").arg(fill);
    }
    
    if let Some(dither) = options.dither {
        if dither != "none" {
            cmd.arg("--dither").arg(dither);
        }
    }
    
    if let Some(intensity) = options.dither_intensity {
        if intensity != "1.0" {
            cmd.arg("--dither-intensity").arg(intensity);
        }
    }
    
    if let Some(bg) = options.bg {
        if !bg.is_empty() {
            cmd.arg("--bg").arg(bg);
        }
    }
    
    if let Some(fg) = options.fg {
        if !fg.is_empty() {
            cmd.arg("--fg").arg(fg);
        }
    }
    
    if let Some(true) = options.fg_only {
        cmd.arg("--fg-only");
    }
    
    if let Some(true) = options.invert {
        cmd.arg("--invert");
    }
    
    if let Some(true) = options.stretch {
        cmd.arg("--stretch");
    }
    
    if let Some(preprocess) = options.preprocess {
        cmd.arg("-p").arg(if preprocess { "on" } else { "off" });
    }
    
    if let Some(work) = options.work {
        cmd.arg("-w").arg(work);
    }
    
    if let Some(color_space) = options.color_space {
        cmd.arg("--color-space").arg(color_space);
    }
    
    if let Some(color_extractor) = options.color_extractor {
        cmd.arg("--color-extractor").arg(color_extractor);
    }
    
    // 添加图片路径
    cmd.arg(&image_path);
    
    println!("Executing: chafa {:?}", cmd.get_args().collect::<Vec<_>>());
    
    // 执行命令
    match cmd.output() {
        Ok(output) => {
            if output.status.success() {
                let result = String::from_utf8_lossy(&output.stdout).to_string();
                println!("Conversion successful, output length: {}", result.len());
                Ok(result)
            } else {
                let error = String::from_utf8_lossy(&output.stderr).to_string();
                eprintln!("Chafa error: {}", error);
                Err(if error.is_empty() {
                    "Chafa conversion failed".to_string()
                } else {
                    error
                })
            }
        }
        Err(e) => {
            let error = format!("Failed to execute chafa: {}", e);
            eprintln!("{}", error);
            Err(error)
        }
    }
}

/// 获取系统信息
#[tauri::command]
fn get_system_info() -> String {
    format!(
        "OS: {}, Arch: {}",
        std::env::consts::OS,
        std::env::consts::ARCH
    )
}

fn main() {
    // 设置环境变量以禁用硬件加速 - 修复AppImage空白问题
    #[cfg(target_os = "linux")]
    {
        std::env::set_var("WEBKIT_DISABLE_COMPOSITING_MODE", "1");
        std::env::set_var("WEBKIT_DISABLE_DMABUF_RENDERER", "1");
        std::env::set_var("GDK_BACKEND", "x11");
        println!("🔧 Disabled hardware acceleration for better compatibility");
    }
    
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .plugin(tauri_plugin_fs::init())
        .setup(|app| {
            // 检查chafa是否可用
            match find_chafa() {
                Some(path) => {
                    match Command::new(&path).arg("--version").output() {
                        Ok(output) if output.status.success() => {
                            let version = String::from_utf8_lossy(&output.stdout);
                            println!("✅ Chafa found at: {:?}", path);
                            println!("   Version: {}", version.trim());
                        }
                        _ => {
                            eprintln!("⚠️  Warning: Chafa found but failed to get version.");
                        }
                    }
                }
                None => {
                    eprintln!("⚠️  Warning: Chafa not found in common locations.");
                    eprintln!("   Please install chafa to use this application:");
                    #[cfg(target_os = "macos")]
                    eprintln!("   macOS: brew install chafa");
                    #[cfg(target_os = "linux")]
                    eprintln!("   Linux: sudo apt install chafa (or sudo dnf install chafa)");
                    #[cfg(target_os = "windows")]
                    eprintln!("   Windows: Download from https://hpjansson.org/chafa/download/");
                }
            }
            
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            check_chafa,
            convert_image,
            get_system_info
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
