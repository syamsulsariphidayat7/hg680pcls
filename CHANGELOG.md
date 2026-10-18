# Changelog

Semua perubahan penting proyek ini didokumentasikan di sini.
Versi mengikuti `MAJOR.MINOR.PATCH`, dan **setiap rilis diberi tag `v<versi>`** di GitHub
(tag inilah yang dipakai installer & tombol Update — bukan branch `main`).

## 1.4.0 (2026-10-18)
- **Kontrol service: Aktifkan / Nonaktifkan** — kartu **Service** baru di dashboard dengan status
  langsung (berjalan/berhenti + autostart) dan satu tombol sakelar.
  **Nonaktifkan** = service dihentikan sekarang (ping berhenti, semua LED dimatikan) sekaligus
  mematikan autostart; **Aktifkan** = dijalankan sekarang + autostart aktif. Setelan tetap tersimpan.
- Endpoint baru `POST /service` (`action=on|off`) — wajib POST + token CSRF, sama seperti `save`/`update`.
- `/status` kini menyertakan `enabled` (keadaan autostart service).
- **Simpan & Restart** tidak lagi menghidupkan service yang sengaja dinonaktifkan.
- Installer menghormati pilihan itu: reinstall/upgrade saat service nonaktif akan tetap nonaktif
  (fresh install tetap langsung aktif seperti sebelumnya).
- Kartu **LED Status** → **LED USB**: pin 518 ternyata **LED indikator USB**, bukan LED status
  generik. Mode & default tidak berubah. Di sebagian unit pin ini dipakai untuk mengendalikan kipas
  USB — untuk itu pakai **Nyala**/**Mati** (pola Detak/Disko hanya cocok untuk LED).
- Dashboard dirapikan: urutan kartu LED kini **LED LAN → LED USB → LED Power**, dan semua teks
  keterangan panjang dihapus — kartu mode/input sudah jelas dari label & preview, kartu Service
  menyisakan baris status hidup, kartu Update menyisakan kredit. Label
  "Target aktif (klik untuk hapus)" tetap ada.

## 1.3.0 (2026-10-18)
- **LED ketiga (pin 518)** — kartu baru **LED Status**: LED tunggal yang tidak ikut status koneksi.
  Mode: **Mati** (pin tidak digerakkan), **Nyala** (terang terus), **Detak** (heartbeat, default),
  dan **Disko**. Default `heart` = kedip pelan sebagai tanda service hidup.
- Nomor pin kini bisa dioverride lewat UCI (berguna untuk board revisi lain yang beda pin):
  `power_pin_on` (521), `power_pin_off` (517), `lan_pin_on` (547), `lan_pin_off` (548),
  `status_pin` (518).
- Perbaikan bug lama yang berhubungan dengan "LED bertumpuk": `stop_mode()` gagal menemukan PID file
  karena `local name="$1" pid_file="$DIR/${name}.pid"` dievaluasi sebelum `name` terisi di sebagian
  shell (dash) — akibatnya proses pola lama tidak pernah dimatikan.
- Proses pola LED kini menutup stdout/stderr-nya sendiri, supaya tidak menahan pipe pemanggil
  (mis. `luci.sys.exec`) dan membuat request menggantung.
- Saat ganti dari pola ke mode steady, kini menunggu proses lama benar-benar keluar dulu — mencegah
  trap proses lama menimpa nilai pin yang baru ditulis.
- Sweep proses tidak lagi mencetak pesan `/proc/NNN/cmdline: No such file` saat proses hilang
  di tengah iterasi.

## 1.2.4 (2026-10-18)
- Tombol **Pasang ulang** di kartu Update: memasang kembali rilis terbaru untuk perbaikan
  (berguna saat versi terpasang sudah terbaru tapi service/LED bermasalah — tombol Install Update
  hanya muncul kalau ada versi lebih baru). Setelan & target ping tetap dipertahankan.
- Slider **Interval Cek** kini punya tanda skala 5, 10, 15, … 60; angkanya bisa diklik untuk
  langsung lompat ke nilai tersebut (slider tetap bebas 1–60 detik).

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
