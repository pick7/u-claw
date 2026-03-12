#!/bin/bash
# ============================================================
# U-Claw USB Builder - 一键制作 U 盘
# 运行后自动下载所有依赖，打包成可直接拷贝到 U 盘的完整目录
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
NODE_VER="v22.14.0"
MIRROR="https://registry.npmmirror.com"
NODE_MIRROR="https://npmmirror.com/mirrors/node"

# Output directory
OUTPUT_DIR="$REPO_DIR/usb-build"
USB_DIR="$OUTPUT_DIR/U-Claw"

clear
echo ""
echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   U-Claw USB Builder                 ║"
echo "  ║   一键制作 U 盘                       ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ---- Detect platform ----
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

echo -e "  ${BOLD}系统:${NC} $OS $ARCH"
echo ""

# Ask which platforms to build for
echo -e "  ${BOLD}选择要打包的平台:${NC}"
echo -e "  ${GREEN}[1]${NC} 仅 Mac Apple Silicon (arm64)"
echo -e "  ${GREEN}[2]${NC} 仅 Windows (x64)"
echo -e "  ${GREEN}[3]${NC} Mac + Windows (全部)"
echo ""

if [ -t 0 ]; then
    read -p "  选择 [1-3, 默认 3]: " PLATFORM_CHOICE
else
    PLATFORM_CHOICE="3"
fi
PLATFORM_CHOICE="${PLATFORM_CHOICE:-3}"

BUILD_MAC=false
BUILD_WIN=false
case $PLATFORM_CHOICE in
    1) BUILD_MAC=true ;;
    2) BUILD_WIN=true ;;
    *) BUILD_MAC=true; BUILD_WIN=true ;;
esac

echo ""

# ---- Clean previous build ----
if [ -d "$USB_DIR" ]; then
    echo -e "  ${YELLOW}清理上次构建...${NC}"
    rm -rf "$USB_DIR"
fi
mkdir -p "$USB_DIR"

# ---- Step 1: Copy scripts and HTML ----
echo -e "  ${BOLD}[1/5] 复制脚本和页面...${NC}"

# Copy all launch scripts and HTML pages
for f in Mac-Start.command Mac-Menu.command Windows-Start.bat Windows-Menu.bat \
         Config.html U-Claw.html SkillHub.html default-config.json migrate.js setup.sh; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
        cp "$SCRIPT_DIR/$f" "$USB_DIR/"
        echo -e "  ${DIM}  + $f${NC}"
    fi
done

