#!/bin/sh
# ==========================================
#  HG680P LuCI Script Uninstaller
# ==========================================

echo "[HG680PCLS] Removing installation..."

# Hentikan service, lalu paksa reset pin GPIO supaya LED tidak nyangkut nyala
/etc/init.d/hg680pcls stop 2>/dev/null
/etc/init.d/hg680pcls disable 2>/dev/null
[ -x /usr/bin/hg680pcl ] && /usr/bin/hg680pcl reset 2>/dev/null

# Hapus semua file
rm -f /etc/config/hg680pcls
rm -f /etc/init.d/hg680pcls
rm -f /usr/bin/hg680pcl
rm -f /usr/lib/lua/luci/controller/hg680pcls.lua
rm -f /usr/lib/lua/luci/model/cbi/hg680pcls.lua
# Sisa halaman UI lama (template) dari versi sebelumnya
rm -rf /usr/lib/lua/luci/view/hg680pcls

# Bersihkan sisa runtime
rm -rf /tmp/hg680p_led

# Catatan: backup config (/etc/config/hg680pcls.bak) sengaja tidak dihapus
if [ -f /etc/config/hg680pcls.bak ]; then
    echo "[HG680PCLS] ℹ️  Backup config dibiarkan: /etc/config/hg680pcls.bak"
fi

echo "[HG680PCLS] ✅ Uninstallation complete!"
