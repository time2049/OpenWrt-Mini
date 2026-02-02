# DIY-1 此脚本功能：添加外部插件
# =======================================================================================================================
# 1-添加 opentomcat 主题 (如果你还需要的话)
git clone https://github.com/WukongMaster/luci-theme-opentomcat.git package/luci-theme-opentomcat

# 2-添加 PassWall 插件
echo "src-git passwall_luci https://github.com/Openwrt-Passwall/openwrt-passwall.git;main" >> "feeds.conf.default"
echo "src-git passwall_packages https://github.com/Openwrt-Passwall/openwrt-passwall-packages.git;main" >> "feeds.conf.default"

# 3-添加 OpenClash 插件
sed -i '$a\src-git openclash https://github.com/vernesong/OpenClash' ./"feeds.conf.defaut"
