#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part3.sh
# Description: OpenWrt DIY script part 3 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

git clone --depth 1 https://github.com/jlzsss/luci-app-shadowsocksr.git package/luci-app-shadowsocksr
# git clone --depth 1 https://github.com/jlzsss/openwrt-dnsmasq-extra.git package/openwrt-dnsmasq-extra
git clone --depth 1 https://github.com/tty228/luci-app-serverchan.git package/luci-app-serverchan
git clone --depth 1 https://github.com/peter-tank/openwrt-minisign.git package/minisign
git clone --depth 1 https://github.com/aa65535/openwrt-chinadns.git package/chinadns
rm -rf feeds/kenzok8/luci-app-qbittorrent
rm -rf feeds/kenzok8/qbittorrent
rm -rf feeds/kenzok8/qBittorrent
rm -rf feeds/kenzok8/qBittorrent-Enhanced-Edition
rm -rf feeds/kenzok8/qBittorrent-static
rm -rf feeds/kenzok8/quickstart
rm -rf feeds/kenzok8/luci-app-nikki
rm -rf feeds/kenzok8/luci-app-quickstart
rm -rf feeds/kenzok8/luci-app-xray
rm -rf feeds/kenzok8/luci-app-xray-status
rm -rf feeds/lede/qBittorrent
rm -rf feeds/lede/qBittorrent-Enhanced-Edition
rm -rf feeds/luci/transmission
rm -rf feeds/luci/transmission-web-control
rm -rf feeds/luci2/luci-app-turboacc
./scripts/feeds install -p packages2 quickstart
./scripts/feeds install -p packages2 luci-app-quickstart
./scripts/feeds install -p luci2 transmission
./scripts/feeds install -p luci2 transmission-web-control
rm -rf feeds/packages/net/{qBittorrent,qBittorrent-static,xray-core,v2ray-geodata,sing-box,chinadns-ng,nikki,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls,haproxy}
rm -rf package/feeds/lede/php7
# rm -rf package/feeds/packages/php7
rm -rf feeds/lede/mt-drivers
rm -rf feeds/kenzok8/r8168
rm -rf feeds/kiddin/MentoHUST-OpenWrt-ipk
# rm -rf feeds/luci/applications/luci-app-dockerman
# rm -rf feeds/other/luci-app-dockerman
# rm -rf feeds/kiddin/luci-app-dockerman
# rm -rf feeds/liuran/luci-app-dockerman
# rm -rf package/lede/luci-app-dockerman
rm -rf feeds/liuran/adguardhome
rm -rf feeds/liuran/GoQuiet
rm -rf feeds/liuran/gost
rm -rf feeds/kenzok8/3proxy/patches
rm -rf feeds/kenzok8/shortcut-fe
rm -rf feeds/NueXini/luci-app-gost
rm -rf feeds/NueXini/gost
rm -rf feeds/NueXini/qBittorrent
rm -rf feeds/NueXini/qBittorrent-static
rm -rf feeds/xuanranran/other/lean/qBittorrent
rm -rf feeds/xuanranran/other/lean/qBittorrent-static
rm -rf feeds/xuanranran/other/lean/qtbase
rm -rf feeds/xuanranran/other/lean/qttools
rm -rf feeds/xuanranran/other/lean/rblibtorrent
rm -rf feeds/NueXini/qtbase
rm -rf feeds/NueXini/qttools
rm -rf feeds/NueXini/rblibtorrent
rm -rf feeds/nikki
rm -rf feeds/kenzok8/mihomo
rm -rf feeds/kenzok8/luci-app-mihomo
rm -rf feeds/small/mihomo
rm -rf feeds/kenzo/mihomo
rm -rf feeds/xuanranran/mihomo
rm -rf feeds/haiibo/mihomo
rm -rf feeds/liuran/mihomo
# feeds/nikki completely removed; feeds/packages/net/nikki is the sole nikki provider
# ============================================================
# nikki sed 块已删除，不再需要：
# feeds/small/nikki 上游已是纯 config wrapper（无 Go 编译、
# 无 PROVIDES mihomo、DEPENDS 已含 +mihomo），与 lede 005 的目标一致。
# 旧 sed 块实际只会重复添加 +mihomo 并加一个无引用的 symlink。
# Immortalwrt 不需要 005 patch（仅 lede 的 feeds/packages/net/nikki 需要）。
# ============================================================
# ============================================================
# clashoo 修复已转为 quilt 树级 patch：
#   Immortalwrt/patches/006-clashoo-use-nikki-mihomo.patch
# 由 workflow 在 diy-part3.sh 之后统一 `patch -p1 --forward` 打上，
# 此处不再做 sed。
# ============================================================

