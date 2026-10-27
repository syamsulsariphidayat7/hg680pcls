# PROGRESS.md

Ringkas — update tiap akhir sesi.

**Tanggal terakhir diperbarui:** 2026-10-27
**Fase:** Maintenance / fitur (setelah Development + Deployment)
**Versi:** 1.5.1

## Sedang dikerjakan (sesi ini)
- [x] **Rilis v1.5.1** — penggabungan kartu Mode LED, tombol Service berwarna, konfirmasi hapus target.
      `VERSION` = 1.5.1, `CHANGELOG` heading `## 1.5.1 (2026-10-27)`, commit + tag `v1.5.1`.
- [x] **Kartu LED LAN + Power digabung** jadi satu kartu **Mode LED** (dua baris: LAN & Power) → grup
      **PENGATURAN** kini **3 kartu**: Mode LED, Ping Target, Interval Cek. Indikator diperkecil
      (LED 16px → 12px, padding tombol mode 14px → 9px, radius 12px → 10px); ≤330px tetap 2 kolom.
      Preview headless (1280/380/320px) sudah dicek: 4 tombol sejajar tidak pecah teks.
- [x] **Tombol kartu Service diberi warna**: **Aktifkan** hijau solid (`#15803d`, hover `#166534`),
      **Nonaktifkan** merah outline (`#b91c1c`, hover jadi solid + teks putih), state `disabled`
      (saat memasang update) abu-abu netral dengan kursor `not-allowed`. Ditambah `title` penjelas efek
      tiap aksi. Kontras teks lolos AA (≥4.5:1). Verifikasi `node --check` lolos.
- [x] **Konfirmasi hapus target aktif**: klik chip di kartu **Ping Target** kini memunculkan `confirm()`
      ("Hapus target <host> dari daftar?" + pengingat berlaku setelah Simpan). Verifikasi `node --check` /
      `sh -n` / `luac -p` lolos. Masuk rilis 1.5.1.
- [x] Catatan tata letak disamakan: `CHANGELOG.md` (1.5.0 menyebut **4 kartu** di PENGATURAN; entri
      1.4.2 diberi keterangan "5 kartu waktu itu, jadi 4 sejak 1.5.0") dan `PROGRESS.md` (rilis 1.4.2).
- [x] **Rilis v1.5.0** — dashboard hanya mengontrol **LED LAN** dan **LED Power**.
- [x] Kode: kartu mode ketiga dihapus dari view; controller hanya memvalidasi/menyimpan
      `power_mode` + `lan_mode`; `/status` tidak lagi mengirim field mode ketiga; skrip
      `usr/bin/hg680pcl` hanya menerima target `power`/`lan`/`reset`/`stop`; `etc/init.d` tidak lagi
      menggerakkan pin ketiga saat start; default UCI bersih.
- [x] Docs disamakan: `README.md` (daftar fitur + override pin + contoh uji GPIO),
      `CHANGELOG.md` (entri 1.3.0/1.4.0 dirapikan, heading 1.5.0), `docs/api.md`,
      `docs/troubleshooting.md`, `AGENTS.md`, `docs/plan-ipk.md`.
- [x] Verifikasi: `luac -p`, `sh -n`, `node --check` semua lolos; `VERSION` 1.5.0; `CHANGELOG` heading 1.5.0.
- [x] Commit + push + tag **v1.5.0** (sudah di origin).
- [ ] Uji di STB: pastikan hanya dua kartu mode yang tampil, Simpan mengubah pola LED LAN/Power,
      dan service lama (yang masih menyimpan pin ketiga di UCI) tetap jalan normal — setelan lama
      diabaikan tanpa error.

## Rilis 1.4.2 (detail)
- [x] **Tata letak halaman dibagi dua grup**: **PENGATURAN** (5 kartu waktu itu + tombol *Simpan & Restart
      Service* di dalam grup; **jadi 4 kartu sejak 1.5.0**) dan **SISTEM** (**Service** lalu **Update**)
      — dengan catatan kecil "berlaku setelah Simpan" / "langsung berlaku".
