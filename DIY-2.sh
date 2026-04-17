#!/bin/bash
# DIY-2 此脚本功能：修改固件参数（J1900 毕业精简版 - 2026 最终修正版）
# ============================================================================================

# 1-修改管理地址为 10.1.1.1
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本 (6.12)
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# --- PassWall 官方最新版强效补丁 ---
# 彻底粉碎旧文件夹，确保拉取官方最新 main 分支，不留残留缓存
rm -rf package/feeds/luci/luci-app-passwall
rm -rf package/feeds/packages/passwall
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall
rm -rf ./tmp

# 强制重写 feeds.conf.default 确保源地址正确
sed -i '/passwall/d' feeds.conf.default
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

# 刷新并【强制覆盖】安装，彻底解决版本不新问题
./scripts/feeds update -a
./scripts/feeds install -f -a

# --- 主题与界面优化 ---
# 锁定 Argon 为默认主题（包括编译选项和开机默认配置）
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/modules/luci-base/root/etc/config/luci
rm -rf feeds/luci/themes/luci-theme-opentomcat
rm -rf feeds/luci/themes/luci-theme-design

# 5-修改时间格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

# 6-添加编译日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(BUILD_DATE_PREFIX)-/g' ./include/image.mk
sed -i "/DTS_DIR:=\$(LINUX_DIR)/a\BUILD_DATE_PREFIX := \$(shell date +'%F')" ./include/image.mk

# 7-只显示CPU型号
[ -f package/lean/autocore/files/x86/autocore ] && sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 8. 核心插件与兼容性选中
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config
echo 'CONFIG_PACKAGE_luci-theme-argon=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-argon-config=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-poweroff=y' >> .config

# 9. 找回 UPnP 服务（你专门要的功能）
echo 'CONFIG_PACKAGE_luci-app-upnp=y' >> .config

# 10. 彻底关闭无用大型插件 (OpenClash/DDNS)
sed -i '/CONFIG_PACKAGE_luci-app-openclash/d' .config
sed -i 's/CONFIG_FEED_openclash=y/CONFIG_FEED_openclash=n/g' .config
sed -i 's/CONFIG_DEFAULT_luci-app-ddns=y/CONFIG_DEFAULT_luci-app-ddns=n/g' .config

# 11. 磁盘空间扩容 (1GB)
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/g' .config

# 15. PassWall UDP 与 转发核心补丁
echo 'CONFIG_PACKAGE_kmod-nft-tproxy=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ipt-tproxy=y' >> .config

# --------------------------------------------------------------------------------------------
# 🚀 以下为【精简瘦身】补丁 🚀

# 16. 精简语言包
find ./feeds/luci/modules/luci-base/po/ -mindepth 1 -maxdepth 1 -not -name "zh_Hans" -not -name "en" -exec rm -rf {} +

# 17. 物理删除冗余插件
rm -rf package/lean/luci-app-usb-printer
rm -rf package/lean/luci-app-vsftpd
rm -rf package/lean/luci-app-syncdial
rm -rf package/lean/luci-app-vlmcsd

# 18. 强制不选中非必要项
echo 'CONFIG_PACKAGE_luci-app-filetransfer=n' >> .config
echo 'CONFIG_PACKAGE_luci-app-unblockmusic=n' >> .config
echo 'CONFIG_PACKAGE_luci-app-access-control=n' >> .config

# 19. 移除无关驱动
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-rtl8152=y/CONFIG_PACKAGE_kmod-usb-net-rtl8152=n/g' .config
# ============================================================================================
