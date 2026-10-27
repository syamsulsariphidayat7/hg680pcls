# Changelog

Semua perubahan penting proyek ini didokumentasikan di sini.
Versi mengikuti `MAJOR.MINOR.PATCH`, dan **setiap rilis diberi tag `v<versi>`** di GitHub
(tag inilah yang dipakai installer & tombol Update — bukan branch `main`).

## 1.5.1 (2026-10-27)
- **Satu kartu untuk dua LED**: **LED LAN** dan **LED Power** digabung jadi kartu **Mode LED** dengan dua
  baris (LAN & Power). Grup **PENGATURAN** kini **3 kartu**: Mode LED, Ping Target, Interval Cek.
- **Indikator lebih ringkas**: titik LED 16px → **12px**, padding tombol mode dirapatkan (14px → 9px),
  radius 12px → 10px. Di layar ≤330px tombol mode turun jadi 2 kolom; di atas itu tetap 4 sejajar.
- **Tombol kartu Service diberi warna**: **Aktifkan** hijau solid, **Nonaktifkan** merah outline
  (hover jadi solid), state `disabled` saat memasang update tampil abu-abu netral.
- **Konfirmasi hapus target**: klik chip di kartu **Ping Target** kini memunculkan dialog konfirmasi
  (nama target + pengingat bahwa perubahan berlaku setelah Simpan).

## 1.5.0 (2026-10-18)
- Dashboard hanya mengontrol **LED LAN** dan **LED Power** (dua kartu mode); kartu mode ketiga dihapus.
- Grup **PENGATURAN** kini berisi **4 kartu**: **LED LAN**, **LED Power**, **Ping Target**, dan
  **Interval Cek** (turun dari 5 kartu karena kartu mode ketiga dihapus).

## 1.4.3 (2026-10-18)
- Kartu **Ping Target**: keterangan **"Pisahkan dengan spasi · maksimal 8 target"** di bawah kolom input,
  supaya jelas cara menulis lebih dari satu target (batas 8 target tidak berubah).

## 1.4.2 (2026-10-18)
- **Halaman dibagi dua grup**: **PENGATURAN** (5 kartu mode/target/interval waktu itu + tombol *Simpan &
  Restart Service* yang kini berada di dalam grup ini; **jadi 4 kartu sejak v1.5.0**) dan **SISTEM**
  (kartu **Service** lalu **Update**) —
  jelas mana yang baru berlaku setelah Simpan dan mana yang langsung berlaku.
- **Baris kartu Service dirapikan**: urutannya sekarang **[Nonaktifkan/Aktifkan] [Service aktif]
  [Internet ONLINE]**, semuanya rapat kiri (sebelumnya tombol didorong ke kanan).
- **Catatan rilis & log install kini berdampingan** dalam satu kartu (2 kolom, tinggi tetap dengan
  scroll sendiri). Kalau hanya satu yang punya isi, panel itu melebar penuh; di layar ≤640px turun
  jadi 1 kolom.
- **Pemasangan update jalan di latar belakang dengan log live**: `POST /update` kini melepas installer
  (detached) dan langsung menjawab, jadi request tidak lagi menggantung 30–90 detik. Dashboard
  memantau lewat endpoint baru **`GET /updatelog`** (tiap ~1,5 detik) dan menampilkan keluaran
  installer baris demi baris — *"Ref dipakai… → Downloading… → Installing files… → Installation
  complete"*.
- **UI saat memasang**: semua tombol (Cek Update, Install/Pasang ulang, Service, sampai **Simpan**)
  dimatikan selama pemasangan, tombol yang diklik berubah jadi `Menginstall… (12s)` + spinner, ada bar
  progres tipis dan peringatan **"jangan tutup atau muat ulang halaman ini"** (`beforeunload`), serta
  auto-refresh 5 detik dijeda. Setelah selesai: toast hijau, versi terpasang diperbarui, lalu hitungan
  **"Memuat ulang dalam 5 detik"** (bisa diklik untuk langsung).
- **Tahan refresh**: kalau halaman dimuat ulang di tengah pemasangan, dashboard mendeteksi installer
  yang masih hidup dan melanjutkan memantau + menampilkan log yang sudah terkumpul.
- Kegagalan kini terlihat sebabnya: exit code installer (`rc`) ditulis terpisah, jadi unduhan yang gagal
  tidak lagi dilaporkan sebagai sukses; pesan gagal menyertakan kodenya dan log tetap terbuka.
- Anti pemasangan ganda: selama installer masih hidup, `POST /update` menjawab **409**
  (`instalasi sedang berjalan`) alih-alih menjalankan dua installer bersamaan.

## 1.4.1 (2026-10-18)
- Pill **status koneksi internet** dipindah dari pojok kanan atas ke kartu **Service**, di sebelah pill
  status service, dan diberi label kecil "Internet" + tooltip supaya tidak tertukar dengan status
  service. Header atas kini hanya judul halaman.
- Dokumentasi baru [`docs/troubleshooting.md`](docs/troubleshooting.md): perintah tes konektivitas
  dari PC & dari STB, urutan dugaan kenapa dashboard bisa bilang OFFLINE padahal internet normal,
  cek service/LED, dan cara update/rollback manual.

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
- Dashboard dirapikan: urutan kartu LED jadi **LED LAN → LED Power**, dan semua teks
  keterangan panjang dihapus — kartu mode/input sudah jelas dari label & preview, kartu Service
  menyisakan baris status hidup, kartu Update menyisakan kredit. Label
  "Target aktif (klik untuk hapus)" tetap ada.

## 1.3.0 (2026-10-18)
- Nomor pin kini bisa dioverride lewat UCI (berguna untuk board revisi lain yang beda pin):
  `power_pin_on` (521), `power_pin_off` (517), `lan_pin_on` (547), `lan_pin_off` (548).
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
