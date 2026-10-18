# 🧩 HG680PCLS
Custom LuCI Script & Service untuk STB HG680P berbasis OpenWrt.

![Platform](https://img.shields.io/badge/platform-OpenWrt-green)
![Device](https://img.shields.io/badge/device-HG680P-blue)

---

## 🧠 Deskripsi
`HG680PCLS` adalah skrip tambahan yang:
- Menambahkan halaman baru di **LuCI → Services → HG680PCLS**
- Memungkinkan pengelolaan LED untuk STB HG680P
- Pastikan STB kamu sudah menjalankan **OpenWrt**, dan sudah ada `curl` di dalamnya.

---

### 💻 1️⃣ Install
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/install.sh)"
```

Installer otomatis memakai **tag rilis terbaru** (`v<versi>`), bukan branch `main`.
Mau pin atau rollback ke versi tertentu:
```bash
HG680PCLS_REF=v1.2.2 sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/install.sh)"
```

---

## 🧹 Uninstall
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/uninstall.sh)"
```
---

## 🧩 Menu LuCI
Setelah instalasi, buka:
> **LuCI → Services → HG680PCLS**

Dashboard berisi:
- 🟢 **Status koneksi** — cukup di **pill pojok kanan atas** (ONLINE/OFFLINE, auto-refresh tiap 5 detik)
- 💡 **Mode LED** (Power & LAN) — kartu visual dengan preview animasi pola kedip (Offline / Online / Heart / Disko)
- 🎯 **Ping target** — input multi target; tiap host tampil sebagai chip dengan **status inline** (dot + latensi, live). Klik chip untuk hapus.
- ⏱️ **Interval cek** — slider 1–60 detik dengan tanda skala **5, 10, 15, … 60** (angkanya bisa diklik untuk lompat ke nilai itu)
- 🔄 **Update** (baris sendiri) — tombol **Cek Update**; kalau ada versi baru, tombol **Install Update** muncul beserta **catatan rilis**, plus **Pasang ulang** (memasang kembali rilis terbaru untuk perbaikan) dan tombol **Repo GitHub** (setelan dipertahankan)
- 💾 **Simpan & Restart Service** — tombol bergaya LuCI, langsung apply ke `/etc/config/hg680pcls` dan restart service

Jika belum muncul LOGOUT dulu atau:
```bash
/etc/init.d/uhttpd restart
```
## 🚀 Ping target sesuaikan bisa IP atau Host (support multi)

Contoh : graph.instagram.com 8.8.8.8 1.1.1.1

Batas: **maksimal 8 target**, dipisah spasi. Karakter yang diizinkan hanya huruf/angka, titik,
strip, garis bawah, dan titik dua (nama host atau IP). Target yang tidak valid ditolak saat simpan.

---

## 🔐 Keamanan & versi

- Endpoint **Simpan** dan **Update** wajib **POST + token CSRF** sesi LuCI (dua lapis: dispatcher
  LuCI dan pemeriksaan di dalam action).
- **Update** menjalankan installer resmi GitHub sebagai `root` — hanya bisa dipicu dari sesi admin
  LuCI yang login.
- Versi terpasang terlihat di kartu Update. Rilis ditandai **tag `v<versi>`** di GitHub dan installer
  menarik dari tag itu (bukan `main`), jadi pemasangan selalu pada keadaan yang sudah ditandai rilis.

---

## 📚 Dokumen

- [Catatan rilis / riwayat versi](CHANGELOG.md)
- [Kontrak API](docs/api.md)
- [Keputusan arsitektur (ADR)](docs/adr/0001-lua-template-bukan-cbi.md)
- [Aturan pengembangan proyek](AGENTS.md) &middot; [Progres](PROGRESS.md)

---

## ⚖️ Lisensi
MIT — Crashoverride © 2025-2026 [Syamsul Sarip Hidayat](https://github.com/syamsulsariphidayat7)
(lihat [`LICENSE`](LICENSE))

---

> 💡 **Catatan:**
> Tested Fw 24.10.x
> Semua file `.lua`, `.config`, dan skrip shell dapat kamu modifikasi sesuai kebutuhan sistem kamu.
