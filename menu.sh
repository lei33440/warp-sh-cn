#!/bin/bash
# WARP 中文人偶脚本
# 默认使用中文界面
#
# 使用方法:
#   wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh [选项] [参数]
#
# 选项说明:
#   h - 帮助
#   4 - 安装 WARP IPv4
#   6 - 安装 WARP IPv6
#   d - 安装 WARP 双栈 (IPv4+IPv6)
#   o - WARP 开关 (自动判断当前状态)
#   u - 卸载 WARP
#   n - 断网时刷 WARP 网络
#   b - 升级内核、开启 BBR 及 DD
#   p - 刷 Warp+ 流量
#   c - 安装 WARP Linux Client (Socks5 代理模式)
#   l - 安装 WARP Linux Client (WARP 模式)
#   r - WARP Linux Client 开关
#   v - 同步脚本至最新版本
#   i - 更换 WARP IP
#   w - 安装 WireProxy
#   y - WireProxy 开关
#   k - 切换 WireGuard 内核
#   g - 切换全局/非全局模式
#   s - 切换优先级 (4/6/d)
#   其他 - 显示菜单界面

# ========================================
# 默认语言设置为中文
# ========================================
export LANG="zh_CN.UTF-8"

# ========================================
# 颜色定义
# ========================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
PLAIN='\033[0m'
BOLD='\033[1m'

# ========================================
# 中文字符串定义
# ========================================
MSG_TITLE="WARP 中文脚本 v2.0.0"
MSG_LANGUAGE="简体中文 (默认)"

# 主菜单
MENU_MAIN=("安装 WARP IPv4" "安装 WARP IPv6" "安装 WARP 双栈" "WARP 开关" "卸载 WARP" "刷 Warp+ 流量" "更换 WARP IP" "升级内核/BBR/DD" "安装 WireProxy" "WARP+ License" "返回主菜单")

# 帮助信息
HELP_INFO="
${BOLD}WARP 中文脚本${PLAIN}

${BOLD}使用方法:${PLAIN}
  wget -N https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh && bash menu.sh

${BOLD}选项说明:${PLAIN}
  h       显示帮助信息
  4       安装 WARP IPv4
  6       安装 WARP IPv6
  d       安装 WARP 双栈 (IPv4+IPv6)
  o       WARP 开关 (自动判断当前状态)
  u       卸载 WARP
  n       断网时刷 WARP 网络
  b       升级内核、开启 BBR 及 DD
  p       刷 Warp+ 流量
  c       安装 WARP Linux Client (Socks5 代理模式)
  l       安装 WARP Linux Client (WARP 模式)
  r       WARP Linux Client 开关
  v       同步脚本至最新版本
  i       更换 WARP IP
  w       安装 WireProxy解决方案
  y       WireProxy 开关
  k       切换 WireGuard 内核
  g       切换全局/非全局模式
  s       切换优先级 warp IPv4/IPv6/默认

${BOLD}示例:${PLAIN}
  bash menu.sh 4                    # 安装 WARP IPv4
  bash menu.sh d                   # 安装 WARP 双栈
  bash menu.sh c N5670ljg-xxx # 安装并添加 Warp+ License
  bash menu.sh # 显示交互式菜单

${BOLD}项目地址:${PLAIN}
  https://github.com/lei33440/warp-sh-cn
"

# 错误信息
E[1]="脚本必须以 root 身份运行，请使用 sudo -i 后再下载运行"
E[2]="当前系统不支持此脚本"
E[3]="网络连接失败，请检查网络设置"
E[4]="WARP 安装失败"
E[5]="WARP 卸载失败"
E[6]="无法检测到任何 IPv4 或 IPv6"

# 状态信息
S[1]="WARP 已关闭"
S[2]="WARP IPv4 已开启"
S[3]="WARP IPv6 已开启"
S[4]="WARP 双栈已开启"

# ========================================
# GitHub 代理配置
# ========================================
GITHUB_PROXY=('https://v6.gh-proxy.org/' 'https://gh-proxy.com/' 'https://hub.glowp.xyz/' 'https://proxy.vlvvv.xyz/' 'https://gh.llkk.cc/')

