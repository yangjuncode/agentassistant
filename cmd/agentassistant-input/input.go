//go:build !windows

package main

import (
	"fmt"
	"os/exec"
	"runtime"
	"strings"
	"time"

	"github.com/go-vgo/robotgo"
)

// 以下变量将命令查找/执行抽象为可替换的函数，便于测试。
var (
	findExecutable = exec.LookPath
	runExecutable  = func(path string, args ...string) error {
		return exec.Command(path, args...).Run()
	}
	executableOutput = func(path string, args ...string) ([]byte, error) {
		return exec.Command(path, args...).Output()
	}
)

// linuxTerminalWindowClasses 收集常见的 Linux 终端窗口 WM_CLASS 名称，
// 这些终端在粘贴时需要使用 ctrl+shift+v 而不是 ctrl+v。
var linuxTerminalWindowClasses = map[string]struct{}{
	"alacritty": {}, "blackbox": {}, "contour": {}, "cool-retro-term": {},
	"cosmic-term": {}, "deepin-terminal": {}, "dolphin": {}, "eterm": {},
	"foot": {}, "ghostty": {}, "gnome-console": {}, "gnome-terminal": {},
	"gnome-terminal-server": {}, "guake": {}, "hyper": {}, "kitty": {},
	"kgx": {}, "konsole": {}, "lxterminal": {}, "mate-terminal": {},
	"ptyxis": {}, "qterminal": {}, "rio": {}, "roxterm": {}, "sakura": {},
	"st": {}, "tabby": {}, "terminator": {}, "terminology": {}, "tilix": {},
	"urxvt": {}, "warp": {}, "wezterm": {}, "xfce4-terminal": {},
	"xterm": {}, "yakuake": {},
}

// linuxTerminalWindowClassIDs 收集以反向域名形式表示的终端窗口 WM_CLASS，
// 例如 Ghostty 为 "com.mitchellh.ghostty"。
var linuxTerminalWindowClassIDs = map[string]struct{}{
	"com.mitchellh.ghostty":    {},
	"com.raggesilver.blackbox": {},
	"com.system76.cosmic-term": {},
	"dev.warp.warp":            {},
	"org.gnome.console":        {},
	"org.gnome.ptyxis":         {},
	"org.kde.konsole":          {},
	"org.wezfurlong.wezterm":   {},
}

// inputText 将文本输入到当前激活窗口。在非 Windows 平台上通过剪贴板粘贴实现：
// 先保存原剪贴板内容，写入待输入文本，发送粘贴快捷键，最后恢复剪贴板。
func inputText(text string) error {
	previous, readErr := robotgo.ReadAll()
	if err := robotgo.WriteAll(text); err != nil {
		return fmt.Errorf("写入剪贴板: %w", err)
	}
	restore := func() {
		if readErr == nil {
			if err := robotgo.WriteAll(previous); err != nil {
				// 输入已经成功，恢复剪贴板失败不应造成重复输入。
				return
			}
		}
	}

	time.Sleep(40 * time.Millisecond)
	if err := sendPasteShortcut(); err != nil {
		restore()
		return err
	}
	time.Sleep(180 * time.Millisecond)
	restore()
	return nil
}

// sendPasteShortcut 发送粘贴快捷键。在 Linux 上优先使用 xdotool，
// 并根据当前激活窗口是否为终端选择 ctrl+shift+v 或 ctrl+v；
// 在 macOS 上使用 command+v。
func sendPasteShortcut() error {
	if runtime.GOOS == "linux" {
		if path, err := findExecutable("xdotool"); err == nil {
			shortcut := linuxPasteShortcut(path)
			if err := runExecutable(path, "key", "--clearmodifiers", shortcut); err != nil {
				return fmt.Errorf("xdotool 粘贴: %w", err)
			}
			return nil
		}
		if err := robotgo.KeyTap("v", "control"); err != nil {
			return fmt.Errorf("发送粘贴快捷键: %w", err)
		}
		return nil
	}
	modifier := "control"
	if runtime.GOOS == "darwin" {
		modifier = "command"
	}
	if err := robotgo.KeyTap("v", modifier); err != nil {
		return fmt.Errorf("发送粘贴快捷键: %w", err)
	}
	return nil
}

// linuxPasteShortcut 通过 xdotool 查询当前激活窗口的 WM_CLASS，
// 判断是否为终端窗口，从而返回对应的粘贴快捷键。
func linuxPasteShortcut(xdotoolPath string) string {
	output, err := executableOutput(xdotoolPath, "getactivewindow", "getwindowclassname")
	if err != nil {
		return "ctrl+v"
	}
	if isLinuxTerminalWindowClass(string(output)) {
		return "ctrl+shift+v"
	}
	return "ctrl+v"
}

// isLinuxTerminalWindowClass 判断 WM_CLASS 是否属于已知的终端窗口。
func isLinuxTerminalWindowClass(value string) bool {
	windowClass := strings.ToLower(strings.TrimSpace(value))
	if _, ok := linuxTerminalWindowClassIDs[windowClass]; ok {
		return true
	}
	if separator := strings.LastIndexByte(windowClass, '.'); separator >= 0 {
		windowClass = windowClass[separator+1:]
	}
	_, ok := linuxTerminalWindowClasses[windowClass]
	return ok
}
