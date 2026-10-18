# PROGRESS.md

Ringkas — update tiap akhir sesi.

**Tanggal terakhir diperbarui:** 2026-10-18
**Fase:** Maintenance / hardening (setelah Development + Deployment)
**Versi:** 1.2.4

## Sedang dikerjakan (sesi ini)
- [x] Tombol **Pasang ulang** di kartu Update (perbaikan tanpa harus ada versi baru).
- [x] Tanda skala slider interval (5, 10, … 60, bisa diklik).
- [x] `VERSION` → 1.2.4 + entri `CHANGELOG.md`.
- [x] Commit + push + tag `v1.2.4` (`19b990a`); resolver GitHub sudah mengembalikan `1.2.4`.

## Sudah selesai (rilis sebelumnya)
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

## Verifikasi rilis terakhir (v1.2.3)
- `GET /tags` GitHub melihat `v1.2.3`; pipeline installer → `1.2.3`.
- File di ref tag tersedia: `VERSION`, `install.sh`, `CHANGELOG.md`, `LICENSE`.
- **Belum diuji di STB** (uji visual/tombol menunggu user).

## Blocker / catatan
- **Tidak bisa render-test LuCI dari host dev** (LuCI tidak terpasang di sini). Verifikasi visual
  harus dilakukan di STB setelah install.
- Endpoint `/check` memakai GitHub API (rate limit 60 req/jam per IP) — sudah ada fallback ke `main`.

## Verifikasi yang sudah dijalankan
- `luac -p` controller → OK
- `sh -n` install.sh / uninstall.sh / init.d / hg680pcl → OK
- `node --check` blok `<script>` dashboard (setelah substitusi `<%=…%>`) → OK

## Langkah berikut (kandidat, belum disetujui)
- CI GitHub Actions (shellcheck + luac -p + sh -n + node --check).
- Histori uptime & tombol Restart Service.
- Mode LED nyala tetap (`steady`).
- Rollback update dari dashboard.
