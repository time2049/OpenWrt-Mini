#!/bin/bash
# DIY-2 此脚本功能：J1900 极致精简毕业版 (2026.04)
# 目标：从官方源强升 Xray、Sing-Box 至最新版，并移除无用驱动
# ============================================================================================

# 1-基础设置：管理地址 10.1.1.1，内核 6.12，空密码
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# 2-PassWall 源码重定向 (使用官方组织仓库，确保不 404)
rm -rf package/feeds/luci/luci-app-passwall
rm -rf package/feeds/packages/passwall
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall
rm -rf ./tmp

sed -i '/passwall/d' feeds.conf.default
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

./scripts/feeds update -a
./scripts/feeds install -f -a

# 3-界面主题深度精简：只保留 Argon
rm -rf feeds/luci/themes/luci-theme-opentomcat package/lean/luci-theme-opentomcat
rm -rf feeds/luci/themes/luci-theme-design package/lean/luci-theme-design
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/modules/luci-base/root/etc/config/luci

# ========================== 核心补丁块：强行注入官方最新版核心 ==========================
# 逻辑：直接从官方 packages 仓库拉取最新源码，放入 package/ 目录以获得最高编译优先级
mkdir -p latest_cores && cd latest_cores
git clone --depth 1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git temp_repo
rm -rf ../package/xray-core ../package/sing-box ../package/hysteria
cp -r temp_repo/xray-core ../package/
cp -r temp_repo/sing-box ../package/
cp -r temp_repo/hysteria ../package/
cd .. && rm -rf latest_cores
# ============================================================================================

# ========================== 极致精简块：删除 J1900 无用插件与驱动 ==========================
# 物理删除冗余：网易云解锁、文件管理、USB打印、多拨、家长控制等
rm -rf package/lean/luci-app-unblockmusic
rm -rf package/lean/luci-app-filetransfer
rm -rf package/lean/luci-app-usb-printer
rm -rf package/lean/luci-app-vsftpd
rm -rf package/lean/luci-app-syncdial
rm -rf package/lean/luci-app-access-control
rm -rf package/lean/luci-app-vlmcsd

# 禁用 USB 网卡驱动 (rtl8152/asix)
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-rtl8152=y/CONFIG_PACKAGE_kmod-usb-net-rtl8152=n/g' .config
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-asix=y/CONFIG_PACKAGE_kmod-usb-net-asix=n/g' .config

# 语言精简：只保留中英文
find ./feeds/luci/modules/luci-base/po/ -mindepth 1 -maxdepth 1 -not -name "zh_Hans" -not -name "en" -exec rm -rf {} +
# ============================================================================================

# 4-写入 .config 确保开关开启
cat >> .config <<EOF
CONFIG_PACKAGE_luci-compat=y
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-app-argon-config=y
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_xray-core=y
CONFIG_PACKAGE_sing-box=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Xray_core=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Sing_Box=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Hysteria2=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-poweroff=y
CONFIG_TARGET_ROOTFS_PARTSIZE=1024
EOF

# 5-修正时间格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

echo "DIY-2 极致精简且官方核心更新脚本执行完毕！"
