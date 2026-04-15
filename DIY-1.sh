#!/bin/bash
# DIY-1 此脚本功能：添加外部插件 (针对 OpenWrt 24.10 优化版)
# =======================================================================================================================

# 1. 添加 PowerOff 关机插件
# 这个插件比较轻量，兼容性尚可
git clone https://github.com/WukongMaster/luci-app-poweroff.git package/luci-app-poweroff

# 2. 添加 Argon 主题 (替代崩溃的 opentomcat)
# Argon 对 ucode 架构支持最好，是目前 24.10 固件的标配
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 3. 添加 PassWall 插件
# 保持原样，这是最稳妥的 feeds 添加方式
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> "feeds.conf.default"
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