# ============================================================
# Fix Go packages that force CGO_ENABLED=0 (v2dat and feed clones of it).
# The golang feed always passes "-linkmode external" in GO_PKG_DEFAULT_LDFLAGS,
# and Go rejects that combination with:
#   "-linkmode requires external (cgo) linking, but cgo is not enabled"
# Deleting the per-package override makes them inherit CGO_ENABLED=1 from the
# feed, the same way every other Go package here is built.
#
# DO NOT patch golang-package.mk: GO_PKG_TARGET_VARS is a multi-line list that
# is expanded into a shell command line, so rewriting the CGO_ENABLED line there
# (especially with ':=') injects make syntax into bash and breaks *every* Go
# package with "CGO_ENABLED: command not found".
# ============================================================
echo "=== Removing CGO_ENABLED=0 overrides from feed Go packages ==="
for cgoff in $(grep -rl 'filter-out CGO_ENABLED=%' feeds --include=Makefile 2>/dev/null); do
  if grep -q 'GO_PKG_DEFAULT_LDFLAGS' "$cgoff"; then
    echo "  -> skipped, already uses the internal linker: $cgoff"
    continue
  fi
  sed -i '/filter-out CGO_ENABLED=%/d' "$cgoff"
  echo "  -> dropped CGO_ENABLED=0 override: $cgoff"
done
echo "=== Go cgo fix done ==="

# ./scripts/feeds update -a
# ./scripts/feeds install -p kenzok8 luci-app-transmission
# ./scripts/feeds install -p kenzok8 transmission
# ./scripts/feeds install -p kenzok8 transmission-web-control
# ./scripts/feeds install -p kenzok8 smartdns
# ./scripts/feeds install -p kenzok8 luci-app-smartdns
# ./scripts/feeds install -p Joecaicai luci-app-qbittorrent
# ./scripts/feeds install -p Joecaicai qBittorrent-Enhanced-Edition
# ./scripts/feeds install -a

# ============================================================
# fchomo / netspeedtest 修复同样走 quilt patches（与 lede 同内容）：
#   Immortalwrt/patches/007-fchomo-drop-postinst-version-check.patch
#   Immortalwrt/patches/008-netspeedtest-use-setuptools.patch
# 由 workflow 统一打上，此处不再做 sed。
# ============================================================
echo "=== Ensuring python3-setuptools selected in .config ==="
if [ -f .config ]; then
  # python3-pkg-resources 在 pinned immortalwrt/packages 里不存在，
  # 008 已把 netspeedtest 依赖换成 setuptools，这里同步 .config
  sed -i '/^CONFIG_PACKAGE_python3-pkg-resources=y$/d' .config
  sed -i '/# CONFIG_PACKAGE_python3-setuptools is not set/d' .config
  sed -i '/^CONFIG_PACKAGE_python3-setuptools=y$/d' .config
  printf 'CONFIG_PACKAGE_python3-setuptools=y\n' >> .config
  echo "  -> selected python3-setuptools, dropped stale pkg-resources"
  make defconfig
  echo "  -> make defconfig done"
else
  echo "  WARNING: .config not found"
fi
echo "=== .config fix done ===" 
