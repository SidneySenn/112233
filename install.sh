#!/bin/bash

# Source: https://goedge.rip/install.sh
# Install Script, 2024-08-04 | GoEdge.RIP | TG @GoEdge233
# Research only

RED="\033[31m"
GREEN="\033[32m"
BLUE="\033[34m"
YELLOW="\033[1;33m"
NC="\033[0m"

log() {
    local color_code="$1"
    local message="$2"
    echo -e "${color_code}[GoEdge.RIP] ${message}${NC}"
}

exxt() {
    local message="$1"
    echo -e "${RED}=============================================${NC}"
    echo -e "${RED}[GoEdge.RIP] ${message}${NC}"
    echo -e "${RED}[GoEdge.RIP] 如有疑问，请带着执行截图至官方反馈。${NC}"
    echo -e "${RED}=============================================${NC}"
    exit 1
}

log "$GREEN" "GoEdge Admin 一键安装脚本"
log "$BLUE" "GoEdge Admin 一键安装脚本"
log "$YELLOW" "GoEdge Admin 一键安装脚本"

check_command() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &>/dev/null; then
            exxt "请先安装 $cmd，如 apt install $cmd / yum install $cmd / dnf install $cmd"
        fi
    done
}

check_architecture() {
    local uname
    uname=$(uname -m)
    case "$uname" in
    x86_64)
        echo "amd64"
        ;;
    aarch64 | arm64)
        echo "arm64"
        ;;
    *)
        exxt "不受支持的架构: $uname"
        ;;
    esac
}

create_install_directory() {
    local base_path="$1"
    if [ ! -d "$base_path" ]; then
        mkdir -p "$base_path"
        log "$GREEN" "安装目录创建成功，默认为 $base_path"
    else
        log "$YELLOW" "检测到 $base_path 已存在，是否覆盖安装？确认之前请确保已做好备份数据库等操作。(y/N)"
        local confirm=$(get_user_input "确认覆盖安装到 $base_path? [第一次确认] (输入 y 确认): ")
        if [ "$confirm" != "y" ]; then
            exxt "安装已被手动取消"
        fi
        local confirm=$(get_user_input "真的确认覆盖安装 $base_path? [最终确认] (输入 y 确认): ")
        if [ "$confirm" != "y" ]; then
            exxt "安装已被手动取消"
        fi
        log "$YELLOW" "将覆盖安装到 $base_path，请确保已做好备份数据库等操作"
    fi
}

update_hosts_file() {
    local -n hosts=$1
    {
        for k in "${hosts[@]}"; do
            if ! grep -q "$k" /etc/hosts; then
                echo "127.0.0.1 $k" >>/etc/hosts
            fi
        done
    }
}

confirm_installation() {
    local confirm=$(get_user_input "[GoEdge.RIP] 是否确认安装 GoEdge Admin v$1? (输入 y 确认): ")
    if [ "$confirm" != "y" ]; then
        exxt "安装已被手动取消"
    fi
    log "$GREEN" "开始安装..."
}

get_user_input() {
    local prompt="$1"
    read -rp "$prompt" input
    echo "$input"
}

get_file_hash() {
    local file=$1
    sha256sum "$file" | awk '{print $1}'
}

check_hash() {
    local filename=$1
    local sha256=$2
    local check_url="https://goedge.rip/dl/check.txt?file=$filename&hash=$sha256"

    local check_ctx
    check_ctx=$(curl -s "$check_url")

    if [[ -z "$check_ctx" ]]; then
        exxt "下载 SHA256 校验文件失败，请检查网络连接。"
    fi

    if echo "$check_ctx" | grep -q "$filename $sha256"; then
        echo "y"
    else
        exxt "错误: 校验 $filename SHA256 失败，可能是网络连接问题，请重试。"
    fi
}

install_goedge_admin() {
    local base_path="$1"
    local arch="$2"
    local version="$3"

    if [[ ! -d "$base_path" ]]; then
        exxt "错误: 基础路径 '$base_path' 不存在。"
    fi

    log "$GREEN" "正在下载 GoEdge Admin v${version}..."
    log "$GREEN" "您的系统架构为 $arch"

    local url="https://goedge.rip/dl/edge/v${version}/edge-admin-linux-${arch}-plus-v${version}.zip"
    local zip_file="$base_path/edge-admin-linux-${arch}-plus-v${version}.zip"
    local filename="edge-admin-linux-${arch}-plus-v${version}.zip"

    log "$GREEN" "正在计算安装包的 SHA256 校验值，确保未被篡改。"

    if ! check_hash "$filename" "$(get_file_hash "$zip_file")"; then
        exxt "错误: 校验 $filename 失败，可能是网络连接问题，请重试。"
    fi

    if ! wget -c -O "$zip_file" "$url"; then
        exxt "错误: 下载 $url 失败。"
    fi

    log "$GREEN" "校验完毕，正在解压 GoEdge Admin v${version}..."

    if ! unzip -q -o "$zip_file" -d "$base_path"; then
        exxt "$RED" "错误: 解压 $zip_file 失败。"
    fi

    log "$GREEN" "GoEdge Admin v${version} 安装成功。"
}

