#!/bin/bash
# DIY-1 此脚本功能：添加外部插件
# =======================================================================================================================

# 1. 物理清理旧插件目录（防止重复拉取导致报错）
rm -rf package/luci-app-poweroff
rm -rf package/luci-theme-argon
rm -rf package/luci-app-argon-config
# =======================================================================================================================

# 2. 添加 PowerOff 关机插件
git clone https://github.com/WukongMaster/luci-app-poweroff.git package/luci-app-poweroff
# =======================================================================================================================

# 3. 添加 Argon 主题 (使用 v2.3.2 稳定版，适配新版 LuCI)
# 这一步直接替换为你红圈选中的 2.3.2 源码分支
git clone -b v2.3.2 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# =======================================================================================================================

# 2. 强制拉取最新的 Xray 和 Sing-box 源码定义
# 这样做可以覆盖掉 OpenWrt 源码中可能自带的旧版本
mkdir -p package/custom
cd package/custom
git clone --depth 1 https://github.com/xiaorouji/openwrt-passwall-packages.git temp_pw
rm -rf ../../feeds/passwall_packages/xray-core
rm -rf ../../feeds/passwall_packages/sing-box
cp -r temp_pw/xray-core ../../package/
cp -r temp_pw/sing-box ../../package/
rm -rf temp_pw
cd ../../