# Make scripts executable
chmod +x "$USB_DIR"/*.command 2>/dev/null || true
chmod +x "$USB_DIR"/*.sh 2>/dev/null || true

echo -e "  ${GREEN}脚本复制完成 ✓${NC}"
echo ""

# ---- Step 2: Create data directory structure ----
echo -e "  ${BOLD}[2/5] 创建数据目录...${NC}"

mkdir -p "$USB_DIR/data/.openclaw"
mkdir -p "$USB_DIR/data/memory"
mkdir -p "$USB_DIR/data/backups"

# Default config
cat > "$USB_DIR/data/.openclaw/openclaw.json" << 'CFGEOF'
{
  "gateway": {
    "mode": "local",
    "auth": { "token": "uclaw" }
  }
}
CFGEOF

echo -e "  ${GREEN}数据目录创建完成 ✓${NC}"
echo ""

# ---- Step 3: Download Node.js runtimes ----
echo -e "  ${BOLD}[3/5] 下载 Node.js 运行时...${NC}"

download_node() {
    local PLATFORM=$1
    local TARGET_DIR=$2

    if [ -d "$TARGET_DIR" ] && [ -f "$TARGET_DIR/bin/node" -o -f "$TARGET_DIR/node.exe" ]; then
        echo -e "  ${GREEN}$PLATFORM 已存在，跳过${NC}"
        return
    fi

    mkdir -p "$TARGET_DIR"

    if echo "$PLATFORM" | grep -q "win"; then
        local ZIPNAME="node-${NODE_VER}-${PLATFORM}.zip"
        local URL="${NODE_MIRROR}/${NODE_VER}/${ZIPNAME}"
        echo -e "  ${CYAN}下载 $ZIPNAME...${NC}"
        curl -# -L "$URL" -o "/tmp/$ZIPNAME"

        # Unzip
        local TMPEXTRACT="/tmp/node-extract-$$"
        mkdir -p "$TMPEXTRACT"
        unzip -q "/tmp/$ZIPNAME" -d "$TMPEXTRACT"
        cp -R "$TMPEXTRACT"/node-${NODE_VER}-${PLATFORM}/* "$TARGET_DIR/"
        rm -rf "$TMPEXTRACT" "/tmp/$ZIPNAME"
    else
        local TARBALL="node-${NODE_VER}-${PLATFORM}.tar.gz"
        local URL="${NODE_MIRROR}/${NODE_VER}/${TARBALL}"
        echo -e "  ${CYAN}下载 $TARBALL...${NC}"
        curl -# -L "$URL" -o "/tmp/$TARBALL"
        tar -xzf "/tmp/$TARBALL" -C "$TARGET_DIR" --strip-components=1
        rm -f "/tmp/$TARBALL"
        chmod +x "$TARGET_DIR/bin/node"
    fi

    echo -e "  ${GREEN}$PLATFORM 下载完成 ✓${NC}"
}

RUNTIME_DIR="$USB_DIR/app/runtime"
mkdir -p "$RUNTIME_DIR"

if $BUILD_MAC; then
    download_node "darwin-arm64" "$RUNTIME_DIR/node-mac-arm64"
fi

if $BUILD_WIN; then
    download_node "win-x64" "$RUNTIME_DIR/node-win-x64"
fi

echo ""

# ---- Step 4: Install OpenClaw + plugins ----
echo -e "  ${BOLD}[4/5] 安装 OpenClaw + QQ 插件...${NC}"

CORE_DIR="$USB_DIR/app/core"
mkdir -p "$CORE_DIR"

# Determine which Node.js to use for npm install
if $BUILD_MAC && [ -f "$RUNTIME_DIR/node-mac-arm64/bin/node" ]; then
    INSTALL_NODE="$RUNTIME_DIR/node-mac-arm64/bin/node"
    INSTALL_NPM="$RUNTIME_DIR/node-mac-arm64/bin/npm"
elif command -v node >/dev/null 2>&1; then
    INSTALL_NODE="node"
    INSTALL_NPM="npm"
else
    echo -e "  ${RED}没有可用的 Node.js，无法安装依赖${NC}"
    exit 1
fi

# Create package.json
cat > "$CORE_DIR/package.json" << 'PKGEOF'
{
  "name": "u-claw-core",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "openclaw": "latest"
  }
}
PKGEOF

echo -e "  ${CYAN}安装 OpenClaw (国内镜像)...${NC}"
cd "$CORE_DIR"
"$INSTALL_NODE" "$INSTALL_NPM" install --registry="$MIRROR" 2>&1 | tail -3

# Install QQ plugin
echo -e "  ${CYAN}安装 QQ 插件...${NC}"
"$INSTALL_NODE" "$INSTALL_NPM" install @sliverp/qqbot@latest --registry="$MIRROR" 2>&1 | tail -2

echo -e "  ${GREEN}OpenClaw + QQ 插件安装完成 ✓${NC}"
echo ""

# ---- Step 5: Calculate size and finish ----
echo -e "  ${BOLD}[5/5] 完成！${NC}"
echo ""

USB_SIZE=$(du -sh "$USB_DIR" | cut -f1)
FILE_COUNT=$(find "$USB_DIR" -type f | wc -l | tr -d ' ')

echo -e "  ${GREEN}${BOLD}╔══════════════════════════════════════════╗"
echo -e "  ║   ✅ U 盘制作完成！                       ║"
echo -e "  ╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${BOLD}输出目录:${NC} $USB_DIR"
echo -e "  ${BOLD}总大小:${NC}   $USB_SIZE"
echo -e "  ${BOLD}文件数:${NC}   $FILE_COUNT"
echo ""

if $BUILD_MAC; then
    echo -e "  ${GREEN}✓${NC} Mac Apple Silicon (arm64)"
fi
if $BUILD_WIN; then
    echo -e "  ${GREEN}✓${NC} Windows x64"
fi
echo ""

echo -e "  ${BOLD}接下来:${NC}"
echo ""
echo -e "  ${CYAN}1. 插入 U 盘（建议 4GB 以上）${NC}"
echo -e "  ${CYAN}2. 复制到 U 盘:${NC}"
echo ""
echo -e "     ${BOLD}Mac:${NC}"
echo -e "     cp -R $USB_DIR /Volumes/你的U盘/"
echo ""
echo -e "     ${BOLD}或者用 Finder:${NC}"
echo -e "     直接把 ${BOLD}U-Claw${NC} 文件夹拖到 U 盘"
echo ""
echo -e "  ${CYAN}3. 在目标电脑上:${NC}"
echo -e "     Mac: 双击 ${BOLD}Mac-Start.command${NC}"
echo -e "     Win: 双击 ${BOLD}Windows-Start.bat${NC}"
echo ""

# Optional: create tar.gz
if [ -t 0 ]; then
    read -p "  是否也打包成 tar.gz 方便分发？(y/n): " -n 1 PACK
    echo ""
    if [ "$PACK" = "y" ] || [ "$PACK" = "Y" ]; then
        echo ""
        echo -e "  ${CYAN}打包中...${NC}"
        cd "$OUTPUT_DIR"
        tar -czf "U-Claw.tar.gz" "U-Claw/"
        PACK_SIZE=$(du -sh "$OUTPUT_DIR/U-Claw.tar.gz" | cut -f1)
        echo -e "  ${GREEN}打包完成: $OUTPUT_DIR/U-Claw.tar.gz ($PACK_SIZE)${NC}"
    fi
fi

echo ""
echo -e "  ${DIM}完成！${NC}"
