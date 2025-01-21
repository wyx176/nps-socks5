#!/bin/bash
export LC_ALL=en_US.UTF-8

# 文件下载存储路径
SOCKS5_PATH="/opt/nps-socks5"
# GitHub仓库信息
REPO_OWNER="wyx176"
REPO_NAME="nps-socks5"

# 获取操作系统类型和架构
OS_TYPE=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# 根据不同的架构设置ARCH_NAME
case $ARCH in
    x86_64)
        ARCH_NAME="amd64"
        ;;
    i386|i686)
        ARCH_NAME="386"
        ;;
    armv7l)
        ARCH_NAME="arm"
        ;;
    aarch64)
        ARCH_NAME="arm64"
        ;;
    mips)
        ARCH_NAME="mips"
        ;;
    mips64)
        ARCH_NAME="mips64"
        ;;
    mips64le)
        ARCH_NAME="mips64le"
        ;;
    mipsle)
        ARCH_NAME="mipsle"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

if [ ! -d "$SOCKS5_PATH" ]; then
    mkdir -p $SOCKS5_PATH
fi

# 异常日志输出
function exception_log() {
    echo "$1 - 反馈群组 https://t.me/Scoks55555"
}

# 构造文件名
CLIENT_FILENAME="${OS_TYPE}_${ARCH_NAME}_client.tar.gz"
SERVER_FILENAME="${OS_TYPE}_${ARCH_NAME}_server.tar.gz"

API_URL="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/latest"

echo  "正在获取最新版本信息..."
# 获取最新的release信息
LATEST_RELEASE=$(curl -s $API_URL)

# 提取下载URL
CLIENT_DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -oP '"browser_download_url": "\K(.*?'"$CLIENT_FILENAME"'[^"]*)' | head -n 1)
SERVER_DOWNLOAD_URL=$(echo "$LATEST_RELEASE" | grep -oP '"browser_download_url": "\K(.*?'"$SERVER_FILENAME"'[^"]*)' | head -n 1)

# 检查提取结果是否为空
if [ -z "$CLIENT_DOWNLOAD_URL" ]; then
    exception_log "获取最新版本失败，一般是网络问题: $CLIENT_FILENAME"
    exit 1
fi

if [ -z "$SERVER_DOWNLOAD_URL" ]; then
    exception_log "获取最新版本失败，一般是网络问题: $SERVER_FILENAME"
    exit 1
fi

function downLoad() {
   local file_name="$1"
   local download_url="$2"
   local save_path="$3"
    if [ -z "$download_url" ]; then
        echo "Failed to find download URL for $file_name"
        exit 1
    fi

    # 显示进度条标题
    echo "正在下载: $file_name"
    # 下载文件
    curl -LJ --progress-bar -o "$save_path/$(basename $download_url)" "$download_url"
}

