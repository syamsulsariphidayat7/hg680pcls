#!/bin/sh
# ==========================================
#  HG680P LuCI Script Installer
#  by Syamsul Sarip Hidayat
# ==========================================

echo "[HG680PCLS] Starting installation..."

TARGET_DIRS="
/etc/config
/etc/init.d
/usr/bin
/usr/lib/lua/luci/controller
/usr/lib/lua/luci/model/cbi
"

for dir in $TARGET_DIRS; do
    mkdir -p "$dir"
done

cp -f etc/config/hg680pcls /etc/config/
cp -f etc/init.d/hg680pcls /etc/init.d/
cp -f usr/bin/hg680pcl /usr/bin/
cp -f usr/lib/lua/luci/controller/hg680pcls.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/model/cbi/hg680pcls.lua /usr/lib/lua/luci/model/cbi/

chmod 755 /etc/init.d/hg680pcls /usr/bin/hg680pcl
chmod 644 /etc/config/hg680pcls
chmod 644 /usr/lib/lua/luci/controller/hg680pcls.lua /usr/lib/lua/luci/model/cbi/hg680pcls.lua

/etc/init.d/hg680pcls enable 2>/dev/null
/etc/init.d/hg680pcls restart 2>/dev/null

echo "[HG680PCLS] Installation complete!"
echo "[HG680PCLS] Access via LuCI: Services → HG680PCLS"
