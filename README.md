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

---

## 🚀 Instalasi Otomatis

> 📢 Pastikan STB kamu sudah menjalankan **OpenWrt**, dan sudah ada `git` serta `bash` di dalamnya.

### 💻 1️⃣ Instal langsung (via `curl`)
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/install.sh)"
```

---

### 🧰 2️⃣ Instal manual (via `git clone`)
```bash
git clone https://github.com/syamsulsariphidayat7/hg680pcls.git
cd hg680pcls
chmod +x install.sh
./install.sh
```

---

## 🧹 Uninstall
```bash
cd /root/hg680pcls
chmod +x uninstall.sh
./uninstall.sh
```

---

## 📂 Struktur Folder
```
hg680pcls/
├── install.sh
├── uninstall.sh
├── etc/
│   ├── config/
│   │   └── hg680pcls
│   └── init.d/
│       └── hg680pcls
├── usr/
│   ├── bin/
│   │   └── hg680pcl
│   └── lib/
│       └── lua/
│           └── luci/
│               ├── controller/
│               │   └── hg680pcls.lua
│               └── model/
│                   └── cbi/
│                       └── hg680pcls.lua
```

---

## 🧩 Menu LuCI
Setelah instalasi, buka:
> **LuCI → Services → HG680PCLS**

Jika belum muncul:
```bash
/etc/init.d/uhttpd restart
```

---

## ⚖️ Lisensi
Crashoverride © 2025 [Syamsul Sarip Hidayat](https://github.com/syamsulsariphidayat7)

---

> 💡 **Catatan:**  
> Semua file `.lua`, `.config`, dan skrip shell dapat kamu modifikasi sesuai kebutuhan sistem kamu.
