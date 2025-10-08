#!/bin/sh
# ==========================================
#  HG680P LuCI Script Installer (Public)
#  by Syamsul Sarip Hidayat
# ==========================================

REPO="https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main"

echo "[HG680PCLS] Downloading and installing..."
TMP_DIR="/tmp/hg680pcls"
mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 1

FILES="
etc/config/hg680pcls
etc/init.d/hg680pcls
usr/bin/hg680pcl
usr/lib/lua/luci/controller/hg680pcls.lua
usr/lib/lua/luci/model/cbi/hg680pcls.lua
"

# Download semua file dari repo GitHub
for f in $FILES; do
    mkdir -p "$(dirname "$f")"
    echo "→ Downloading $f"
    curl -fsSL "$REPO/$f" -o "$f" || { echo "✖ Gagal download $f"; exit 1; }
done

# Copy ke sistem
echo "[HG680PCLS] Installing files..."
cp -f etc/config/hg680pcls /etc/config/
cp -f etc/init.d/hg680pcls /etc/init.d/
cp -f usr/bin/hg680pcl /usr/bin/
cp -f usr/lib/lua/luci/controller/hg680pcls.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/model/cbi/hg680pcls.lua /usr/lib/lua/luci/model/cbi/

# Set permission
chmod 755 /etc/init.d/hg680pcls /usr/bin/hg680pcl
chmod 644 /etc/config/hg680pcls
chmod 644 /usr/lib/lua/luci/controller/hg680pcls.lua /usr/lib/lua/luci/model/cbi/hg680pcls.lua

# Enable dan mulai service
/etc/init.d/hg680pcls enable 2>/dev/null
/etc/init.d/hg680pcls restart 2>/dev/null

# Bersihkan
cd /tmp
rm -rf "$TMP_DIR"

echo ""
echo "[HG680PCLS] ✅ Installation complete!"
echo "[HG680PCLS] Access via LuCI → Services → HG680PCLS"
echo ""
