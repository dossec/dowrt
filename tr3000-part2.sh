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
# sed -i "s/192\.168\.[0-9]*\.[0-9]*/192.168.6.1/g" package/base-files/files/bin/config_generate

# Modify default theme
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Modify wifi name
cat > package/base-files/files/etc/uci-defaults/99-set-wifi.sh <<EOF
uci set network.lan.ipaddr='192.168.6.1'
uci commit network
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

# load mtd_rw
sed -i "/exit 0/i insmod mtd-rw i_want_a_brick=1" package/base-files/files/etc/rc.local
