# PROGRESS.md

Ringkas — update tiap akhir sesi.

**Tanggal terakhir diperbarui:** 2026-10-18
**Fase:** Maintenance / fitur (setelah Development + Deployment)
**Versi:** 1.4.0

## Sedang dikerjakan (sesi ini)
- [x] **Kontrol service: Aktifkan / Nonaktifkan** — kartu **Service** (baris kedua, sebelum Update) dengan pill status
      (berjalan/berhenti + autostart) dan satu tombol sakelar.
- [x] Endpoint baru `POST /service` (`action=on|off`) — wajib POST + token CSRF (pakai `require_post()`),
      memanggil `/etc/init.d/hg680pcls {enable,start} | {stop,disable}`.
- [x] `/status` menambah field `enabled` (cek symlink `/etc/rc.d/*hg680pcls`).
- [x] `service_running()` kini juga mendeteksi penanda `# hg680pcls-service` di cmdline shell service,
      jadi indikator "berjalan" akurat sejak `Aktifkan` (LED power/lan baru muncul setelah ping pertama).
- [x] `POST /save` tidak lagi me-restart (menghidupkan) service yang sengaja dinonaktifkan.
- [x] `install.sh` menghormati pilihan user: reinstall/upgrade mempertahankan keadaan nonaktif,
      fresh install tetap langsung aktif.
- [x] Dashboard dirapikan: kartu **LED Status → LED USB** (pin 518 = LED indikator USB — di sebagian
      unit dipakai untuk kendali kipas USB), urutan kartu LED jadi **LED LAN → LED USB → LED Power**,
      dan deskripsi panjang dihapus (kartu Service menyisakan status hidup, kartu Update kredit;
      label "Target aktif (klik untuk hapus)" tetap).
- [ ] Commit + push + tag `v1.4.0` — **menunggu izin user**.
- [ ] Uji di STB: tombol Nonaktifkan (LED mati + tidak ada proses), Aktifkan, setelah reboot,
      plus urutan/penamaan kartu baru (LED LAN → LED USB → LED Power) dan kartu Service.

## Sudah selesai (rilis sebelumnya)
- v1.2.4 — tombol **Pasang ulang** di kartu Update + skala slider interval (angka 5…60 bisa diklik).
- v1.2.3 — keamanan (`save`/`update` wajib POST + token CSRF), validasi `ping_targets`
  (maks 8, pola hostname/IP), rilis berbasis tag (installer & Cek Update resolve tag `v<versi>`
  tertinggi, fallback `main`), catatan rilis dari `CHANGELOG.md`, latar halaman putih,
  dokumentasi (`AGENTS.md`, `docs/api.md`, `docs/adr/`, `LICENSE`, `CHANGELOG.md`).
  Sudah di-push + tag `v1.2.3` (`627ed4a`, `545bc45`, `7e5f983`, `be5eda8`).
- Service `procd` loop ping + kontrol LED GPIO; sweep proses pola LED (anti tumpuk).
- Dashboard kustom: kartu mode LED (Power/LAN), ping target chip inline, slider interval 1–60s.
- Pill status koneksi pojok kanan atas (endpoint `/status`, auto-refresh 5 detik).
- Layout 2 baris (config | update) + tombol Repo GitHub; "Tambah cepat" & kartu Status dihapus.
- Tombol Cek Update / Install Update (endpoint `/check`, `/update`).

## Verifikasi rilis terakhir (v1.3.0)
- Uji `usr/bin/hg680pcl` di host dev memakai **sysfs palsu** (`/tmp/fakegpio`) + path di-rewrite:
  mode `heart`/`on`/`off`/`disko`, ganti mode (proses lama mati, tidak menumpuk), `reset` menyapu
  semua proses & pin kembali 0, override pin lewat stub `uci`, dan uji balapan pola→steady (3/3 pin benar).
- **Belum diuji di STB** (uji visual/tombol menunggu user).

## Blocker / catatan
- **Tidak bisa render-test LuCI dari host dev** (LuCI tidak terpasang di sini). Verifikasi visual
  harus dilakukan di STB setelah install.
- Endpoint `/check` memakai GitHub API (rate limit 60 req/jam per IP) — sudah ada fallback ke `main`.
- Pin 518 = **LED indikator USB** (dikonfirmasi user), bukan LED status generik. Mode **Mati** menulis
  `0` ke pin (LED padam) — pakai itu bila di unit lain pin ini ternyata bukan LED.

## Verifikasi yang sudah dijalankan
- `luac -p` controller → OK
- `sh -n` install.sh / uninstall.sh / init.d / hg680pcl → OK
- `node --check` blok `<script>` dashboard (setelah substitusi `<%=…%>`) → OK
- Harness uji LED lokal (`/tmp/test_led.sh`, sysfs palsu) → semua langkah sesuai harapan

## Langkah berikut (kandidat, belum disetujui)
- CI GitHub Actions (shellcheck + luac -p + sh -n + node --check).
- Histori uptime & tombol Restart Service.
- Rollback update dari dashboard.
- Mode LED `heart`/`disko` untuk power/LAN sudah ada; mode `nyala tetap` (`on`) masih hanya untuk LED USB (pin 518).
