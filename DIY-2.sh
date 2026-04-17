#!/bin/bash
# DIY-2 此脚本功能：修改固件参数（J1900 毕业精简版 - 2026 最终完美版）
# ============================================================================================

# 1-修改管理地址为 10.1.1.1
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本为最新的 6.12
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码 (确保开机是空密码)
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# --- 核心模块：PassWall 强制官方最新版 ---
# 物理粉碎所有旧版文件夹，确保拉取 main 分支
rm -rf package/feeds/luci/luci-app-passwall
rm -rf package/feeds/packages/passwall
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall
rm -rf ./tmp

sed -i '/passwall/d' feeds.conf.default
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

# 刷新并强制安装 (必须带 -f)
./scripts/feeds update -a
./scripts/feeds install -f -a

# --- 核心模块：界面主题深度精简 ---
# 1. 彻底物理消灭 opentomcat 和 design (同时清理 feeds 和 package 目录)
rm -rf feeds/luci/themes/luci-theme-opentomcat
rm -rf package/lean/luci-theme-opentomcat
rm -rf feeds/luci/themes/luci-theme-design
rm -rf package/lean/luci-theme-design

# 2. 锁定 Argon 为唯一默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/modules/luci-base/root/etc/config/luci

# 5-修改系统显示的时间格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

# 6-添加编译日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(BUILD_DATE_PREFIX)-/g' ./include/image.mk
sed -i "/DTS_DIR:=\$(LINUX_DIR)/a\BUILD_DATE_PREFIX := \$(shell date +'%F')" ./include/image.mk

# 7-优化 CPU 型号显示
[ -f package/lean/autocore/files/x86/autocore ] && sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 8. 强制点名选中核心插件 (确保 PassWall、UPnP、Argon 都在)
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config
echo 'CONFIG_PACKAGE_luci-theme-argon=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-argon-config=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-upnp=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-poweroff=y' >> .config

# 9. 显式禁用残留主题 (双重保险)
echo 'CONFIG_PACKAGE_luci-theme-opentomcat=n' >> .config
echo 'CONFIG_PACKAGE_luci-theme-design=n' >> .config

# 10. 彻底关闭大型臃肿插件
sed -i '/CONFIG_PACKAGE_luci-app-openclash/d' .config
sed -i 's/CONFIG_FEED_openclash=y/CONFIG_FEED_openclash=n/g' .config
sed -i 's/CONFIG_DEFAULT_luci-app-ddns=y/CONFIG_DEFAULT_luci-app-ddns=n/g' .config

# 11. 磁盘空间扩容为 1024MB
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/g' .config

# 12. 补齐 UDP 转发内核模块
echo 'CONFIG_PACKAGE_kmod-nft-tproxy=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ipt-tproxy=y' >> .config

# --- 极致瘦身补丁 ---
# 13. 只保留中英文语言包
find ./feeds/luci/modules/luci-base/po/ -mindepth 1 -maxdepth 1 -not -name "zh_Hans" -not -name "en" -exec rm -rf {} +

# 14. 移除对 J1900 无用的硬件驱动和多余插件
rm -rf package/lean/luci-app-usb-printer
rm -rf package/lean/luci-app-vsftpd
rm -rf package/lean/luci-app-syncdial
rm -rf package/lean/luci-app-vlmcsd
echo 'CONFIG_PACKAGE_luci-app-filetransfer=n' >> .config
echo 'CONFIG_PACKAGE_luci-app-unblockmusic=n' >> .config
echo 'CONFIG_PACKAGE_luci-app-access-control=n' >> .config
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-rtl8152=y/CONFIG_PACKAGE_kmod-usb-net-rtl8152=n/g' .config

# ============================================================================================
