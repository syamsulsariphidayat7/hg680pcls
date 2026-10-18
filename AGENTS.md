# AGENTS.md — HG680PCLS

Instruksi proyek. Melengkapi `~/.config/opencode/AGENTS.global.md` (aturan global tetap berlaku).

## Apa ini
Add-on LuCI untuk STB **HG680P** (OpenWrt, arsitektur ARM): mengontrol **LED Power & LED LAN**
langsung dari GPIO `/sys/class/gpio`, plus memantau konektivitas internet via `ping`.
Halaman dashboard kustom di **LuCI → Services → HG680PCLS**.

- Repo: https://github.com/syamsulsariphidayat7/hg680pcls
- Branch kerja: `main` (proyek solo, langsung di main — keputusan dicatat di sini)
- Lisensi: MIT (`LICENSE`)

## Struktur file
```
VERSION                                   # penanda versi, dipasang ke /usr/lib/lua/luci/view/hg680pcls/VERSION
install.sh / uninstall.sh                 # installer & uninstaller (dijalankan di STB sebagai root)
etc/config/hg680pcls                      # default UCI: ping_targets, interval, power_mode, lan_mode
etc/init.d/hg680pcls                      # service procd: loop ping + set mode LED
usr/bin/hg680pcl                          # skrip GPIO LED (mode: offline/online/heart/disko/reset)
usr/lib/lua/luci/controller/hg680pcls.lua # route LuCI + endpoint status/save/check/update
usr/lib/lua/luci/view/hg680pcls/dashboard.htm  # halaman dashboard (CSS inline + JS vanilla)
CHANGELOG.md                              # riwayat rilis (sumber catatan "Cek Update")
docs/api.md, docs/adr/                    # kontrak API & keputusan arsitektur
```

## Stack & versi
- Target: **OpenWrt 24.10.x** (LuCI ucode core + `luci-lua-runtime` untuk controller/view Lua).
- Halaman: **Lua template** (`view/*.htm`) + CSS/JS vanilla inline. Tanpa framework, tanpa build step.
- Service: `procd` (`/etc/init.d/hg680pcls`), shell POSIX (busybox ash).
- Ikon/badge: tidak ada dependensi eksternal; template LuCI (`<%=pcdata(...)%>`) untuk escaping.

## Konvensi kode
- Shell: POSIX `sh`, aman untuk busybox. Hindari `bashism`, `local` di luar fungsi, dan `sort -V` (pakai `-k n`).
- Lua: `module("luci.controller.hg680pcls", package.seeall)`; helper lokal dideklarasikan di atas
  sebelum dipakai; pola `local function x()` yang akan direferensikan dari fungsi lain harus berada di atas.
- Template: semua variabel tampilan lewat `pcdata()`; JS ditulis ES5-ish (tanpa `const`/arrow) agar aman di
  WebView lama; `credentials: "same-origin"` untuk semua fetch.
- Teks UI: Bahasa Indonesia.
- Format/lint: sebelum commit jalankan
  `luac -p usr/lib/lua/luci/controller/hg680pcls.lua`,
  `sh -n install.sh uninstall.sh etc/init.d/hg680pcls usr/bin/hg680pcl`,
  dan cek JS template:
  `awk '/^<script>/{f=1;next} /^<\/script>/{f=0} f' usr/lib/lua/luci/view/hg680pcls/dashboard.htm | sed 's/<%=[^%]*%>/TPL/g' > /tmp/d.js && node --check /tmp/d.js`

## Aturan keamanan (jangan dilanggar)
- Endpoint POST (`save`, `update`) **wajib** lewat `post(...)` di routing + `require_post()` di action.
- `update` menjalankan installer resmi sebagai **root** — jangan tambahkan endpoint semacam ini tanpa cek POST+token.
- Input `ping_targets` **wajib** lewat `valid_targets()` (maks 8, pola hostname/IP) karena nilainya masuk ke
  loop shell di `init.d`.
- Jangan pernah menaruh token/secret di repo.

## Rilis & versi
- Versi ada di `VERSION` (tanpa prefix `v`); tag git memakai prefix `v` (`v1.2.3`).
- **Naikkan `VERSION` setiap rilis** dan tambahkan entri di `CHANGELOG.md` (heading `## x.y.z (tanggal)` —
  dipakai tombol Cek Update untuk menampilkan catatan rilis).
- Installer & tombol Update menarik **tag `v<versi>` tertinggi** dari GitHub API `/tags`
  (fallback `main` bila API gagal). Pin/rollback manual: `HG680PCLS_REF=v1.2.2 sh -c "$(curl ...)"`.
- Urutan rilis: update `VERSION` + `CHANGELOG.md` → commit → `git tag vX.Y.Z` → `git push origin main --tags`.
- **Commit & push hanya setelah izin user.**

## Deploy
- Target: STB OpenWrt (bukan Vercel/VPS). Install lewat `install.sh` (unduh file dari tag rilis).
- Setelah install di STB: logout LuCI atau `/etc/init.d/uhttpd restart` agar menu baru muncul.
- Tidak ada database, tidak ada seed data, tidak ada `.env`.

## Testing
- Tidak ada test otomatis di repo (belum ada CI). Minim, tiap perubahan wajib lolos:
  `luac -p`, `sh -n`, dan `node --check` (lihat bagian Konvensi kode).
- Uji nyata (wajib sebelum rilis): pasang di STB, cek lebar/layout, LED (mode + saat offline),
  tombol Simpan, Cek Update, dan pastikan bar simpan tidak menutupi footer OpenWrt.
- Halaman LuCI tidak bisa dirender dari host dev — pengujian visual dilakukan di STB.

## Catatan lingkungan
- Dev di `/srv/http/hg680pcls` (repo git). Jangan menyentuh proyek lain di `/srv/http`.
- Ingin merender halaman LuCI? Butuh STB; dari host ini tidak mungkin.

## Keputusan yang sudah diambil (ringkas)
- **Lua template + tombol native**, bukan CBI map/section — alasan di `docs/adr/0001-lua-template-bukan-cbi.md`.
- **Bar simpan in-flow** (bukan `position:fixed`/sticky) agar tidak menutupi footer OpenWrt.
- **Light theme saja** (dark mode dihapus atas permintaan user).
- **Background halaman putih** (`#ffffff`); elemen dalam memakai token `--hg-bg: #eef2f6`.
- Rilis berbasis **tag**, bukan branch `main`.
