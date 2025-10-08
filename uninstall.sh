#!/bin/sh
# ==========================================
#  HG680P LuCI Script Uninstaller
# ==========================================

echo "[HG680PCLS] Removing installation..."

# Hentikan service
/etc/init.d/hg680pcls stop 2>/dev/null
/etc/init.d/hg680pcls disable 2>/dev/null

# Hapus semua file
rm -f /etc/config/hg680pcls
rm -f /etc/init.d/hg680pcls
rm -f /usr/bin/hg680pcl
rm -f /usr/lib/lua/luci/controller/hg680pcls.lua
rm -f /usr/lib/lua/luci/model/cbi/hg680pcls.lua

echo "[HG680PCLS] ✅ Uninstallation complete!"
