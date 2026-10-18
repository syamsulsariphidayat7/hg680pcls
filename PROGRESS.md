# PROGRESS.md

Ringkas — update tiap akhir sesi.

**Tanggal terakhir diperbarui:** 2026-10-18
**Fase:** Maintenance / hardening (setelah Development + Deployment)
**Versi:** 1.2.3

## Sedang dikerjakan (sesi ini)
- [x] Keamanan: `save` & `update` wajib POST + token CSRF.
- [x] Validasi `ping_targets` (maks 8, pola hostname/IP).
- [x] Rilis berbasis tag: installer & Cek Update resolve tag `v<versi>` tertinggi (fallback `main`).
- [x] Catatan rilis di dashboard (dibaca dari `CHANGELOG.md`).
- [x] Dokumentasi: `AGENTS.md`, `PROGRESS.md`, `docs/api.md`, `docs/adr/`, `LICENSE`, `CHANGELOG.md`.
- [x] UI: latar halaman putih + bar simpan in-flow (tidak menutupi footer).
- [ ] Commit + push + tag `v1.2.3` → **menunggu izin user**.

## Sudah selesai (rilis sebelumnya)
- Service `procd` loop ping + kontrol LED GPIO; sweep proses pola LED (anti tumpuk).
- Dashboard kustom: kartu mode LED (Power/LAN), ping target chip inline, slider interval 1–60s.
- Pill status koneksi pojok kanan atas (endpoint `/status`, auto-refresh 5 detik).
- Layout 2 baris (config | update) + tombol Repo GitHub; "Tambah cepat" & kartu Status dihapus.
- Tombol Cek Update / Install Update (endpoint `/check`, `/update`).

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
