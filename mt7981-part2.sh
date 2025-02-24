#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.6.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Modify wifi name
cat > package/base-files/files/etc/uci-defaults/99-set-wifi.sh <<EOF
#uci set network.lan.ipaddr='192.168.6.1'
#uci commit network
for radio in \$(uci show wireless | grep '=wifi-device' | cut -d'.' -f2 | cut -d'=' -f1);do
    uci set wireless.\$radio.disabled='0'
    #uci set wireless.default_\$radio.ssid='OpenWrt'
    #uci set wireless.default_radio1.ssid='OpenWrt-5G'
    uci set wireless.default_\$radio.encryption='psk-mixed'
    uci set wireless.default_\$radio.key='1234567890'
done
uci commit wireless
wifi reload
exit 0
EOF

# modify distfeeds
cat > package/base-files/files/etc/uci-defaults/98-set-distfeeds.sh <<EOF
    sed -i '/src\/gz immortalwrt_vnt\|src\/gz immortalwrt_core/d' /etc/opkg/distfeeds.conf
exit 0
EOF

# download clash core
curl -sL -m 30 --retry 2 https://github.com/vernesong/OpenClash/releases/download/Clash/clash-"$CPU_MODEL".tar.gz -o /tmp/clash.tar.gz
tar zxvf /tmp/clash.tar.gz -C /tmp >/dev/null 2>&1
chmod +x /tmp/clash >/dev/null 2>&1
mkdir -p package/base-files/files/etc/openclash/core
mv /tmp/clash package/base-files/files/etc/openclash/core/clash_meta >/dev/null 2>&1
rm -rf /tmp/clash.tar.gz >/dev/null 2>&1
