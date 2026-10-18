# Changelog

Semua perubahan penting proyek ini didokumentasikan di sini.
Versi mengikuti `MAJOR.MINOR.PATCH`, dan **setiap rilis diberi tag `v<versi>`** di GitHub
(tag inilah yang dipakai installer & tombol Update — bukan branch `main`).

## 1.2.3 (2026-10-18)
- Keamanan: endpoint `save` & `update` kini **wajib POST + token CSRF**
  (`post(...)` di routing + `require_post()` di dalam action).
- Keamanan: validasi target ping — maksimal 8 target, hanya pola hostname/IP
  (mencegah injeksi shell di loop `init.d` dan opsi `ping` yang diawali `-`).
- Rilis berbasis tag: installer & tombol Update menarik ref tag `v<versi>` terbaru
  (fallback `main`); bisa dipin manual lewat `HG680PCLS_REF=v1.2.2`.
- Tombol **Cek Update** kini menampilkan catatan rilis (dibaca dari `CHANGELOG.md`).
- UI: latar halaman putih bersih; bar simpan tidak lagi menutupi footer OpenWrt.
- Dokumentasi: `docs/api.md`, `docs/adr/`, `AGENTS.md`, `PROGRESS.md`, `LICENSE`.

## 1.2.2 (2026-10-18)
- Layout 2 baris: kartu config sejajar di baris 1; kartu Update digabung dengan
  kontak + tombol **Repo GitHub** di baris 2.
- Bar simpan dipindah ke dalam alur konten (tidak lagi `position:fixed`, tadinya
  menutupi footer OpenWrt).

## 1.2.1 (2026-10-18)
- Lebar halaman penuh, mengikuti halaman LuCI lain (batas 1080px dihapus).
- Kartu **Status Koneksi** dihapus — status cukup di pill pojok kanan atas.
- Preset "Tambah cepat" dihapus; ping target cukup input + chip status inline.
- Workflow update manual: tombol **Cek Update** selalu ada, tombol **Install Update**
  hanya muncul bila ada versi baru.
- Endpoint `/status` mengirim versi terpasang (pill terisi tanpa cek ke GitHub).

## 1.2.0 (2026-10-18)
- Halaman dashboard (Lua template) dengan tombol simpan bergaya native LuCI.
- Ping target sebagai chip dengan status inline (dot hijau/merah + latensi).
- Tombol **Update dari GitHub** + penanda versi (`VERSION`).
- Mode LED `offline` / `online` / `heart` / `disko`; default power `online`, LAN `heart`;
  target ping default `graph.instagram.com`; interval 1–60 detik.
- Perbaikan proses LED "bertumpuk" saat reinstall (sweep proses + clean-slate).