- [x] Baris kartu Service: urutan **[tombol] [pill Service] [pill Internet]**, semuanya rapat kiri
      (`margin-left:auto` dihapus).
- [x] Kartu Update: panel **catatan rilis + log install** berdampingan (2 kolom, tinggi tetap + scroll),
      melebar penuh bila hanya satu yang terisi (`syncPanes()` → kelas `one`), 1 kolom di ≤640px.
- [x] **Pemasangan update detached + log live**: `POST /update` melepas installer (`sh -c … &`,
      stdin `/dev/null`, stdout/stderr → `/tmp/hg680pcls-update.log`) lalu langsung menjawab —
      request LuCI tidak lagi menggantung 30–90 detik. Skrip wrapper menulis PID sendiri,
      mengunduh `install.sh` ke file (supaya exit code `curl` tidak tertukar dengan exit code
      installer), lalu menulis exit code ke `/tmp/hg680pcls-update.rc`.
- [x] Endpoint baru **`GET /updatelog`** (`running`, `done`, `code`, `local`, `log` = 4000 karakter
      terakhir) + penolakan **409 `instalasi sedang berjalan`** kalau masih ada installer hidup.
- [x] Dashboard: poll `/updatelog` tiap 1,5 detik, log mengalir ke panel, semua tombol (Cek Update,
      Install/Pasang ulang, Service, **Simpan**) dimatikan selama pemasangan, label `Menginstall… (Ns)`
      + spinner, bar progres, peringatan "jangan tutup halaman" (`beforeunload`), auto-refresh 5 detik
      dijeda, hitungan "Memuat ulang dalam 5 detik" (bisa diklik) setelah sukses, exit code dilaporkan
      saat gagal, dan **pemantauan dilanjutkan** kalau halaman di-refresh di tengah pemasangan.
- [x] Verifikasi lokal: `luac -p`, `sh -n`, `node --check` + **smoke test DOM 93/93**
      (`/tmp/opencode/dom_test.js`, DOM & `fetch` palsu: struktur, urutan section/kartu, panel,
      alur sukses/gagal/409/buntu, pemulihan setelah refresh) + **harness controller 36/36**
      (`/tmp/opencode/ctrl_test.lua`, stub luci/nixio: penanda `running`/`done`, perintah detached,
      protokol pid/rc dengan `curl` palsu, anti pemasangan ganda). Harness ada di `/tmp` (tidak di repo).
- [x] Commit + push + tag **v1.4.2** (`333a2a1`, tag `v1.4.2` sudah di-push & terverifikasi lewat GitHub API:
      `/tags` mengembalikan 1.4.2 teratas, `VERSION` = 1.4.2, heading pertama `CHANGELOG` = 1.4.2,
      `docs/troubleshooting.md` & `docs/api.md` (bagian `GET /updatelog`) tersedia di tag, dan kode
      controller/dashboard di tag memuat `action_updatelog`, route `updatelog`, `setsid`, `syncPanes`).

## Rilis 1.4.0 & 1.4.1 (detail)
- [x] Commit + push + tag **v1.4.0** (`f9dc99b`, tag `v1.4.0` sudah di-push & terverifikasi lewat GitHub API).
- [x] Pill status internet dipindah dari pojok kanan atas ke kartu **Service** (di sebelah pill status
      service, diberi label "Internet" + tooltip).
- [x] Dokumentasi **`docs/troubleshooting.md`** — perintah tes konektivitas dari PC & dari STB,
      urutan dugaan kenapa dashboard bilang OFFLINE padahal internet normal, cek service/LED,
      serta cara update/rollback manual. Ditautkan dari README + daftar struktur `AGENTS.md`.
