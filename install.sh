#!/bin/sh
# ==========================================
#  HG680P LuCI Script Installer (Public)
#  by Syamsul Sarip Hidayat
# ==========================================

SLUG="syamsulsariphidayat7/hg680pcls"
RAW="https://raw.githubusercontent.com/$SLUG"
API="https://api.github.com/repos/$SLUG"

if ! command -v curl >/dev/null 2>&1; then
    echo "✖ curl tidak ditemukan. Jalankan dulu: opkg update && opkg install curl"
    exit 1
fi

# Tentukan ref rilis = tag v<versi> tertinggi (rilis selalu berbasis tag, bukan
# branch main yang bisa setengah jadi). Bisa dipaksa manual untuk pin/rollback:
#   HG680PCLS_REF=v1.2.2 sh -c "$(curl -fsSL .../main/install.sh)"
REF="${HG680PCLS_REF:-}"
if [ -z "$REF" ]; then
    ver=$(curl -fsSL --connect-timeout 8 --max-time 15 "$API/tags?per_page=100" 2>/dev/null \
        | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"v\([0-9][0-9.]*\)".*/\1/p' \
        | sort -t. -k1,1n -k2,2n -k3,3n | tail -n1)
    [ -n "$ver" ] && REF="v$ver"
fi
if [ -z "$REF" ]; then
    REF="main"
    echo "[HG680PCLS] ⚠ Tidak menemukan tag rilis di GitHub, memakai branch main"
fi

REPO="$RAW/$REF"
echo "[HG680PCLS] Ref dipakai: $REF"

echo "[HG680PCLS] Downloading and installing..."
TMP_DIR="/tmp/hg680pcls"
mkdir -p "$TMP_DIR" && cd "$TMP_DIR" || exit 1

FILES="
VERSION
etc/config/hg680pcls
etc/init.d/hg680pcls
usr/bin/hg680pcl
usr/lib/lua/luci/controller/hg680pcls.lua
usr/lib/lua/luci/view/hg680pcls/dashboard.htm
"

# Download semua file dari repo GitHub
for f in $FILES; do
    mkdir -p "$(dirname "$f")"
    echo "→ Downloading $f"
    curl -fsSL "$REPO/$f" -o "$f" || { echo "✖ Gagal download $f"; exit 1; }
done

# Bersihkan sisa CBI dari versi sebelumnya (kini pakai template view)
rm -f /usr/lib/lua/luci/model/cbi/hg680pcls.lua

# Copy ke sistem
echo "[HG680PCLS] Installing files..."
mkdir -p /usr/lib/lua/luci/view/hg680pcls

# Simpan keadaan service SEBELUM ditimpa, supaya pilihan user dihormati:
# - fresh install (belum ada init script) -> selalu aktif
# - reinstall/upgrade saat service sengaja dinonaktifkan -> tetap nonaktif
SVC_FRESH=1
[ -f /etc/init.d/hg680pcls ] && SVC_FRESH=0
SVC_WAS_ENABLED=0
ls /etc/rc.d/*hg680pcls >/dev/null 2>&1 && SVC_WAS_ENABLED=1

# Simpan config lama agar setelan user tidak hilang saat upgrade
if [ -f /etc/config/hg680pcls ]; then
    cp -f /etc/config/hg680pcls /etc/config/hg680pcls.bak
    echo "[HG680PCLS] Config lama dibackup ke /etc/config/hg680pcls.bak"
fi

cp -f etc/init.d/hg680pcls /etc/init.d/
cp -f usr/bin/hg680pcl /usr/bin/
cp -f usr/lib/lua/luci/controller/hg680pcls.lua /usr/lib/lua/luci/controller/
cp -f usr/lib/lua/luci/view/hg680pcls/dashboard.htm /usr/lib/lua/luci/view/hg680pcls/
cp -f VERSION /usr/lib/lua/luci/view/hg680pcls/VERSION

# Hanya pasang config default bila belum ada (jangan timpa setelan user)
if [ -f /etc/config/hg680pcls ]; then
    echo "[HG680PCLS] Mempertahankan config yang sudah ada"
else
    cp -f etc/config/hg680pcls /etc/config/
fi

# Set permission
chmod 755 /etc/init.d/hg680pcls /usr/bin/hg680pcl
chmod 644 /etc/config/hg680pcls
chmod 644 /usr/lib/lua/luci/controller/hg680pcls.lua
chmod 644 /usr/lib/lua/luci/view/hg680pcls/dashboard.htm
chmod 644 /usr/lib/lua/luci/view/hg680pcls/VERSION

# Clean-slate: matikan service & sisa proses LED supaya tidak "bertumpuk" saat reinstall
/etc/init.d/hg680pcls stop 2>/dev/null
[ -x /usr/bin/hg680pcl ] && /usr/bin/hg680pcl reset 2>/dev/null
rm -rf /tmp/hg680p_led

# Bersihkan cache menu LuCI agar perubahan langsung terlihat
rm -f /tmp/luci-indexcache /tmp/luci-indexcache.* 2>/dev/null

# Enable dan mulai service — kecuali user memang menonaktifkannya sebelumnya
if [ "$SVC_FRESH" -eq 1 ] || [ "$SVC_WAS_ENABLED" -eq 1 ]; then
    /etc/init.d/hg680pcls enable 2>/dev/null
    /etc/init.d/hg680pcls start 2>/dev/null
else
    /etc/init.d/hg680pcls disable 2>/dev/null
    echo "[HG680PCLS] Service tetap NONAKTIF (sesuai setelan sebelumnya) — aktifkan dari dashboard bila perlu."
fi

# Bersihkan
cd /tmp
rm -rf "$TMP_DIR"

echo ""
echo "[HG680PCLS] ✅ Installation complete! (ref: $REF)"
echo "[HG680PCLS] Access via LuCI → Services → HG680PCLS"
echo ""
