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

---

## 🧹 Uninstall
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/uninstall.sh)"
```
---

## 🧩 Menu LuCI
Setelah instalasi, buka:
> **LuCI → Services → HG680PCLS**

Dashboard modern berisi:
- 🟢 **Status koneksi** — ONLINE/OFFLINE + latensi per target (auto-refresh tiap 5 detik)
- 💡 **Mode LED** (Power & LAN) — kartu visual dengan preview animasi pola kedip (Offline / Online / Heart / Disko)
- 🎯 **Ping target** — input multi target; tiap host tampil sebagai chip dengan **status inline** (dot + latensi, live). Klik chip untuk hapus.
- ⏱️ **Interval cek** — slider 1–60 detik
- 🔄 **Update dari GitHub** — cek versi terpasang vs terbaru, tombol update langsung dari dashboard (setelan dipertahankan)
- 💾 **Simpan & Restart Service** — tombol bergaya LuCI, langsung apply ke `/etc/config/hg680pcls` dan restart service

Jika belum muncul LOGOUT dulu atau:
```bash
/etc/init.d/uhttpd restart
```
## 🚀 Ping target sesuaikan bisa IP atau Host (support multi)

Contoh : graph.instagram.com 8.8.8.8 1.1.1.1

---

## ⚖️ Lisensi
Crashoverride © 2025 [Syamsul Sarip Hidayat](https://github.com/syamsulsariphidayat7)

---

> 💡 **Catatan:**
> Tested Fw 24.10.x
> Semua file `.lua`, `.config`, dan skrip shell dapat kamu modifikasi sesuai kebutuhan sistem kamu.