- [x] Commit + push + tag **v1.4.1** (`9efa409`, tag `v1.4.1` sudah di-push & terverifikasi lewat GitHub API:
      `/tags` mengembalikan 1.4.1, `VERSION` & heading `CHANGELOG` di tag cocok, `docs/troubleshooting.md` tersedia).

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
- Pemasangan update kini dijalankan **detached** dari proses LuCI. Pola yang sama (`… >/dev/null 2>&1 &`)
  sudah dipakai `POST /save` untuk restart service dan jalan di STB, tapi perilaku "installer tetap
  hidup setelah request LuCI selesai" baru diuji di harness lokal (curl palsu) — **perlu dipastikan
  sekali di STB** saat Install Update pertama.
- Endpoint `/check` memakai GitHub API (rate limit 60 req/jam per IP) — sudah ada fallback ke `main`.

## Verifikasi yang sudah dijalankan
- `luac -p` controller → OK
- `sh -n` install.sh / uninstall.sh / init.d / hg680pcl → OK
- `node --check` blok `<script>` dashboard (setelah substitusi `<%=…%>`) → OK
- **Smoke test DOM dashboard — 93/93** (`/tmp/opencode/dom_test.js`; DOM + `fetch` palsu):
  struktur dua grup, urutan Service→Update, urutan isi baris Service, panel tersembunyi di awal,
  kelas `one`/`two`, alur Cek Update, pemasangan sukses (log mengalir 3 poll + toast + versi baru +
  countdown), gagal (`rc=1`), tolak 409, installer buntu (~15 dtk), dan pemulihan setelah refresh.
- **Harness controller — 36/36** (`/tmp/opencode/ctrl_test.lua`, stub `luci`/`nixio`, jalan dengan `luajit`):
  `done`/`running`/`code` dari `/updatelog`, PID hidup & stale, pemotongan log 4000 karakter,
  perintah detached (`</dev/null`, log, `&`), wrapper lolos `sh -n`, protokol PID/rc dengan `curl` palsu
  (sukses → 0, installer gagal → 7, unduhan gagal → 1 — bukan sukses palsu), dan tolak ganda (409).
- Harness uji LED lokal (`/tmp/test_led.sh`, sysfs palsu) → semua langkah sesuai harapan

## Rencana berikutnya (disetujui arahnya, belum dikerjakan)
- **Paket `.ipk` sebagai pelengkap `install.sh`** — detail lengkap di
  [`docs/plan-ipk.md`](docs/plan-ipk.md). Ringkas:
  - Rute **A**: skrip `scripts/make-ipk.sh` (tanpa SDK; hanya `ar`+`tar`+`gzip` di host dev),
    `Architecture: all`, `Depends: luci-lua-runtime`, `conffiles: /etc/config/hg680pcls`.
  - Dibangun **di host dev**, bukan di PC user (keputusan user: hindari dependensi/storage/kuota).
  - `install.sh` + tombol **Install Update** tetap jalur utama; `.ipk` untuk fresh install
    (upload via LuCI → System → Software) dan `opkg remove` yang bersih.
  - Konflik `opkg` vs `install.sh` → **fase 1**: cukup dokumentasi + pengingat; fase 2
    (tombol Update sadar-jalur-pemasangan) ditunda.
  - Target format: OpenWrt **24.10** (`opkg`/`.ipk`); 25.x SNAPSHOT sudah `apk` — jangan ikut dulu.
  - Rencana versi rilis: **1.5.0**. Aset `.ipk` diunggah **manual** ke GitHub Release
    (`gh` CLI tidak terpasang di host dev).
  - Perkiraan: ±1–2 jam implementasi + uji lokal, ±10 menit uji STB, ±1 menit tiap rilis berikutnya.

## Langkah berikut (kandidat, belum disetujui)
- CI GitHub Actions (shellcheck + luac -p + sh -n + node --check).
- Histori uptime & tombol Restart Service.
- Rollback update dari dashboard.
- Mode LED `on` (nyala tetap) untuk power/LAN belum ada — sekarang hanya pola kedip (offline/online/heart/disko).
