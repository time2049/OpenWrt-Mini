#!/bin/bash
# DIY-2 此脚本功能：修改固件参数
# ============================================================================================

# 1-修改管理地址为 10.1.1.1
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本 (6.12)
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# 4-修复核心错误：将默认主题由 bootstrap/opentomcat 修改为 argon
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 5-修改时间格式
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

# 6-添加编译日期
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(BUILD_DATE_PREFIX)-/g' ./include/image.mk
sed -i "/DTS_DIR:=\$(LINUX_DIR)/a\BUILD_DATE_PREFIX := \$(shell date +'%F')" ./include/image.mk

# 7-只显示CPU型号
[ -f package/lean/autocore/files/x86/autocore ] && sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore
# 8. 修复 Argon 主题崩溃的核心：强制添加兼容包
# 这一行是解决你之前那个“__entries 为 nil”报错的唯一解药
echo 'CONFIG_PACKAGE_luci-compat=y' >> .config

# 9. 强制选中你刚添加的插件，确保它们出现在固件里
echo 'CONFIG_PACKAGE_luci-theme-argon=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-argon-config=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-passwall=y' >> .config
echo 'CONFIG_PACKAGE_luci-app-poweroff=y' >> .config

# 10. 额外补丁：确保 OpenClash 被彻底关闭（防止它占用资源导致体积过大）
sed -i '/CONFIG_PACKAGE_luci-app-openclash/d' .config
