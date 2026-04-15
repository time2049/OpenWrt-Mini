#!/bin/bash
# DIY-2 此脚本功能：修改固件参数 (针对 24.10 优化版)
# ============================================================================================

# 1-修改管理地址 (改为 10.1.1.1)
sed -i 's/192.168.1.1/10.1.1.1/g' package/base-files/files/bin/config_generate

# 2-修改内核版本 (保持你的 6.12 尝试，注意 24.10 默认通常就是较新内核)
sed -i 's/KERNEL_PATCHVER:=6.6/KERNEL_PATCHVER:=6.12/g' ./target/linux/x86/Makefile

# 3-删除默认密码
# 注意：新版 LEDE 路径可能在 package/emenu/default-settings 或类似位置，确保路径正确
[ -f package/lean/default-settings/files/zzz-default-settings ] && sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# 4-修复核心错误：修改默认主题为 Argon
# 这一步是修复 Web 报错的关键！不再指向 opentomcat
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 5-修改时间格式
# 适配新版 autocore 路径
find package/ -name "index.htm" | xargs sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g'

# 6-添加编译日期 (保持原样)
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(BUILD_DATE_PREFIX)-/g' ./include/image.mk
sed -i "/DTS_DIR:=\$(LINUX_DIR)/a\BUILD_DATE_PREFIX := \$(shell date +'%F')" ./include/image.mk

# 7-只显示CPU型号 (针对 x86 优化)
[ -f package/lean/autocore/files/x86/autocore ] && sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 8-强制设置默认主题配置 (兜底方案)
# 确保系统第一次启动时直接进入 Argon 界面
mkdir -p package/base-files/files/etc/uci-defaults
cat <<EOF > package/base-files/files/etc/uci-defaults/99-theme
uci set luci.main.mediaurlbase='/luci-static/argon'
uci commit luci
exit 0
EOF