# 启动 edge-admin 主程序
start_edge_admin() {
    local base_path="$1"

    chmod +x "$base_path/edge-admin/bin/edge-admin"
    if [ ! -f "$base_path/edge-admin/bin/edge-admin" ]; then
        exxt "错误: edge-admin 二进制文件不存在，可能是压缩包损坏，请重新下载。"
    fi
    chmod +x "$base_path/edge-admin/edge-api/bin/edge-api"
    if [ ! -f "$base_path/edge-admin/edge-api/bin/edge-api" ]; then
        exxt "错误: edge-api 二进制文件不存在，可能是压缩包损坏，请重新下载。"
    fi

    "$base_path/edge-admin/bin/edge-admin" stop 2&>/dev/null
    "$base_path/edge-admin/edge-api/bin/edge-api" stop 2&>/dev/null

    if ! "$base_path/edge-admin/bin/edge-admin" start; then
        exxt "错误: 启动 edge-admin 失败，请手动启动。"
    fi
    if ! "$base_path/edge-admin/edge-api/bin/edge-api" start; then
        exxt "错误: 启动 edge-api 失败，请手动启动。"
    fi

    log "$GREEN" "GoEdge Admin 启动成功"
}

# 获取IP地址
get_ip() {
    local v4_ips=()
    local v6_ips=()
    local private_v4_ips=()

    v4_ip_list=(
        "https://api.ipify.org/"
        "https://ipinfo.io/ip"
    )

    v6_ip_list=(
        "https://api6.ipify.org/"
        "http://ipv6.ip.sb"
    )

    # Public v4
    for url in "${v4_ip_list[@]}"; do
        local ip
        ip=$(curl -s "$url")
        if [ -n "$ip" ] && [[ ! ${v4_ips[*]} =~ $ip ]]; then
            v4_ips+=("$ip")
        fi
    done

    # Private v4
    while IFS= read -r ip; do
        if [[ ! ${private_v4_ips[*]} =~ $ip ]]; then
            private_v4_ips+=("$ip")
        fi
    done < <(ip -4 addr show | awk '/inet / {print $2}' | cut -d/ -f1 | grep -E '^10\.|^172\.(1[6-9]|2[0-9]|3[0-1])\.|^192\.168\.')

    # Public v6
    for url in "${v6_ip_list[@]}"; do
        local ip
        ip=$(curl -s "$url")
        if [ -n "$ip" ] && [[ ! ${v6_ips[*]} =~ $ip ]]; then
            v6_ips+=("$ip")
        fi
    done

    echo "${v4_ips[*]} ${v6_ips[*]} ${private_v4_ips[*]}"
}

# 主函数
main() {
    check_command unzip curl wget sed grep expect sha256sum

    local LATEST
    LATEST='1.3.9'
    log "$GREEN" "当前推荐安装版本: v$LATEST"

    local ARCH
    ARCH=$(check_architecture)
    log "$GREEN" "当前 CPU 架构: $ARCH"

    local GOEDGE_BASE_PATH="/usr/local/goedge"
    create_install_directory "$GOEDGE_BASE_PATH"

    local update_hosts_list=(
        "goedge.cloud"
        "goedge.cn"
    )

    local download_hosts_list=(
        "dl.goedge.cloud"
        "cn.dl.goedge.cloud"
        "global.dl.goedge.cloud"
        "dl.goedge.cn"
        "global.dl.goedge.cn"
        "cn.dl.goedge.cn"
    )

    update_hosts_file update_hosts_list
    update_hosts_file download_hosts_list

    log "$GREEN" "已屏蔽官方域名访问，降低使用风险"

    confirm_installation "$LATEST"

    install_goedge_admin "$GOEDGE_BASE_PATH" "$ARCH" "$LATEST"

    start_edge_admin "$GOEDGE_BASE_PATH"

    echo "# Command Alias by GoEdge[.]RIP | TG @goedge233" >>~/.bashrc
    echo "alias edge-admin='$GOEDGE_BASE_PATH/edge-admin/bin/edge-admin'" >>~/.bashrc
    echo "alias edge-api='$GOEDGE_BASE_PATH/edge-admin/edge-api/bin/edge-api'" >>~/.bashrc

    log "$GREEN" "安装成功！请通过浏览器访问以下链接："

    echo -e "${YELLOW}┌─────────────────────────────────────────────────────────────"
    echo -e "${YELLOW}│       安装/覆盖 v$LATEST 一键脚本 GoEdge"
    echo -e "${YELLOW}│"
    echo -e "${YELLOW}│   - 本地访问:    http://localhost:7788/"
    read -r v4_ips v6_ips private_v4_ips <<<"$(get_ip)"
    for ip in $v4_ips; do
        echo -e "${YELLOW}│   - 公网访问:    http://$ip:7788/"
    done
    for ip in $v6_ips; do
        echo -e "${YELLOW}│   - IPv6:        http://[$ip]:7788/"
    done
    for ip in $private_v4_ips; do
        echo -e "${YELLOW}│   - 内网访问:    http://$ip:7788/"
    done
    echo -e "${YELLOW}│"
    echo -e "${YELLOW}│   执行完毕，请通过浏览器访问以上地址以完成安装。"
    echo -e "${YELLOW}│"
    echo -e "${YELLOW}└─────────────────────────────────────────────────────────────${NC}"

    log "$BLUE" "edge-admin 常用命令: https://goedge.rip/docs/Admin/Commands.md.html"
    log "$GREEN" "安装完毕，GoEdge Admin v$LATEST 和附带的 edge-api 已安装至 $GOEDGE_BASE_PATH/edge-admin"
    log "$GREEN" "请手动执行 source ~/.bashrc 自动加载 edge-admin 和 edge-admin 命令"
}

main "$@"
