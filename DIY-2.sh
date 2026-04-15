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
