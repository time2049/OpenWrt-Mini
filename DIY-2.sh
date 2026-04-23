#!/bin/bash
# DIY-2 此脚本功能：修改固件参数（J1900 毕业精简版 - 2026 最终完美版）
# ============================================================================================

# 1-修改管理地址为 10.1.1.1
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本为最新的 6.12
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# --- 核心模块：PassWall 强制拉取最新 ---
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

# --- 主题精简：只留 Argon ---
rm -rf feeds/luci/themes/luci-theme-opentomcat
rm -rf package/lean/luci-theme-opentomcat
rm -rf feeds/luci/themes/luci-theme-design
rm -rf package/lean/luci-theme-design
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/modules/luci-base/root/etc/config/luci

# ============================================================================================
# 重点逻辑：强制劫持最新核心（Xray & Sing-box）
# ============================================================================================
mkdir -p latest_cores && cd latest_cores
git clone --depth 1 https://github.com/ty666/openwrt-passwall-packages.git temp_repo
rm -rf ../package/xray-core ../package/sing-box
cp -r temp_repo/xray-core ../package/
cp -r temp_repo/sing-box ../package/
cd .. && rm -rf latest_cores

# ============================================================================================
# 写入 .config 确保核心和精简配置生效
# ============================================================================================
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

# ============================================================================================
# 极致瘦身：移除 J1900 无用驱动、网易云、文件管理、家长控制等
# ============================================================================================
rm -rf package/lean/luci-app-unblockmusic
rm -rf package/lean/luci-app-filetransfer
rm -rf package/lean/luci-app-usb-printer
rm -rf package/lean/luci-app-vsftpd
rm -rf package/lean/luci-app-syncdial
rm -rf package/lean/luci-app-access-control
rm -rf package/lean/luci-app-vlmcsd

# 禁用 USB 网卡驱动
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-rtl8152=y/CONFIG_PACKAGE_kmod-usb-net-rtl8152=n/g' .config
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-asix=y/CONFIG_PACKAGE_kmod-usb-net-asix=n/g' .config

# 只保留中英文语言包
find ./feeds/luci/modules/luci-base/po/ -mindepth 1 -maxdepth 1 -not -name "zh_Hans" -not -name "en" -exec rm -rf {} +

# 修正时间显示格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'
# ============================================================================================
