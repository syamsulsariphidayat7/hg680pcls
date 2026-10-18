# Troubleshooting — HG680PCLS

Catatan diagnosa cepat: konektivitas (ping), service, dan LED.

Semua perintah di STB dijalankan **sebagai root** (`ssh root@<IP-STB>`), kecuali bagian yang
ditandai "dari PC". IP STB = alamat LuCI yang kamu buka di browser (bisa juga `arp -a` dari PC).

---

## 1. Tes konektivitas dari PC

Yang dibuktikan di sini: internet & DNS **di PC** normal, dan STB bisa dijangkau dari PC.

```sh
ping 8.8.8.8                 # IP: tidak butuh DNS
nslookup graph.instagram.com # DNS PC
ping graph.instagram.com     # DNS + ICMP
ping <IP-STB>                # STB hidup & satu jaringan?
```

Windows: sama saja di CMD/PowerShell (`ping 8.8.8.8`, `nslookup graph.instagram.com`).

Kalau `ping <IP-STB>` gagal, masalahnya di jaringan lokal (STB mati / beda subnet / firewall),
bukan di add-on ini.

---

## 2. Tes konektivitas dari dalam STB (inilah yang dipakai service)

Penting: service menjalankan ping **dari STB**, bukan dari PC. Jadi hasil dari PC tidak bisa
dipakai untuk menyimpulkan kondisi STB.

```sh
ping -c 1 -W 2 8.8.8.8              # ICMP ke IP, tanpa DNS
ping -c 1 -W 2 graph.instagram.com  # resolusi nama host + ICMP
nslookup graph.instagram.com        # DNS STB (busybox)
uci show hg680pcls.settings         # target, interval, mode LED, pin
```

Perintah manual skrip LED (hasilnya langsung kelihatan di LED, tidak mengubah setelan UCI):

```sh
/usr/bin/hg680pcl status on     # LED USB nyala
/usr/bin/hg680pcl power online  # LED power pola online
/usr/bin/hg680pcl lan heart     # LED LAN pola heart
/usr/bin/hg680pcl reset         # semua LED padam, semua proses pola disapu
```

---

## 3. Dashboard bilang OFFLINE padahal internet normal

Urutan dugaan (dari yang paling sering):

| # | Kemungkinan | Cara memastikan | Solusi |
|---|---|---|---|
| 1 | **DNS STB bermasalah** — target default berupa *nama host* | dari STB: `ping -c 1 8.8.8.8` sukses **tapi** `ping -c 1 graph.instagram.com` gagal | tambahkan target berbasis IP (mis. `8.8.8.8`) di kartu **Ping Target** — IP tidak butuh DNS |
| 2 | **ICMP diblokir** jaringan/ISP | `ping -c 1 8.8.8.8` juga gagal dari STB | pakai target nama host/server yang masih menjawab ICMP, atau DNS resolver yang bisa di-ping |
| 3 | **Service nonaktif** | pill "Service nonaktif" di kartu Service | tekan **Aktifkan** |
| 4 | Baru ganti target/interval | — | tunggu satu siklus (maks 60 detik) |
| 5 | Target dihapus semua / salah ketik | `uci show hg680pcls.settings.ping_targets` | isi minimal satu target valid (maks 8) |

Catatan: status ONLINE = **minimal satu** target merespons.

---

## 4. Service & LED tidak sesuai

```sh
/etc/init.d/hg680pcls status                # status procd
pgrep -f hg680pcls-service                  # penanda service hidup (dipakai controller)
pgrep -f hg680pcl                           # proses pola LED yang sedang jalan
logread | grep -i hg680pcls | tail -20      # log service
ls /etc/rc.d/*hg680pcls                     # ada = autostart aktif saat boot
```

- **Semua LED diam** padahal pill "Service aktif": cek `pgrep -f hg680pcl`. Kalau kosong, service
  belum masuk siklus ping pertama (interval bisa sampai 60 detik) — atau pin di unitmu beda
  (lihat bagian Nomor pin GPIO di README).
- **LED bertumpuk / pola aneh**: `/usr/bin/hg680pcl reset` menyapu proses pola yang tidak tercatat.
- **Pin 518 (LED USB)**: kalau di unitmu pin ini dipakai untuk kipas USB, pakai mode **Nyala**/**Mati** —
  pola **Detak**/**Disko** membuat pin kedip terus dan tidak cocok untuk kipas.
- **Service nonaktif tidak kembali saat boot**: memang begitu (disengaja) — tekan **Aktifkan**.

---

## 5. Update / pasang ulang

- Dari dashboard: **Cek Update** → kalau ada versi baru muncul **Install Update**; **Pasang ulang**
  memasang kembali rilis terbaru (tanpa perlu ada versi baru). Setelan & target ping selalu
  dipertahankan, termasuk keadaan service (aktif/nonaktif).
- Selama pemasangan, **log installer mengalir langsung** di panel sebelah catatan rilis dan semua
  tombol dimatikan (termasuk *Simpan*). Setelah sukses halaman memuat ulang sendiri; kalau gagal,
  tombol aktif kembali dan log tetap terbuka.
- Pemasangan berjalan di latar belakang di STB, jadi **aman kalau halaman di-refresh**: dashboard
  mendeteksi installer yang masih hidup dan melanjutkan pemantauan. Yang **jangan** dilakukan adalah
  me-reboot STB di tengah pemasangan.
- Log mentah di STB: `/tmp/hg680pcls-update.log`, exit code di `/tmp/hg680pcls-update.rc`
  (`0` = sukses), PID installer di `/tmp/hg680pcls-update.pid`.

```sh
# dari SSH, kalau ingin memantau langsung
tail -f /tmp/hg680pcls-update.log
```

- Dashboard bilang **"Installer tidak berjalan"**: proses installer mati sebelum menulis exit code
  (biasanya tidak bisa mengunduh dari GitHub). Cek koneksi/`curl`, lalu tekan **Pasang ulang** lagi.
- **Instalasi sedang berjalan** (HTTP 409): masih ada installer yang hidup. Tunggu sampai selesai,
  atau hentikan paksa lewat SSH: `kill $(cat /tmp/hg680pcls-update.pid)`.
- Manual dari SSH (pin ke versi tertentu, mis. untuk rollback):

```sh
HG680PCLS_REF=v1.4.0 sh -c "$(curl -fsSL https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main/install.sh)"
```

- Menu/kartu tidak muncul setelah install: logout LuCI atau `/etc/init.d/uhttpd restart`.
- **Cek Update** memakai GitHub API (batas 60 permintaan/jam per IP); kalau kena batas, versi
  dibaca dari branch `main` sebagai cadangan.
