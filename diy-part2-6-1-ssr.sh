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
sed -i 's/ImmortalWrt/ImmortalWrt-Hanwckf/g' package/base-files/files/bin/config_generate

# Modify filename, add date prefix
sed -i 's/IMG_PREFIX:=/IMG_PREFIX:=$(shell date +"%Y%m%d")-ssr-23.05/1' include/image.mk

# Modify ppp-down, add sleep 3. my source code is change, no need this
sed -i '$a\\sleep 3' package/network/services/ppp/files/lib/netifd/ppp-down


    - name: Load custom configuration
      run: |
        [ -e files ] && mv files openwrt/files

        [ -e "$CONFIG_FILE" ] && \
          mv "$CONFIG_FILE" openwrt/.config

        chmod +x "$DIY_P2_SH"

        cd openwrt

        "$GITHUB_WORKSPACE/$DIY_P2_SH"

        echo "========================================"
        echo "Force JCG Q30 / MT7981 target"
        echo "========================================"

        # 删除所有 MT7622 target
        sed -i '/CONFIG_TARGET_mediatek_mt7622=/d' .config
        sed -i '/CONFIG_TARGET_DEVICE_mediatek_mt7622_/d'
        sed -i '/CONFIG_TARGET_DEVICE_PACKAGES_mediatek_mt7622_/d'

        # 删除可能存在的其他 Mediatek target
        sed -i '/CONFIG_TARGET_mediatek_mt7986=/d' .config
        sed -i '/CONFIG_TARGET_DEVICE_mediatek_mt7986_/d'
        sed -i '/CONFIG_TARGET_DEVICE_PACKAGES_mediatek_mt7986_/d'

        # 强制 MT7981
        echo 'CONFIG_TARGET_mediatek=y' >> .config
        echo 'CONFIG_TARGET_mediatek_mt7981=y' >> .config
        echo 'CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_jcg_q30=y' >> .config
        echo 'CONFIG_TARGET_DEVICE_PACKAGES_mediatek_mt7981_DEVICE_jcg_q30=""' >> .config

        echo "========================================"
        echo "Current target configuration:"
        echo "========================================"

        grep '^CONFIG_TARGET' .config | grep -E 'mediatek|mt7981|mt7622' || true
