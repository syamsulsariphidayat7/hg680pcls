# ADR 0001 — Dashboard pakai Lua template kustom + tombol native, bukan CBI map/section

- **Status:** Diterima (berlaku sejak v1.2.0)
- **Tanggal:** 2026-10-18
- **Konteks proyek:** HG680PCLS (add-on LuCI, OpenWrt 24.10.x)

## Konteks

Dashboard perlu: kartu mode LED dengan preview animasi, chip target ping dengan status inline
yang dimuat/di-*refresh* via JS, pill status koneksi, dan tombol Update yang memanggil endpoint
kustom. LuCI menyediakan dua cara umum:

1. **CBI** (model + section/option + widget bawaan) — dapat form, validasi, dan tombol
   simpan/apply otomatis, tapi tampilan mengikuti komponen CBI (sulit dikustomisasi).
2. **Lua template kustom** (`luci.view.render` dari `view/*.htm`) + endpoint JSON sendiri —
   kontrol penuh atas HTML/CSS/JS, tapi simpan/validasi harus diurus sendiri.

Catatan penting: pada OpenWrt 24.10, LuCI core memakai **ucode**, sementara controller/view Lua
dijalankan lewat paket `luci-lua-runtime`. Render halaman LuCI juga **tidak bisa diuji dari host
dev** (hanya di STB). Jadi opsi yang bergantung pada CBI template kustom + `luci-compat`
berisiko lebih tinggi untuk diuji secara lokal.

## Keputusan

Pakai **Lua template kustom** (`usr/lib/lua/luci/view/hg680pcls/dashboard.htm`) dengan CSS/JS
inline, plus endpoint JSON sendiri (`/status`, `/save`, `/check`, `/update`). Tombol simpan memakai
class native LuCI (`cbi-button cbi-button-apply`) supaya tetap konsisten dengan halaman lain.

## Konsekuensi

**Positif**
- Kontrol penuh tampilan: layout 2 baris, chip target, pill status, animasi preview LED, light theme.
- Tidak bergantung `luci-compat` untuk CBI template kustom → jejak dependensi lebih kecil.
- Status/latensi bisa di-*poll* via JS tanpa reload halaman.

**Negatif / risiko yang diterima**
- Validasi & keamanan harus ditulis sendiri → wajib `post(...)` + `require_post()` (token CSRF)
  dan `valid_targets()` untuk `ping_targets`. Ini sudah diterapkan di v1.2.3.
- Perubahan pada `dashboard.htm` **wajib divalidasi manual**: blok `<script>` diekstrak lalu
  `node --check`, dan seluruh halaman harus diuji di STB (lihat `AGENTS.md` → Testing).
- Bila API internal LuCI berubah antar rilis, template/route bisa perlu penyesuaian.

## Alternatif yang ditolak
- **CBI map/section penuh** — tampilan tidak bisa dibuat seperti desain yang diminta (kartu,
  preview animasi, chip) tanpa banyak template override yang justru rapuh.
- **CBI + template override `view/cbi/…`** — butuh `luci-compat`, sulit diuji dari host dev.
