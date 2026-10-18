# PROGRESS.md

Ringkas — update tiap akhir sesi.

**Tanggal terakhir diperbarui:** 2026-10-18
**Fase:** Maintenance / fitur (setelah Development + Deployment)
**Versi:** 1.3.0

## Sedang dikerjakan (sesi ini)
- [x] **LED ketiga (pin 518)** → kartu **LED Status** di dashboard: mode `Mati` / `Nyala` / `Detak` (heartbeat, default) / `Disko`.
      LED ini tidak ikut status koneksi (independen), jadi bisa dipakai sebagai heartbeat service.
- [x] Nomor pin LED bisa dioverride lewat UCI (`power_pin_on/off`, `lan_pin_on/off`, `status_pin`) dengan fallback default.
- [x] Perbaikan 3 bug pada `usr/bin/hg680pcl` yang ditemukan saat uji lokal:
      `stop_mode` tidak menemukan PID file (local multi-assign), proses latar menahan stdout pemanggil,
      dan balapan trap vs mode steady (`wait_gone`).
- [x] `VERSION` → 1.3.0, entri `CHANGELOG.md`, `docs/api.md` (bentuk respons `/status` diperbarui), `README.md`, `AGENTS.md`.
- [ ] Commit + push + tag `v1.3.0` — **menunggu izin user**.
- [ ] Uji di STB: apakah pin 518 benar LED (bukan IR/USB reset), mode `Detak`, overrides UCI.

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
- Pin 518 **belum dikonfirmasi** sebagai LED di unit user. Kalau ternyata bukan LED, set mode **Mati**
  (atau ganti `status_pin` / lewati) — tidak perlu edit skrip.

## Verifikasi yang sudah dijalankan
- `luac -p` controller → OK
- `sh -n` install.sh / uninstall.sh / init.d / hg680pcl → OK
- `node --check` blok `<script>` dashboard (setelah substitusi `<%=…%>`) → OK
- Harness uji LED lokal (`/tmp/test_led.sh`, sysfs palsu) → semua langkah sesuai harapan

## Langkah berikut (kandidat, belum disetujui)
- CI GitHub Actions (shellcheck + luac -p + sh -n + node --check).
- Histori uptime & tombol Restart Service.
- Rollback update dari dashboard.
- Mode LED `heart`/`disko` untuk power/LAN sudah ada; mode `nyala tetap` (`on`) masih hanya untuk LED status.
