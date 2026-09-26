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
rm -rf feeds/luci2/luci-app-turboacc
./scripts/feeds install -p packages2 quickstart
./scripts/feeds install -p packages2 luci-app-quickstart
rm -rf feeds/packages/net/{qBittorrent,qBittorrent-static,xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls,haproxy}
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
rm -rf feeds/NueXini/qtbase
rm -rf feeds/NueXini/qttools
rm -rf feeds/NueXini/rblibtorrent

# ============================================================
# Remove duplicate mihomo packages from other feeds
# Keep feeds/packages/net/mihomo as the sole mihomo provider
# ============================================================

rm -rf feeds/kenzok8/mihomo
rm -rf feeds/kenzok8/luci-app-mihomo
rm -rf feeds/small/mihomo
rm -rf feeds/kenzo/mihomo
rm -rf feeds/xuanranran/mihomo
rm -rf feeds/haiibo/mihomo
rm -rf feeds/liuran/mihomo
# All mihomo packages removed; feeds/packages/net/mihomo is the sole provider

# ============================================================
# 以下修复已转为 quilt 树级 patches，见 lede/patches/：
#   005-nikki-depend-on-feed-mihomo.patch        (原 nikki sed 块)
#   006-clashoo-use-nikki-mihomo.patch           (原 clashoo sed 循环)
#   007-fchomo-drop-postinst-version-check.patch (原 fchomo Method 3)
# 由 workflow 在 diy-part3.sh 之后统一 `patch -p1 --forward` 打上，
# 此处不再做 sed（重复施加会导致 patch 失败）。
# kmod-ixgbe 的 +kmod-libie sed 已删除：当前 lede master 的
# netdevices.mk 已改为条件依赖 (+LINUX_6_12:kmod-libie …)，
# 旧 pattern 匹配不上，且 .config 已选中 kmod-libie，无需再改。
# 生成方式：quilt new -> quilt add -> 改文件 -> quilt refresh。
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

# ============================================================
# netspeedtest 的 python3-pkg-resources -> python3-setuptools 替换
# 已转为 lede/patches/008-netspeedtest-use-setuptools.patch，
# 由 workflow 统一打上，此处不再做 sed。
# （仅 sirpdboy/netspeedtest 这一份需要改，其它 feeds 已干净。）
# ============================================================

# ============================================================
# Fix luci-app-ssr-plus: 保留 bind-dig，禁止替换成 bind
# kenzok8/small、kenzok8/jell 的 luci-app-ssr-plus 依赖 +bind-dig，
# 它是 feeds/packages/net/bind 真实提供的子包
# （bind-libs/bind-server/bind-client/bind-tools/bind-dig/...）。
# 而裸 `bind` 包根本不存在，之前全局 s/bind-dig/bind/g 不仅修不好，
# 还会把 bind 自身 Makefile 里的 define Package/bind-dig 破坏掉，
# 把提供者都删掉。这里只做校验，不做任何替换。
# 缺失的 ipk 靠下面 .config 选中 CONFIG_PACKAGE_bind-dig 来编译。
# ============================================================
echo "=== Checking ssr-plus bind-dig dependency (keep as-is) ==="
grep -rl "bind-dig" feeds package --include=Makefile 2>/dev/null | head -20 | while read -r f; do echo "  keep bind-dig in: $f"; done
echo "=== ssr-plus check done ==="

# ============================================================
# 确保依赖在 .config 中被选中，然后 make defconfig 使其生效
# netspeedtest 需要: python3-setuptools（替代已移除的 pkg-resources）
# ssr-plus 需要: bind-dig + bind-libs（+liburcu 已有）
# 注意: 裸 `bind` 包不存在，禁止选中 CONFIG_PACKAGE_bind；
# python3-light 真实存在，禁止全局 s/+python3-light/+python3/g。
# diy-part3 运行在 ./scripts/feeds install -a 之后，改完 Makefile/.config
# 必须 make defconfig，否则 tmp/.packageinfo 还是旧的，install 必 fail。
# ============================================================
echo "=== Ensuring dependencies are selected in .config ==="
if [ -f .config ]; then
  # 清掉之前误加的无效项（裸 bind 包不存在）
  sed -i '/^CONFIG_PACKAGE_bind=y$/d' .config
  sed -i '/^CONFIG_OVERRIDE_PKGS=/d' .config
  # 删除旧行避免重复（同时匹配 "=y" 和 "is not set" 行）
  for sym in bind-dig bind-libs python3-setuptools python3 python3-light liburcu; do
    sed -i "/CONFIG_PACKAGE_${sym}[ =]/d" .config
  done
  printf 'CONFIG_PACKAGE_bind-dig=y\n' >> .config
  printf 'CONFIG_PACKAGE_bind-libs=y\n' >> .config
  printf 'CONFIG_PACKAGE_liburcu=y\n' >> .config
  printf 'CONFIG_PACKAGE_python3=y\n' >> .config
  printf 'CONFIG_PACKAGE_python3-light=y\n' >> .config
  printf 'CONFIG_PACKAGE_python3-setuptools=y\n' >> .config
  echo "  -> selected bind-dig, bind-libs, liburcu, python3, python3-light, python3-setuptools"
  # 刷新 defconfig，让新增选中项展开到依赖关系中
  make defconfig
  echo "  -> make defconfig done"
else
  echo "  WARNING: .config not found"
fi
echo "=== .config fix done ==="

# ============================================================
# Verify required packages are selected in .config
# ============================================================
echo "=== Verifying .config packages ==="
if [ -f .config ]; then
  grep -q "CONFIG_PACKAGE_python3-setuptools=y" .config && echo "  -> python3-setuptools selected" || echo "  -> WARNING: python3-setuptools not selected"
  grep -q "CONFIG_PACKAGE_bind-dig=y" .config && echo "  -> bind-dig selected" || echo "  -> WARNING: bind-dig not selected"
  grep -q "CONFIG_PACKAGE_bind-libs=y" .config && echo "  -> bind-libs selected" || echo "  -> WARNING: bind-libs not selected"
  grep -q "CONFIG_PACKAGE_python3-light=y" .config && echo "  -> python3-light selected" || echo "  -> WARNING: python3-light not selected"
else
  echo "  WARNING: .config not found"
fi
echo "=== verification done ==="
