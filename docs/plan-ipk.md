# Rencana: paket `.ipk` untuk HG680PCLS

**Status:** direncanakan — arah sudah disetujui user, **belum diimplementasikan**.
**Tanggal:** 2026-10-18 (setelah rilis v1.4.1)

## Keputusan yang sudah diambil

1. **Rute A — skrip build lokal (tanpa OpenWrt SDK).** Host dev sudah punya `ar` (binutils),
   `tar`, `gzip`; tidak ada instalasi tambahan. Diuji: `ar` 2.47, `tar` 1.35, disk bebas 92 GB.
2. **`.ipk` = pelengkap `install.sh`, bukan pengganti.** `install.sh` + tombol **Install Update**
   tetap jalur utama (berbasis tag GitHub). `.ipk` untuk fresh install / install lewat LuCI
   (**System → Software → Upload Package**) dan untuk `opkg remove` yang bersih.
3. **Build tidak di PC user.** Ditanyakan user soal beban dependensi/storage/kuota: rute A tidak
   memakai apa pun di PC user. Rute SDK (berat: unduh ~200–400 MB, ekstrak ~1–2 GB) **tidak dipakai**.
4. **Target format:** OpenWrt **24.10.x** → `opkg` + `.ipk`.
   OpenWrt 25.x (SNAPSHOT) sudah pindah ke `apk` — **jangan ikut dulu**.
5. **Fase 1 untuk konflik `opkg` vs `install.sh`** (lihat bagian khusus di bawah): cukup dokumentasi
   + pesan di kartu Update. Fase 2 (tombol Update sadar-jalur-pemasangan) ditunda.
6. **Versi rilis**: `VERSION` → **1.5.0** + entri `CHANGELOG.md` (perlu konfirmasi user).
7. **Lampiran aset `.ipk` ke GitHub Release** diunggah **manual lewat web GitHub** — `gh` CLI
   **tidak terpasang** di host dev ini (kalau nanti dipasang, unggah bisa otomatis).

## Kenapa `.ipk` terasa susah padahal tidak

Struktur repo sudah persis seperti yang diharapkan paket OpenWrt, dan `install.sh` sudah memuat
semua aturan yang dibutuhkan `postinst` (fresh install vs upgrade, menghormati service nonaktif,
permission, backup config). Jadi pekerjaannya sebagian besar **memindahkan logika yang sudah ada**,
bukan menulis dari nol.

## Isi paket

Pohon `data/` (samakan dengan daftar `install.sh`, jadi dua jalur memasang file yang identik):

| File di paket | Tujuan | Mode |
|---|---|---|
| `etc/config/hg680pcls` | `/etc/config/hg680pcls` | 644 (**conffiles**) |
| `etc/init.d/hg680pcls` | `/etc/init.d/hg680pcls` | 755 |
| `usr/bin/hg680pcl` | `/usr/bin/hg680pcl` | 755 |
| `usr/lib/lua/luci/controller/hg680pcls.lua` | sama | 644 |
| `usr/lib/lua/luci/view/hg680pcls/dashboard.htm` | sama | 644 |
| `usr/lib/lua/luci/view/hg680pcls/VERSION` | sama (dibaca `local_version()`) | 644 |

`control`:

```
Package: hg680pcls
Version: 1.5.0-1
Depends: luci-lua-runtime
Architecture: all
Section: luci
Priority: optional
Maintainer: Syamsul Sarip Hidayat <...>
Installed-Size: <KB terhitung otomatis>
Description: Kontrol LED Power/LAN/USB + monitor ping untuk STB HG680P (halaman LuCI).
```

`conffiles`:

```
/etc/config/hg680pcls
```

→ setelan user (`ping_targets`, `interval`, mode LED, pin) **tidak tertimpa** saat upgrade. Ini
keunggulan `.ipk` dibanding `install.sh` yang menyalin file secara manual.

## Skrip build — `scripts/make-ipk.sh`

1. Baca versi dari `VERSION`; `PKG_RELEASE` default `1` (bisa `PKG_RELEASE=2 ./scripts/make-ipk.sh`).
2. Staging ke `build/ipk/data/` + `build/ipk/control/` (dibersihkan dulu tiap kali).
3. Set permission persis seperti tabel di atas (ingat: `ar` tidak menyimpan owner, **mode wajib benar**).
4. `data.tar.gz` (`tar -C data -czf ... .`), `control.tar.gz`, `debian-binary` berisi `2.0\n`.
5. `ar rc dist/hg680pcls_<versi>_all.ipk debian-binary control.tar.gz data.tar.gz`
   + `sha256sum` → `dist/hg680pcls_<versi>_all.ipk.sha256`.
