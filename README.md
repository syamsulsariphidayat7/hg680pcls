# 🧩 HG680PCLS
Custom LuCI Script & Service untuk STB HG680P berbasis OpenWrt.

![Platform](https://img.shields.io/badge/platform-OpenWrt-green)
![Device](https://img.shields.io/badge/device-HG680P-blue)
![License](https://img.shields.io/badge/license-MIT-lightgrey)

---

## 🧠 Deskripsi
`HG680PCLS` adalah skrip tambahan yang:
- Menambahkan halaman baru di **LuCI → Services → HG680PCLS**
- Memungkinkan pengelolaan layanan / konfigurasi custom untuk STB HG680P
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

Jika belum muncul logout dulu atau:
```bash
/etc/init.d/uhttpd restart
```
## 🚀 Ping target sesuaikan bisa IP atau Host (support multi)
contoh : 8.8.8.8 1.1.1.1 ava.game.naver.com
---

## ⚖️ Lisensi
Crashoverride © 2025 [Syamsul Sarip Hidayat](https://github.com/syamsulsariphidayat7)

---

> 💡 **Catatan:**  
> Semua file `.lua`, `.config`, dan skrip shell dapat kamu modifikasi sesuai kebutuhan sistem kamu.