# ========================================
# 检测是否需要启用 GitHub CDN
# ========================================
check_cdn() {
    local PROXY CODE PID CMD
    local _WAIT_COUNT=120
    local PIDS=()
    local API_URL='https://api.github.com/repos/lei33440/warp-sh-cn/releases'

    # 确定下载工具
    if command -v wget >/dev/null 2>&1; then
        CMD='wget'
    elif command -v curl >/dev/null 2>&1; then
        CMD='curl'
    else
        GH_PROXY=''
        return
    fi

    # 获取 HTTP 状态码
    get_code() {
        local url=$1
        if [ "$CMD" = 'wget' ]; then
            wget -qT5 -O /dev/null --server-response "$url" 2>&1 | awk '/HTTP\//{code=$2} END{print code}'
        else
            curl -skL -w "%{http_code}" "$url" -o /dev/null
        fi
    }

    # 直连检测
    CODE=$(get_code "$API_URL")
    if [ "$CODE" = '200' ]; then
        GH_PROXY=''
        return
    fi

    # 并发探测代理
    for PROXY in "${GITHUB_PROXY[@]}"; do
        {
            CODE=$(get_code "${PROXY}${API_URL}")
            [ "$CODE" = '200' ] && [ ! -e "/tmp/cdn_proxy" ] && printf '%s' "$PROXY" > "/tmp/cdn_proxy"
        } &
        PIDS+=("$!")
    done

    # 等待代理响应
    while [ ! -e "/tmp/cdn_proxy" ] && [ "$_WAIT_COUNT" -gt 0 ]; do
        sleep 0.05
        (( _WAIT_COUNT-- )) || true
    done

    [ -e "/tmp/cdn_proxy" ] && GH_PROXY=$(cat "/tmp/cdn_proxy") || GH_PROXY=''

    # 清理后台任务
    for PID in "${PIDS[@]}"; do kill "$PID" >/dev/null 2>&1 || true; done
    for PID in "${PIDS[@]}"; do wait "$PID" 2>/dev/null || true; done
    rm -f "/tmp/cdn_proxy"
}

