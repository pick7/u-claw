#!/bin/bash
# ============================================================
# U-Claw 虾盘 - macOS 一键安装并启动
# 从 U 盘解压到电脑，然后启动 OpenClaw
# ============================================================

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo ""
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║     U-Claw 虾盘 v1.1                ║"
echo "  ║     一键安装并启动 (macOS)           ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

USB_DIR="$(cd "$(dirname "$0")" && pwd)"
ARCHIVE="$USB_DIR/U-Claw.tar.gz"
INSTALL_DIR="$HOME/U-Claw"

# 移除 macOS 隔离标记（解决"无法验证开发者"弹窗）
xattr -rd com.apple.quarantine "$USB_DIR" 2>/dev/null || true

# 检查压缩包
if [ ! -f "$ARCHIVE" ]; then
    echo -e "  ${RED}错误: 找不到 U-Claw.tar.gz${NC}"
    echo "  请确保此脚本和压缩包在同一目录"
    read -p "  按回车键退出..."
    exit 1
fi

# 检查是否已安装
if [ -d "$INSTALL_DIR/openclaw/node_modules" ]; then
    echo -e "  ${GREEN}检测到已安装的 U-Claw${NC}"
    echo "  位置: $INSTALL_DIR"
    echo ""
    echo -e "  ${YELLOW}[1] 直接启动（跳过解压）${NC}"
    echo "  [2] 重新安装（覆盖现有）"
    echo ""
    read -p "  请选择 [1/2，默认1]: " choice
    choice="${choice:-1}"
    if [ "$choice" = "2" ]; then
        echo ""
        echo -e "  ${YELLOW}正在重新安装...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo ""
        echo -e "  ${CYAN}跳过解压，直接启动...${NC}"
    fi
fi

# 解压（如果需要）
if [ ! -d "$INSTALL_DIR/openclaw/node_modules" ]; then
    echo ""
    echo -e "  ${CYAN}正在解压 U-Claw 到 $INSTALL_DIR ...${NC}"
    echo "  这可能需要 30-60 秒，请稍等..."
    echo ""

    mkdir -p "$HOME"
    cd "$HOME"
    tar xzf "$ARCHIVE"

    if [ $? -ne 0 ]; then
        echo -e "  ${RED}解压失败！${NC}"
        read -p "  按回车键退出..."
        exit 1
    fi

    echo -e "  ${GREEN}解压完成！${NC}"
    echo ""
fi

# 删除 Windows 相关文件（可选，不影响运行）
# rm -f "$INSTALL_DIR"/Windows-*.bat 2>/dev/null

# 启动 OpenClaw
echo -e "  ${CYAN}正在启动 OpenClaw...${NC}"
echo ""

cd "$INSTALL_DIR"
exec bash "$INSTALL_DIR/Mac-从U盘启动.command"
