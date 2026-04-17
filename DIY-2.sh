#!/bin/bash
# DIY-2 此脚本功能：修改固件参数（J1900 毕业精简版）
# ============================================================================================

# 1-修改管理地址为 10.1.1.1
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本 (6.12)
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings
# --- 彻底解决 PassWall 版本过旧的强力手段 ---

# 1. 物理粉碎 Lean 源码自带的旧版插件包，强制腾出位子
rm -rf package/feeds/luci/luci-app-passwall
rm -rf package/feeds/packages/passwall
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/packages/net/passwall

# 2. 强制删除可能存在的缓存索引，逼系统重新扫描 feeds.conf.default
rm -rf ./tmp

# 3. 再次确保 feeds.conf.default 的内容是官方最新地址
# （这一步是双重保险，防止文件被自动还原）
sed -i '/passwall/d' feeds.conf.default
echo 'src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main' >> feeds.conf.default
echo 'src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main' >> feeds.conf.default

# 4. 强力刷新：update 拉取，install -f 强制覆盖安装
./scripts/feeds update -a
./scripts/feeds install -f -a
# 4-修复默认主题为 argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 5-修改时间格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

# 6-添加编译日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(BUILD_DATE_PREFIX)-/g' ./include/image.mk
sed -i "/DTS_DIR:=\$(LINUX_DIR)/a\BUILD_DATE_PREFIX := \$(shell date +'%F')" ./include/image.mk

# 7-只显示CPU型号
[ -f package/lean/autocore/files/x86/autocore ] && sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 8. 修复 Argon 主题兼容性
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config

# 9. 强制选中核心插件
echo 'CONFIG_PACKAGE_luci-theme-argon=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-argon-config=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-poweroff=y' >> .config

# 10. 彻底关闭无用大型插件 (OpenClash/DDNS)
sed -i '/CONFIG_PACKAGE_luci-app-openclash/d' .config
sed -i 's/CONFIG_FEED_openclash=y/CONFIG_FEED_openclash=n/g' .config
sed -i 's/CONFIG_DEFAULT_luci-app-ddns=y/CONFIG_DEFAULT_luci-app-ddns=n/g' .config

# 11. 磁盘空间扩容 (1GB)
sed -i 's/CONFIG_TARGET_ROOTFS_PARTSIZE=.*/CONFIG_TARGET_ROOTFS_PARTSIZE=1024/g' .config

# 12. 物理删除无用主题源码 (彻底消灭 opentomcat/design)
rm -rf feeds/luci/themes/luci-theme-opentomcat
rm -rf feeds/luci/themes/luci-theme-design

# 13. 锁定 Argon 默认配置
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/modules/luci-base/root/etc/config/luci

# 14. 强行刷新 Feed 缓存
./scripts/feeds update -a && ./scripts/feeds install -a

# 15. PassWall 依赖补丁
echo 'CONFIG_PACKAGE_kmod-nft-tproxy=y' >> .config
echo 'CONFIG_PACKAGE_kmod-ipt-tproxy=y' >> .config

# --------------------------------------------------------------------------------------------
# 🚀 以下为【精简瘦身】补丁 🚀

# 16. 精简语言包 (只保留简体中文和英文)
# 这一步能大幅减少固件体积和编译时间
find ./feeds/luci/modules/luci-base/po/ -mindepth 1 -maxdepth 1 -not -name "zh_Hans" -not -name "en" -exec rm -rf {} +

# 17. 物理删除冗余插件 (有些插件即便不选也会被拉取)
rm -rf package/lean/luci-app-usb-printer     # 打印服务
rm -rf package/lean/luci-app-vsftpd          # FTP服务器
rm -rf package/lean/luci-app-syncdial        # 多线多拨
rm -rf package/lean/luci-app-vlmcsd          # KMS激活 (如果你不用路由激活Windows)

# 18. 强制不选中非必要项 (清理后台菜单)
echo 'CONFIG_PACKAGE_luci-app-filetransfer=n' >> .config   # 文件传输
echo 'CONFIG_PACKAGE_luci-app-unblockmusic=n' >> .config    # 解锁网易云 (如果不需要)
echo 'CONFIG_PACKAGE_luci-app-access-control=n' >> .config # 访问控制
#echo 'CONFIG_PACKAGE_luci-app-upnp=n' >> .config           # UPNP (根据需求决定，建议保留或删除)

# 19. 移除默认编译的一些无关驱动
sed -i 's/CONFIG_PACKAGE_kmod-usb-net-rtl8152=y/CONFIG_PACKAGE_kmod-usb-net-rtl8152=n/g' .config
# ============================================================================================
