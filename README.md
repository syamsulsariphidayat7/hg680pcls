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

Jika belum muncul LOGOUT dulu atau:
```bash
/etc/init.d/uhttpd restart
```
## 🚀 Ping target sesuaikan bisa IP atau Host (support multi)

Contoh : 8.8.8.8 1.1.1.1 ava.game.naver.com

---

## ⚖️ Lisensi
Crashoverride © 2025 [Syamsul Sarip Hidayat](https://github.com/syamsulsariphidayat7)

---

> 💡 **Catatan:**
> Tested Fw 24.10.x
> Semua file `.lua`, `.config`, dan skrip shell dapat kamu modifikasi sesuai kebutuhan sistem kamu.
