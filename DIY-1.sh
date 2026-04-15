#!/bin/bash
# DIY-1 此脚本功能：添加外部插件
# =======================================================================================================================

# 1. 添加 PowerOff 关机插件
git clone https://github.com/WukongMaster/luci-app-poweroff.git package/luci-app-poweroff

# 2. 添加 Argon 主题 (适配新版 LuCI，取代崩溃的 opentomcat)
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 3. 添加 PassWall 插件 (保留这一个就够了)
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> "feeds.conf.default"
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> "feeds.conf.default"

# 注意：SSR+ 和 OpenClash 的源已彻底移除
