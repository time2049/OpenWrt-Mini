#!/bin/bash
# DIY-1 此脚本功能：添加外部插件
# =======================================================================================================================

# 1. 物理清理旧插件目录（防止重复拉取导致报错）
rm -rf package/luci-app-poweroff
rm -rf package/luci-theme-argon
rm -rf package/luci-app-argon-config

# 2. 添加 PowerOff 关机插件
git clone https://github.com/WukongMaster/luci-app-poweroff.git package/luci-app-poweroff

# 3. 添加 Argon 主题 (使用 v2.3.2 稳定版，适配新版 LuCI)
# 这一步直接替换为你红圈选中的 2.3.2 源码分支
git clone -b v2.3.2 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
