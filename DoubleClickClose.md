# DoubleClickClose

一个基于 AutoHotkey v2 与 Windows UI Automation (UIA) 开发的 Chrome 标签页增强工具。

该工具为 Google Chrome 增加了 **双击标签页关闭(Tab Double Click to Close)** 功能，并尽可能保持与 Microsoft Edge 相近的交互体验。

---

## 功能

- 双击标签页关闭当前标签页
- 基于 Windows UI Automation 判断点击目标，避免误触
- 保留 Chrome 原生的标签页操作逻辑
- 当仅剩最后一个标签页时，不关闭浏览器窗口，而是在当前标签页打开 `chrome://newtab/`
- 响应速度快，对日常浏览影响极小

---

## 环境要求

开发环境：

- AutoHotkey v2
- Descolada/UIA-v2

发布版本（EXE）无需安装 AutoHotkey，可直接运行。

---

## 使用方法

### EXE 版本

直接运行：

```
DoubleClickClose.exe
```

建议将程序加入 Windows 开机启动目录，实现自动运行。

---

### AHK 脚本版本

安装 AutoHotkey v2 后运行：

```
DoubleClickCloseV2.ahk
```

---

## 实现原理

程序通过 Windows UI Automation 获取鼠标所在控件，仅当双击目标为 Chrome 标签页 (`TabItem`) 时才执行关闭操作。

普通标签页：

```
双击
    ↓
Ctrl + W
```

最后一个标签页：

```
双击
    ↓
chrome://newtab/
```

从而避免浏览器窗口被关闭。

---

## 已知限制

- 当前仅支持 Google Chrome。
- 依赖 Chrome 当前 UI Automation 结构，未来 Chrome 更新可能需要适配。
- 若标签栏 UI 发生较大变化，需重新调试 UIA 元素。

---

## 开源协议

本项目仅供学习与交流使用。

如需修改或二次开发，欢迎基于本项目继续完善。