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
- 🟢 **Status koneksi internet** — pill **Internet ONLINE/OFFLINE** di kartu **Service** (auto-refresh tiap 5 detik)
- 💡 **Mode LED Power & LAN** — kartu visual dengan preview animasi pola kedip (Offline / Online / Heart / Disko)
- 🔵 **LED USB** (pin default `518`) — LED indikator USB (di sebagian unit justru dipakai untuk mengendalikan kipas USB), tidak ikut status koneksi. Mode: **Mati**, **Nyala**, **Detak** (heartbeat, default), **Disko**.
- 🎯 **Ping target** — input multi target; tiap host tampil sebagai chip dengan **status inline** (dot + latensi, live). Klik chip untuk hapus.
- ⏱️ **Interval cek** — slider 1–60 detik dengan tanda skala **5, 10, 15, … 60** (angkanya bisa diklik untuk lompat ke nilai itu)
- 🔌 **Service** (baris kedua) — status service + tombol **Aktifkan / Nonaktifkan**: nonaktif berarti ping & semua LED berhenti dan tidak otomatis jalan saat STB dinyalakan (setelan tetap tersimpan)
- 🔄 **Update** (baris kedua) — tombol **Cek Update**; kalau ada versi baru, tombol **Install Update** muncul beserta **catatan rilis**, plus **Pasang ulang** (memasang kembali rilis terbaru untuk perbaikan) dan tombol **Repo GitHub** (setelan dipertahankan)
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

## 🔧 Nomor pin GPIO (opsional)

Default sudah cocok untuk HG680P "2GB" (pin power 521/517, LAN 547/548, LED USB 518).
Kalau board revisimu beda, override lewat UCI tanpa perlu edit skrip:

```bash
uci set hg680pcls.settings.power_pin_on='521'
uci set hg680pcls.settings.power_pin_off='517'
uci set hg680pcls.settings.lan_pin_on='547'
uci set hg680pcls.settings.lan_pin_off='548'
uci set hg680pcls.settings.status_pin='518'
uci commit hg680pcls && /etc/init.d/hg680pcls restart
```

Cara memastikan sebuah pin memang LED (dan bukan penerima IR atau tombol reset USB) — contoh dengan
pin 518, yang di unit HG680P kami terdeteksi sebagai **LED indikator USB** (di sebagian unit, pin ini
dipakai orang untuk mengendalikan kipas USB; pilih mode **Nyala**/**Mati**, pola **Detak**/**Disko**
tidak cocok untuk kipas):

```bash
echo 518 > /sys/class/gpio/export
echo out > /sys/class/gpio/gpio518/direction
while true; do echo 1 > /sys/class/gpio/gpio518/value; sleep 0.3
              echo 0 > /sys/class/gpio/gpio518/value; sleep 0.3; done
# amati: LED mana yang berkedip? remote masih jalan? perangkat USB tidak terputus?
# Ctrl+C lalu: echo 518 > /sys/class/gpio/unexport
```

Referensi pin komunitas (proyek `luci-app-gpioled`): HG680P R1GB = power 483/484, IR 480,
ethernet 481/482; HG680P R2GB = power 425/426, IR 507, ethernet 506/510.

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
- [Catatan diagnosa (troubleshooting)](docs/troubleshooting.md)
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