6. `build/` dan `dist/` **masuk `.gitignore`** (repo ini belum punya `.gitignore` — dibuat saat implementasi).

## `postinst` (jalan setelah file dipasang)

Aturan yang sama dengan `install.sh`:

- Deteksi **fresh install** vs **upgrade**: fresh = belum ada penanda paket
  (mis. `/usr/lib/lua/luci/view/hg680pcls/.installed`); upgrade = penanda sudah ada.
- Fresh install → `/etc/init.d/hg680pcls enable` + `start`.
- Upgrade → **jangan ubah** keadaan enable/disable pilihan user; restart service hanya kalau memang
  sedang aktif (`ls /etc/rc.d/*hg680pcls` atau service jalan).
- Bersihkan cache LuCI: `rm -f /tmp/luci-indexcache*` supaya menu langsung muncul.
- Tulis penanda `.installed` (dipakai deteksi di atas).

## `prerm` / `postrm`

- `prerm` (`upgrade`/`remove`): `/etc/init.d/hg680pcls stop` + `/usr/bin/hg680pcl reset`
  + `rm -rf /tmp/hg680p_led` (LED padam & proses pola tersapu sebelum file hilang).
- `postrm` (`remove`): `rm -f /tmp/luci-indexcache*` (menu hilang setelah uninstall).
  Config `/etc/config/hg680pcls` **sengaja dibiarkan** (conffiles) — user bisa hapus manual.

## Konflik yang harus diketahui: `opkg` vs `install.sh` (fase 1)

Kalau paket dipasang lewat `opkg`, lalu user menekan **Install Update** (yang menjalankan
`install.sh` dari tag), file ditimpa **di luar pengetahuan opkg** → opkg menandai file
*modified* dan `opkg upgrade`/`remove` berikutnya bisa mengeluh.

Fase 1 (sekarang):

- Dokumentasi (`README.md` + `docs/troubleshooting.md`) menyebut: *kalau terpasang via opkg,
  update lewat opkg* (`opkg install --allow-untrusted <url .ipk>` atau unggah ulang dari LuCI).
- Kartu Update di dashboard boleh menampilkan pengingat bila `opkg status hg680pcls` ada
  (opsional, ditunda bersama fase 2).

Fase 2 (nanti, belum disetujui):

- Tombol **Install Update** mendeteksi jalur pemasangan; kalau via opkg → unduh aset `.ipk` dari
  Release lalu `opkg install --allow-untrusted`. Perlu logika baru di controller + endpoint baru.

## Checklist implementasi

- [ ] `scripts/make-ipk.sh` (build + `control`/`conffiles`/`postinst`/`prerm`/`postrm`)
- [ ] `.gitignore` → `build/`, `dist/`
- [ ] Uji isi paket: `ar t`, `tar tzf` (daftar file + mode benar)
- [ ] Uji fungsional di host: ekstrak ke root palsu (`/tmp/ipk-root`), cek mode, jalankan
      `postinst`/`prerm` dengan `PATH` & root palsu (uji fresh vs upgrade, service nonaktif tetap nonaktif)
- [ ] `README.md` (2 jalur instalasi), `docs/troubleshooting.md` (bagian opkg),
      `AGENTS.md` (konvensi build), `PROGRESS.md`
- [ ] `VERSION` → 1.5.0 + entri `CHANGELOG.md`
- [ ] Uji di STB: install via LuCI Upload Package → menu muncul; upgrade di atas `.ipk` lama
      dengan config yang sudah diubah → setelan tetap; `opkg remove hg680pcls` → service berhenti, LED padam
- [ ] Build `.ipk` final dari tag `v1.5.0` → unggah ke GitHub Release (+ `.sha256`)

## Perkiraan usaha

- Implementasi + uji lokal: **±1–2 jam** kerja agent.
- Uji di STB (visual & opkg): perlu kamu, ±10 menit.
- Tiap rilis berikutnya: **±1 menit** (jalankan skrip, unggah aset).

## Catatan teknis

- `Architecture: all` sah untuk paket murni Lua/shell — tidak terikat arsitektur ARM STB.
- Paket tanpa tanda tangan: kalau `opkg` di unit user memeriksa signature, pakai
  `opkg install --allow-untrusted hg680pcls_1.5.0_all.ipk`.
- `.ipk` **tidak** memuat `install.sh`/`uninstall.sh` (alat repo, bukan isi paket).
- Ukuran paket: beberapa KB (hanya Lua + shell + satu halaman HTML).
