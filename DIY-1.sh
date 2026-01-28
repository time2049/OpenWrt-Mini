# DIY-1 此脚本功能：添加外部插件
# =======================================================================================================================
# 1-添加 opentomcat 主题 (如果你还需要的话)
git clone https://github.com/WukongMaster/luci-theme-opentomcat.git package/luci-theme-opentomcat

# 2-添加 Argon 主题 (锁定 v1.8.4 稳定版，不带设置选项)
# 去掉了之前的 -b 18.06，改为 v1.8.4 标签，这个版本更稳定且适配性好
git clone -b v1.8.4 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon

# 3-添加 PassWall 插件
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> "feeds.conf.default"
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
