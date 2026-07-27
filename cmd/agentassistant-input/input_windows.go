//go:build windows

package main

import (
	"fmt"
	"syscall"
	"unicode/utf16"
	"unsafe"

	"golang.org/x/sys/windows"
)

const (
	windowsInputKeyboard   = 1
	windowsKeyEventKeyUp   = 0x0002
	windowsKeyEventUnicode = 0x0004
	windowsVKReturn        = 0x0D
	windowsVKTab           = 0x09
)

var (
	textInputUser32 = windows.NewLazySystemDLL("user32.dll")
	procSendInput   = textInputUser32.NewProc("SendInput")
)

type windowsKeyboardInput struct {
	VirtualKey uint16
	ScanCode   uint16
	Flags      uint32
	Time       uint32
	ExtraInfo  uintptr
}

// windowsInput 包含 Windows INPUT 结构中的联合体。
// 联合体中最大的成员是 MOUSEINPUT（64 位 Windows 上为 32 字节），
// 键盘结构占用联合体的前 24 字节，因此需要 Reserved 字段补齐。
type windowsInput struct {
	Type     uint32
	Padding  uint32
	Keyboard windowsKeyboardInput
	Reserved [8]byte
}

// inputText 在 Windows 上通过 Win32 SendInput 以 Unicode 键盘事件
// 直接输入文本，不依赖剪贴板。换行符映射为回车键，制表符映射为 Tab 键。
func inputText(text string) error {
	inputs := windowsTextInputs(text)
	if len(inputs) == 0 {
		return nil
	}
	const maxInputsPerCall = 256
	for len(inputs) > 0 {
		count := len(inputs)
		if count > maxInputsPerCall {
			count = maxInputsPerCall
		}
		batch := inputs[:count]
		sent, _, callErr := procSendInput.Call(
			uintptr(len(batch)),
			uintptr(unsafe.Pointer(&batch[0])),
			unsafe.Sizeof(windowsInput{}),
		)
		if int(sent) != len(batch) {
			if callErr == nil || callErr == syscall.Errno(0) {
				callErr = fmt.Errorf("SendInput 可能被 Windows UIPI 权限隔离阻止")
			}
			return fmt.Errorf("Win32 输入文本只发送了 %d/%d 个事件: %w", sent, len(batch), callErr)
		}
		inputs = inputs[count:]
	}
	return nil
}

// windowsTextInputs 将文本转换为 Windows INPUT 键盘事件序列。
func windowsTextInputs(text string) []windowsInput {
	runes := []rune(text)
	inputs := make([]windowsInput, 0, len(runes)*2)
	for index, current := range runes {
		switch current {
		case '\r':
			if index+1 < len(runes) && runes[index+1] == '\n' {
				continue
			}
			inputs = appendWindowsVirtualKey(inputs, windowsVKReturn)
		case '\n':
			inputs = appendWindowsVirtualKey(inputs, windowsVKReturn)
		case '\t':
			inputs = appendWindowsVirtualKey(inputs, windowsVKTab)
		default:
			for _, codeUnit := range utf16.Encode([]rune{current}) {
				inputs = appendWindowsUnicode(inputs, codeUnit)
			}
		}
	}
	return inputs
}

// appendWindowsUnicode 追加一个 Unicode 字符的按下与抬起事件。
func appendWindowsUnicode(inputs []windowsInput, codeUnit uint16) []windowsInput {
	return append(inputs,
		windowsInput{
			Type:     windowsInputKeyboard,
			Keyboard: windowsKeyboardInput{ScanCode: codeUnit, Flags: windowsKeyEventUnicode},
		},
		windowsInput{
			Type: windowsInputKeyboard,
			Keyboard: windowsKeyboardInput{
				ScanCode: codeUnit,
				Flags:    windowsKeyEventUnicode | windowsKeyEventKeyUp,
			},
		},
	)
}

// appendWindowsVirtualKey 追加一个虚拟按键的按下与抬起事件。
func appendWindowsVirtualKey(inputs []windowsInput, virtualKey uint16) []windowsInput {
	return append(inputs,
		windowsInput{
			Type:     windowsInputKeyboard,
			Keyboard: windowsKeyboardInput{VirtualKey: virtualKey},
		},
		windowsInput{
			Type:     windowsInputKeyboard,
			Keyboard: windowsKeyboardInput{VirtualKey: virtualKey, Flags: windowsKeyEventKeyUp},
		},
	)
}
