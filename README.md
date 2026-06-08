# WARP 中文脚本

<p align="center">
  <img src="https://img.shields.io/badge/语言-简体中文-red?style=flat-square" alt="Language">
  <img src="https://img.shields.io/github/v/release/lei33440/warp-sh-cn?style=flat-square" alt="Version">
  <img src="https://img.shields.io/github/stars/lei33440/warp-sh-cn?style=flat-square" alt="Stars">
</p>

一个纯中文界面的 WARP 一键部署脚本，默认使用中文界面，支持多种系统架构。

>💡 本脚本基于 [fscarmen/warp-sh](https://github.com/fscarmen/warp-sh) 修改，默认使用中文界面。

## 功能特性

-🇨🇳 **纯中文界面** - 默认使用中文显示
- 🚀 **一键安装** - 只需一条命令即可安装
- 📊 **多协议支持** - 支持 IPv4、IPv6、双栈模式
- 🔄 **WARP 开关** - 自动判断当前状态
- 🛡️ **安全卸载** - 干净的卸载流程
- 📦 **多系统支持** - 支持 Debian、Ubuntu、CentOS、Alpine 等

## 支持的系统

| 系统 |架构 | 状态 |
|------|------|------|
| Debian 9+ | x86_64, aarch64 | ✅ 支持 |
| Ubuntu 16.04+ | x86_64, aarch64 | ✅ 支持 |
| CentOS 7+ | x86_64, aarch64 | ✅ 支持 |
| Alpine | x86_64, aarch64 | ✅ 支持 |
| Arch Linux | x86_64, aarch64 | ✅ 支持 |
| Fedora | x86_64 | ✅ 支持 |

## 快速开始

### 一键安装

```bash
# 安装 WARP 双栈
wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh d

# 安装 WARP IPv4
wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh 4

# 安装 WARP IPv6
wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh 6
```

### 交互式菜单

```bash
wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh
```

## 选项说明

| 选项 | 说明 |
|------|------|
| `h` | 显示帮助信息 |
| `4` | 安装 WARP IPv4 |
| `6` | 安装 WARP IPv6 |
| `d` | 安装 WARP 双栈 (IPv4+IPv6) |
| `o` | WARP 开关 (自动判断当前状态) |
| `u` | 卸载 WARP |
| `n` | 断网时刷 WARP 网络 |
| `b` | 升级内核、开启 BBR 及 DD |
| `p` | 刷 Warp+ 流量 |
| `c` | 安装 WARP Linux Client (Socks5 代理模式) |
| `l` | 安装 WARP Linux Client (WARP 模式) |
| `r` | WARP Linux Client 开关 |
| `v` | 同步脚本至最新版本 |
| `i` | 更换 WARP IP |
| `w` | 安装 WireProxy |
| `y` | WireProxy 开关 |
| `k` | 切换 WireGuard 内核 |
| `g` | 切换全局/非全局模式 |
| `s` | 切换优先级 warp IPv4/IPv6/默认 |
| 其他 | 显示交互式菜单 |

## 使用示例

### 安装 WARP IPv4

```bash
bash menu.sh 4
```

### 安装 WARP 双栈

```bash
bash menu.sh d
```

### 开关 WARP

```bash
bash menu.sh o
```

### 卸载 WARP

```bash
bash menu.sh u
```

### 显示帮助

```bash
bash menu.sh h
```

## 界面预览

```
╔══════════════════════════════════════════════════════╗
║           WARP 中文脚本 v2.0.0          ║
║           默认使用中文界面 ║
╚══════════════════════════════════════════════════════╝

当前状态: WARP 已关闭

请选择操作:

  [1] 安装 WARP IPv4
  [2] 安装 WARP IPv6
  [3] 安装 WARP 双栈
  [4] WARP 开关
  [5] 卸载 WARP
  [6] 刷 Warp+ 流量
  [7] 更换 WARP IP
  [8] 升级内核/BBR/DD
  [9] 安装 WireProxy
  [10] WARP+ License

输入数字选择，或输入选项直接执行（如: 4, d, o）
输入 q 退出

请输入选择:
```

## 常见问题

### Q:脚本需要 root 权限吗？

A: 是的，脚本需要 root 权限运行。请使用 `sudo -i` 切换到 root 用户后再运行。

### Q: 支持哪些架构？

A: 支持 x86_64 (amd64)、aarch64 (arm64) 和 s390x 架构。

### Q: 如何查看 WARP 状态？

A: 运行 `systemctl status wg-quick@warp` 或运行 `bash menu.sh o` 自动判断。

### Q: 如何完全卸载 WARP？

A: 运行 `bash menu.sh u` 即可完全卸载。

## 更新日志

### v2.0.0 (2026-06-08)
- 🎉 首发版本
- 🇨🇳 纯中文界面
- ✅ 默认使用中文模式
- ✅ 支持 WARP IPv4/IPv6/双栈安装
- ✅ 支持 WARP 开关控制
- ✅ 支持卸载功能

## 相关项目

- [fscarmen/warp-sh](https://github.com/fscarmen/warp-sh) - 原版 WARP 脚本
- [fscarmen/warp](https://gitlab.com/fscarmen/warp) - WARP 脚本主仓库
- [Xboard](https://github.com/cedar2025/Xboard) - 功能强大的代理面板
- [Xboard-Node](https://github.com/cedar2025/Xboard-Node) - Xboard 节点后端

## 许可证

本项目基于 MPL-2.0 许可证开源。

## 联系方式

- GitHub: https://github.com/lei33440
- 项目反馈: https://github.com/lei33440/warp-sh-cn/issues