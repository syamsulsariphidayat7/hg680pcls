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

Halaman pengaturan berbentuk **form native LuCI** (tombol **Save & Apply**, mengikuti tema aktif):
- 🟢 **Status koneksi** — ONLINE/OFFLINE + latensi per target (read-only, dihitung saat halaman dibuka)
- 💡 **Mode LED** (Power & LAN) — pilihan Offline / Online / Heart / Disko, dengan preview animasi pola
- 🎯 **Ping target** — input multi target, dipisah spasi
- ⏱️ **Interval cek** — 1–60 detik
- 💾 **Save & Apply** — menyimpan ke `/etc/config/hg680pcls` lalu otomatis me-restart service

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