#安装服务端
function install_server() {
  local server_path="$SOCKS5_PATH/server"
  #判断/usr/bin/nps文件是否存在，如果存在则退出脚本停止安装
    if [ -f "/usr/bin/nps" ] || [ -d "/etc/nps" ]; then
        exception_log "服务端已安装，请先卸载再安装。"
        exit 1
    fi

    # 判断$SOCKS5_PATH是否存在，如果不存在则创建，如果存在则删除对应的服务端文件
    if [ ! -d $server_path ]; then
        mkdir -p $server_path
    else
        rm -rf "${server_path}"/*
    fi

    #下载服务端文件
    downLoad "$SERVER_FILENAME" "$SERVER_DOWNLOAD_URL" "$server_path"
    #判断文件是否下载完毕，如果没下载完毕则退出脚本
    if [ ! -f "$server_path/$SERVER_FILENAME" ]; then
        exception_log "服务端文件下载失败，请检查网络连接或重试。 $SERVER_FILENAME"
        exit 1
    fi

    # 解压服务端文件，判断解压后是否有nps文件，如果没有则退出脚本
    tar -zxf "$server_path/$SERVER_FILENAME" -C "$server_path" > /dev/null 2>&1
    if [ ! -f "$server_path/nps" ]; then
        exception_log "服务端文件解压失败，请检查文件是否损坏。 $SERVER_FILENAME"
        exit 1
        else
            echo "服务端文件下载成功。"
    fi

    #执行安装命令sudo ./nps install
    sudo "$server_path/nps" install > /dev/null 2>&1

    #检测是否包含nps
    if [ ! -f "/usr/bin/nps" ]; then
       exception_log "服务端安装失败，未检测到文件信息。"
       exit 1
    fi

   #执行nps -version命令判断是否有响应
   if nps -version >/dev/null 2>&1; then
       sudo nps start
       echo "服务端安装成功，启动中..."
   else
       exception_log "服务端安装失败，未检测到指令。"
       exit 1
   fi

   #检测是否有nps进程
   if pgrep -f "nps service" >/dev/null; then
       echo "==服务端服务器启动成功=="
       echo "默认穿透端口：8024"
       echo "默认web端口：18080"
       echo "默认web登录账号：admin"
       echo "默认web登录密码：admin"
       echo "服务端配置文件路径：/etc/nps/conf"
       exception_log "如有防火墙，请放行8024、18080端口"
   else
       exception_log "服务端启动失败。"
       exit 1
   fi
}

#卸载服务端
function uninstall_server() {
  local server_path="$SOCKS5_PATH/server"
    #判断/etc/nps文件是否存在
    if [  -f "/usr/bin/nps" ]; then
        sudo nps stop
    fi

    #判断nps进程是否存在，不存在则删除/etc/nps文件夹
    if ! pgrep -f "nps service" >/dev/null; then
       rm -rf /etc/nps
       rm -rf /usr/bin/nps
    fi

    #判断$server_path是否存在，如果存在则删除对应的服务端文件
    if [ -d $server_path ]; then
        rm -rf "$server_path"/*
    fi

    if [  -f "/usr/bin/nps" ]; then
        exception_log "服务端卸载失败。"
        exit 1
        else
            echo "服务端卸载成功。"
    fi
}

# 安装客户端
function install_client() {
    local client_path="$SOCKS5_PATH/client"
    # 判断npc进程是否存在
    if [ -f /usr/bin/npc ] || pgrep -f "npc" >/dev/null; then
        exception_log "客户端已安装，请先卸载再安装"
        exit 1
    fi

    if [ ! -d $client_path ]; then
        mkdir -p $client_path
    else
        rm -rf "${client_path}"/*
    fi
    downLoad "$CLIENT_FILENAME" "$CLIENT_DOWNLOAD_URL" "$client_path"
    if [ ! -f "$client_path/$CLIENT_FILENAME" ]; then
        exception_log "客户端文件下载失败，请检查网络连接或重试。 $CLIENT_FILENAME"
        exit 1
    fi
    tar -zxf "$client_path/$CLIENT_FILENAME" -C "$client_path" > /dev/null 2>&1
    if [ ! -f "$client_path/npc" ]; then
        exception_log "客户端文件解压失败，请检查文件是否损坏。 $CLIENT_FILENAME"
        exit 1
    else
        echo "客户端文件下载成功。"
    fi

    #请输入服务端IP
    read -p "请输入服务端IP：" server_ip
    #判断服务端IP是否为空，为空则退出脚本，不为空则判断是否为IPV4
    if [ -z "$server_ip" ]; then
        exception_log "服务端IP不能为空。"
        exit 1
    fi
    if ! [[ $server_ip =~ ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$ ]]; then
        exception_log "服务端IP格式错误: $server_ip"
        exit 1
    fi

    #请输入服务端穿透端口(默认8024)
    read -p "请输入服务端穿透端口(默认8024)：" server_port
    #判断服务端穿透端口是否为空，为空则默认8024
    if [ -z "$server_port" ]; then
        server_port="8024"
    fi

    #请输入服务端vkey
    read -p "请输入服务端vkey：" server_vkey
    #判断服务端vkey是否为空，为空则退出脚本
    if [ -z "$server_vkey" ]; then
        exception_log "服务端vkey不能为空。"
        exit 1
    fi

    #执行npc
    sudo "$client_path"/npc install -server="$server_ip:$server_port" -vkey="$server_vkey" > /dev/null 2>&1
    sudo npc start > /dev/null 2>&1
    if pgrep -f "npc" >/dev/null; then
        echo "==客户端安装启动成功=="
    else
        exception_log "客户端安装失败。"
        exit 1
    fi
}

# 卸载客户端
function uninstall_client() {
    local client_path="$SOCKS5_PATH/client"
    if ! [ -f /usr/bin/npc ]; then
        exception_log "客户端未安装。"
        exit 1
    fi
    #判断npc进程是否存在
    if pgrep -f "npc" >/dev/null; then
        sudo npc stop
    fi
    sudo npc uninstall
    #删除客户端路径下的文件
    if [ -d "$client_path" ]; then
        rm -rf "$client_path"/*
    fi
    #删除/usr/bin/npc文件
    if [ -f "/usr/bin/npc" ]; then
        rm -rf /usr/bin/npc
    fi
    echo "客户端卸载成功。"
}

# 启动服务端
function start_server() {
    #判断服务端是否安装
    if [ ! -f "/usr/bin/nps" ]; then
        exception_log "服务端未安装，请先安装服务端。"
        exit 1
    fi
    if pgrep -f "nps service" >/dev/null; then
        echo "服务端运行中，无需启动"
        exit 0
    else
        sudo nps start
    fi
    if pgrep -f "nps service" >/dev/null; then
        echo "服务端启动成功"
        exit 0
    else
        exception_log "服务端启动失败"
        exit 1
    fi
}

# 停止服务端
function stop_server() {
    #判断服务端是否安装
    if [ ! -f "/usr/bin/nps" ]; then
        exception_log "服务端未安装，请先安装服务端。"
        exit 1
    fi
    if pgrep -f "nps service" >/dev/null; then
        sudo nps stop
    else
        echo "服务端未运行，无需停止。"
        exit 0
    fi
    if pgrep -f "nps service" >/dev/null; then
        exception_log "服务端停止失败。"
        exit 1
    else
        echo "服务端停止成功。"
    fi
}

# 启动客户端
function start_client() {
    #判断客户端是否安装
    if [ ! -f "/usr/bin/npc" ]; then
        exception_log "客户端未安装，请先安装客户端。"
        exit 1
    fi
    if pgrep -f "npc" >/dev/null; then
        echo "客户端运行中，无需启动。"
        exit 0
    else
        sudo npc start
    fi
    if pgrep -f "npc" >/dev/null; then
        echo "客户端启动成功。"
        else
            exception_log "客户端启动失败。"
            exit 1
    fi
}

# 停止客户端
function stop_client() {
    #判断客户端是否安装
    if [ ! -f "/usr/bin/npc" ]; then
        exception_log "客户端未安装，请先安装客户端。"
        exit 1
    fi
    if pgrep -f "npc" >/dev/null; then
        sudo npc stop
    else
        echo "客户端未运行，无需停止。"
        exit 0
    fi
    if pgrep -f "npc" >/dev/null; then
        exception_log "客户端停止失败。"
        exit 1
    else
        echo "客户端停止成功。"
    fi
}
# 菜单
function menu() {
    clear
    # 定义菜单项数组
    local options=(
        "1. 安装服务端"
        "2. 安装客户端"
        "============="
        "3. 卸载服务端"
        "4. 卸载客户端"
        "============="
        "5. 启动服务端"
        "6. 启动客户端"
        "============="
        "7. 关闭服务端"
        "8. 关闭客户端"
        "============="
        "0. 退出"
    )

    # 打印菜单
    for option in "${options[@]}"; do
        echo "$option"
    done

    # 获取用户选择
    read -p "请选择操作：" choice

    # 处理用户输入
    case $choice in
        1)
            install_server
            ;;
        2)
            install_client
            ;;
        3)
            uninstall_server
            ;;
        4)
            uninstall_client
            ;;
        5)
            start_server
            ;;
        6)
            start_client
            ;;
        7)
            stop_server
            ;;
        8)
            stop_client
            ;;
        0)
            exit 0
            ;;
        *)
            echo "无效的选择，请重新输入。"
            menu
            ;;
    esac
}
menu