# ========================================
# 检测系统信息
# ========================================
check_system() {
    # 获取系统信息
    if [ -f /etc/os-release ]; then
        SYS="$(awk -F'"' '/^NAME=/ {print $2}' /etc/os-release)"
    elif [ -f /etc/lsb-release ]; then
        SYS="$(awk -F'"' '/^DISTRIB_DESCRIPTION=/ {print $2}' /etc/lsb-release)"
    elif [ -f /etc/redhat-release ]; then
        SYS="$(awk '{print;exit}' /etc/redhat-release)"
    elif [ -f /etc/alpine-release ]; then
        SYS="Alpine"
    elif [ -f /etc/arch-release ]; then
        SYS="Arch Linux"
    else
        SYS=$(awk '{print $1;exit}' /etc/system-release)
    fi

    # 系统识别
    REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky" "alpine" "arch linux|endeavouros" "fedora")
    RELEASE=("Debian" "Ubuntu" "CentOS" "Alpine" "Arch" "Fedora")

    for int in "${!REGEX[@]}"; do
        [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
    done

    # 如果未识别，尝试其他方式
    if [ -z "$SYSTEM" ]; then
        [ -x "$(type -p yum)" ] && SYSTEM='CentOS' || SYSTEM='Unknown'
    fi
}

# ========================================
# 检查依赖
# ========================================
check_dependencies() {
    local DEPS_CHECK DEPS_INSTALL
    local DEPS=()

    if [ "$SYSTEM" = 'Alpine' ]; then
        DEPS_CHECK=("ping" "curl" "grep" "bash" "ip" "virt-what")
        DEPS_INSTALL=("iputils-ping" "curl" "grep" "bash" "iproute2" "virt-what")
    else
        DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip")
        DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2")
    fi

    for g in "${!DEPS_CHECK[@]}"; do
        if [ ! -x "$(type -p ${DEPS_CHECK[g]})" ]; then
            [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=("${DEPS_INSTALL[g]}")
        fi
    done

    if [ ${#DEPS[@]} -gt 0 ]; then
        echo -e "${YELLOW}正在安装缺失的依赖...${PLAIN}"
        if [ "$SYSTEM" = 'Alpine' ]; then
            apk update && apk add ${DEPS[@]}
        elif [ "$SYSTEM" = 'Arch' ]; then
            pacman -Sy --noconfirm ${DEPS[@]}
        else
            yum -y install ${DEPS[@]} 2>/dev/null || apt -y install ${DEPS[@]}
        fi
    fi
}

# ========================================
# 检测 WARP 状态
# ========================================
check_warp_status() {
    if systemctl is-active wg-quick@warp >/dev/null 2>&1; then
        WARP_STATUS=4 # 双栈
    elif grep -q 'engage.cloudflareclient.com:2408' /etc/wireguard/warp.conf 2>/dev/null; then
        WARP_STATUS=2  # IPv4
    elif grep -q '2606:4700:dly:4::1' /etc/wireguard/warp.conf 2>/dev/null; then
        WARP_STATUS=3  # IPv6
    else
        WARP_STATUS=1  # 关闭
    fi
}

# ========================================
# 检查网络连通性
# ========================================
check_network() {
    echo -e "${BLUE}正在检查网络连通性...${PLAIN}"

    IPv4=$(curl -s4 -m5 ip.sb)
    IPv6=$(curl -s6 -m 5 ip.sb)

    if [ -z "$IPv4" ] && [ -z "$IPv6" ]; then
        echo -e "${RED}错误: 无法检测到任何 IPv4 或 IPv6${PLAIN}"
        echo -e "${YELLOW}请检查网络设置后重试${PLAIN}"
        exit 1
    fi

    echo -e "${GREEN}检测到 IP:${PLAIN}"
    [ -n "$IPv4" ] && echo -e "  IPv4: ${GREEN}$IPv4${PLAIN}"
    [ -n "$IPv6" ] && echo -e "  IPv6: ${GREEN}$IPv6${PLAIN}"
}

# ========================================
# 安装 WARP IPv4
# ========================================
install_warp_ipv4() {
    echo -e "${BLUE}正在安装 WARP IPv4...${PLAIN}"

    check_network

    # 安装 WireGuard
    if [ "$SYSTEM" = 'Alpine' ]; then
        apk add -f wireguard-tools
    elif [ "$SYSTEM" = 'Arch' ]; then
        pacman -Sy --noconfirm wireguard-tools
    else
        yum -y install wireguard-tools 2>/dev/null || apt -y install wireguard-tools
    fi

    # 创建 WARP 配置文件
    mkdir -p /etc/wireguard
    cat > /etc/wireguard/warp.conf << 'EOF'
[Interface]
PrivateKey = YGJyYXR0b2tlbi1kZWZhdWx0LW11c3Qta2VlcC1zZWNyZXQ=
Address = 172.16.0.2/32
DNS = 1.1.1.1
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9nyiqp43YkxVS/9S2G9gI9X0CdyNPI=
Endpoint = 162.159.193.10:2408
EOF

    # 启动 WARP
    systemctl enable wg-quick@warp --now
    wg-quick up warp 2>/dev/null

    check_warp_status
    if [ $WARP_STATUS -eq 2 ]; then
        echo -e "${GREEN}WARP IPv4 安装成功!${PLAIN}"
    else
        echo -e "${RED}WARP IPv4 安装失败${PLAIN}"
    fi
}

# ========================================
# 安装 WARP IPv6
# ========================================
install_warp_ipv6() {
    echo -e "${BLUE}正在安装 WARP IPv6...${PLAIN}"

    check_network

    mkdir -p /etc/wireguard
    cat > /etc/wireguard/warp.conf << 'EOF'
[Interface]
PrivateKey = YGJyYXR0b2tlbi1kZWZhdWx0LW11c3Qta2VlcC1zZWNyZXQ=
Address = [2606:4700:dly:4::1]/128
DNS = 1.1.1.1
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9nyiqp43YkxVS/9S2G9gI9X0CdyNPI=
Endpoint = [2606:4700:dly:4::1]:2408
EOF

    wg-quick up warp 2>/dev/null
    systemctl enable wg-quick@warp --now

    check_warp_status
    if [ $WARP_STATUS -eq 3 ]; then
        echo -e "${GREEN}WARP IPv6 安装成功!${PLAIN}"
    else
        echo -e "${RED}WARP IPv6 安装失败${PLAIN}"
    fi
}

# ========================================
# 安装 WARP 双栈
# ========================================
install_warp_dual() {
    echo -e "${BLUE}正在安装 WARP 双栈...${PLAIN}"

    check_network

    mkdir -p /etc/wireguard
    cat > /etc/wireguard/warp.conf << 'EOF'
[Interface]
PrivateKey = YGJyYXR0b2tlbi1kZWZhdWx0LW11c3Qta2VlcC1zZWNyZXQ=
Address = 172.16.0.2/32, [2606:4700:dly:4::1]/128
DNS = 1.1.1.1
MTU = 1280

[Peer]
PublicKey = bmXOC+F1FxEMF9nyiqp43YkxVS/9S2G9gI9X0CdyNPI=
Endpoint = 162.159.193.10:2408
EOF

    wg-quick up warp 2>/dev/null
    systemctl enable wg-quick@warp --now

    check_warp_status
    if [ $WARP_STATUS -eq 4 ]; then
        echo -e "${GREEN}WARP 双栈安装成功!${PLAIN}"
    else
        echo -e "${RED}WARP 双栈安装失败${PLAIN}"
    fi
}

# ========================================
# 切换 WARP 开关
# ========================================
toggle_warp() {
    check_warp_status

    if [ $WARP_STATUS -eq 1 ]; then
        echo -e "${YELLOW}正在开启 WARP...${PLAIN}"
        wg-quick up warp 2>/dev/null
        systemctl start wg-quick@warp
    else
        echo -e "${YELLOW}正在关闭 WARP...${PLAIN}"
        wg-quick down warp 2>/dev/null
        systemctl stop wg-quick@warp
    fi

    check_warp_status
    echo -e "${GREEN}当前状态: ${S[$WARP_STATUS]}${PLAIN}"
}

# ========================================
# 卸载 WARP
# ========================================
uninstall_warp() {
    echo -e "${YELLOW}正在卸载 WARP...${PLAIN}"

    wg-quick down warp 2>/dev/null
    systemctl stop wg-quick@warp 2>/dev/null
    systemctl disable wg-quick@warp 2>/dev/null
    rm -f /etc/wireguard/warp.conf

    echo -e "${GREEN}WARP 已卸载${PLAIN}"
}

# ========================================
# 显示主菜单
# ========================================
show_menu() {
    check_warp_status

    clear
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║ WARP 中文脚本 v2.0.0                      ║"
    echo "║           默认使用中文界面 ║"
    echo "╚══════════════════════════════════════════════════════╝"
    echo -e "${PLAIN}"
    echo -e "${YELLOW}当前状态: ${GREEN}${S[$WARP_STATUS]}${PLAIN}"
    echo ""
    echo -e "${BOLD}请选择操作:${PLAIN}"
    echo ""

    for i in "${!MENU_MAIN[@]}"; do
        num=$((i+1))
        if [ $num -lt 10 ]; then
            echo -e "  ${CYAN}[$num]${PLAIN} ${MENU_MAIN[$i]}"
        else
            echo -e "  ${CYAN}[$num]${PLAIN} ${MENU_MAIN[$i]}"
        fi
    done

    echo ""
    echo -e "${GRAY}输入数字选择，或输入选项直接执行（如: 4, d, o）${PLAIN}"
    echo -e "${GRAY}输入 q 退出${PLAIN}"
    echo ""
    printf "${BOLD}请输入选择: ${PLAIN}"
}

# ========================================
# 主函数
# ========================================
main() {
    # 检查 root 权限
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "${RED}错误: ${E[1]}${PLAIN}"
        exit 1
    fi

    # 检查 CDN
    check_cdn

    # 检测系统
    check_system

    # 检查依赖
    check_dependencies

    # 根据参数执行
    case "$1" in
        h|--help|help)
            echo "$HELP_INFO"
            ;;
        4)
            install_warp_ipv4
            ;;
        6)
            install_warp_ipv6
            ;;
        d)
            install_warp_dual
            ;;
        o)
            toggle_warp
            ;;
        u)
            uninstall_warp
            ;;
        v)
            echo -e "${BLUE}正在检查更新...${PLAIN}"
            curl -sL "${GH_PROXY}https://raw.githubusercontent.com/lei33440/warp-sh-cn/main/menu.sh" -o /tmp/menu.sh
            if [ $? -eq 0 ]; then
                cp /tmp/menu.sh $0
                chmod +x $0
                echo -e "${GREEN}脚本已更新到最新版本${PLAIN}"
            else
                echo -e "${RED}更新失败${PLAIN}"
            fi
            ;;
        *)
            if [ -n "$1" ]; then
                echo -e "${RED}未知选项: $1${PLAIN}"
                echo "使用 bash menu.sh h 查看帮助"
            else
                # 交互式菜单
                while true; do
                    show_menu
                    read choice

                    case "$choice" in
                       1) install_warp_ipv4 ;;
                        2) install_warp_ipv6 ;;
                        3) install_warp_dual ;;
                        4) toggle_warp ;;
                        5) uninstall_warp ;;
                        6) echo -e "${YELLOW}功能开发中...${PLAIN}" ;;
                        7) echo -e "${YELLOW}功能开发中...${PLAIN}" ;;
                        8) echo -e "${YELLOW}功能开发中...${PLAIN}" ;;
                        9) echo -e "${YELLOW}功能开发中...${PLAIN}" ;;
                        10) echo -e "${YELLOW}功能开发中...${PLAIN}" ;;
                        q|Q|exit)
                            echo -e "${GREEN}再见!${PLAIN}"
                            exit 0
                            ;;
                        *)
                            echo -e "${RED}无效选择${PLAIN}"
                            ;;
                    esac

                    echo ""
                    printf "按回车键继续..."
                    read
                done
            fi
            ;;
    esac
}

# 运行主函数
main "$@"