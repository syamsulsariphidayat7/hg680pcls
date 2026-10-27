# Kontrak API — HG680PCLS

Semua endpoint berada di bawah `admin/services/hg680pcls`.
Base URL: `http://<router>/cgi-bin/luci/admin/services/hg680pcls`

- Semua respons **JSON** (`application/json`) kecuali bila ditolak CSRF (lihat bawah).
- Endpoint yang ditandai **POST+token** memakai `post(...)` pada routing LuCI sehingga
  divalidasi otomatis oleh dispatcher (`405` bila bukan POST, `403` bila token salah),
  dan dicek ulang oleh `require_post()` di dalam action (lapisan kedua).
- Token CSRF tersedia di template sebagai `<%=token%>`.

---

## `GET /status`

Data untuk pill status & chip target di dashboard. Dipanggil berkala (5 detik).

**Response 200**

```json
{
  "online": true,
  "service": "running",
  "version": "1.3.0",
  "config": {
    "power_mode": "online",
    "lan_mode": "heart",
    "ping_targets": "graph.instagram.com",
    "interval": 5
  },
  "targets": [
    { "host": "graph.instagram.com", "ok": true,  "ms": 18.4 },
    { "host": "8.8.8.8",             "ok": false, "ms": null }
  ]
}
```

| Field | Tipe | Keterangan |
|---|---|---|
| `online` | bool | `true` bila **minimal satu** target merespons |
| `service` | string | `"running"` / `"stopped"` (penanda `hg680pcls-service` di cmdline, fallback `pgrep -f /usr/bin/hg680pcl`) |
| `enabled` | bool | `true` bila service aktif saat boot (ada symlink `/etc/rc.d/*hg680pcls`) |
| `version` | string | versi terpasang dari `VERSION`; `""` bila file tidak ada |
| `config.power_mode` / `config.lan_mode` | string | mode tersimpan (`offline`\|`online`\|`heart`\|`disko`) |
| `config.ping_targets` | string | daftar target, dipisah spasi |
| `config.interval` | number | interval cek (detik) |
| `targets[]` | array | maksimum **8** entri; `ms` = latensi, `null` bila tidak merespons |

Catatan: setiap target di-ping di server (`ping -c 1 -W 1`) memakai `luci.util.shellquote()`,
jadi nilai dari UCI tidak pernah dieksekusi sebagai shell.

---

## `POST /save` — **POST+token**

Simpan setelan lalu restart service. Body `application/x-www-form-urlencoded`.

| Param | Wajib | Validasi |
|---|---|---|
| `token` | ya | token CSRF sesi LuCI |
| `power_mode` | ya | salah satu dari `offline`\|`online`\|`heart`\|`disko` |
| `lan_mode` | ya | idem |
| `interval` | ya | angka 1–60 |
| `ping_targets` | ya | dipisah spasi; maks **8**; tiap token cocok `^[A-Za-z0-9][A-Za-z0-9._:-]*$`, maks 253 char |

**Response 200**

```json
{ "ok": true }
```

**Response 400** (validasi gagal)

```json
{ "ok": false, "error": "target tidak valid: -f" }
```

Pesan lain yang mungkin: `power_mode tidak valid`, `lan_mode tidak valid`,
`interval harus 1-60 detik`, `maksimal 8 target`, `target terlalu panjang: …`,
`ping target tidak boleh kosong`.

**Response 403 / 405** — HTML dari LuCI (`csrftoken` / Method Not Allowed).
Artinya sesi/token tidak valid; dashboard menampilkan pesan "Sesi/CSRF tidak valid — muat ulang halaman LuCI".

---

## `GET /check`

Bandingkan versi terpasang dengan rilis terbaru di GitHub.

Cara kerja: `VERSION` lokal vs **tag `v<versi>` tertinggi** dari `GET api.github.com/repos/<slug>/tags`.
Bila API gagal (offline / rate limit), fallback membaca `VERSION` dari branch `main`.

**Response 200**

```json
{
  "ok": true,
  "local": "1.2.4",
  "remote": "1.3.0",
  "update": true,
  "notes": "- Keamanan: endpoint save & update kini wajib POST + token CSRF.\n- …"
}
```

| Field | Keterangan |
|---|---|
| `local` | versi terpasang (`""` bila belum pernah ada `VERSION`, mis. install lama) |
| `remote` | versi rilis terbaru; `""` bila tidak bisa dicek |
| `update` | `true` bila `remote` berbeda dari `local` |
| `notes` | isi bagian `CHANGELOG.md` untuk versi `remote` (dipotong ~900 char), hanya saat `update` |

---

## `POST /service` — **POST+token**

Nyalakan/matikan service `hg680pcls` dari dashboard (kartu **Service**).

| Param | Wajib | Nilai |
|---|---|---|
| `token` | ya | token CSRF sesi LuCI |
| `action` | ya | `on` (enable autostart + start) atau `off` (stop + disable autostart) |

Yang dijalankan:

| `action` | Perintah |
|---|---|
| `on` | `/etc/init.d/hg680pcls enable` lalu `start` |
| `off` | `/etc/init.d/hg680pcls stop` (LED direset oleh service) lalu `disable` |

**Response 200**

```json
{ "ok": true, "running": true, "enabled": true }
```

**Response 400**

```json
{ "ok": false, "error": "action tidak valid" }
```

**Response 403 / 405** — sama seperti `/save`.

Catatan: `POST /save` tidak menghidupkan service yang sedang nonaktif (restart hanya dijalankan
bila service memang aktif). Installer juga mempertahankan keadaan nonaktif saat reinstall/upgrade.

---

## `POST /update` — **POST+token**

Jalankan installer resmi dari ref rilis, sebagai root — dijalankan **di latar belakang** (detached).

Dipicu oleh dua tombol di dashboard:
- **Install Update** (muncul hanya bila ada versi lebih baru),
- **Pasang ulang** (selalu tersedia — untuk perbaikan, mis. service/LED bermasalah padahal versi sudah terbaru).

Keduanya memanggil endpoint ini tanpa parameter tambahan; ref selalu rilis terbaru.

1. Tolak dulu (409) bila masih ada pemasangan lain yang hidup.
2. Resolve ref = tag `v<versi>` tertinggi (`remote_version()`), fallback `main`.
3. Bersihkan sisa file pemasangan sebelumnya.
4. Lepas skrip installer ke latar belakang (`sh -c … &`, stdin `/dev/null`, stdout/stderr ke log).
   Skrip itu sendiri: menulis PID-nya, `curl` `install.sh` dari ref tersebut ke
   `/tmp/hg680pcls-install.sh`, menjalankannya, lalu menulis exit code.
5. Installer mempertahankan `/etc/config/hg680pcls` (backup ke `/etc/config/hg680pcls.bak`),
   memasang file, dan restart service.

**Body:** `token=<csrf token>` (`application/x-www-form-urlencoded`)

**Response 200** (cepat — installer baru saja dilepas, belum selesai)

```json
{ "ok": true, "started": true, "ref": "v1.4.2", "local": "1.4.1" }
```

| Field | Keterangan |
|---|---|
| `started` | `true` bila installer berhasil dilepas ke latar belakang |
| `ref` | ref yang dipakai (`v1.4.2` atau `main`) |
| `local` | versi terpasang **saat ini** (versi baru baru terlihat di `/updatelog` setelah selesai) |

**Response 409** (masih ada pemasangan berjalan)

```json
{ "ok": false, "error": "instalasi sedang berjalan" }
```

**Response 403 / 405** — sama seperti `/save`.

---

## `GET /updatelog`

Kemajuan pemasangan, dipantau dashboard tiap ~1,5 detik selama installer berjalan (dan sekali saat
halaman dimuat, untuk melanjutkan pemantauan bila halaman di-refresh di tengah pemasangan).

**Response 200**

```json
{
  "ok": true,
  "running": true,
  "done": false,
  "code": null,
  "local": "1.4.1",
  "log": "[HG680PCLS] Ref dipakai: v1.4.2\n→ Downloading VERSION\n…"
}
```

| Field | Keterangan |
|---|---|
| `running` | `true` bila proses installer (PID di `/tmp/hg680pcls-update.pid`) masih hidup |
| `done` | `true` bila exit code sudah ditulis (`/tmp/hg680pcls-update.rc`) — pemasangan selesai |
| `code` | exit code installer (`0` sukses); kosong selama pemasangan berjalan |
| `local` | versi terpasang saat ini (setelah sukses berisi versi baru) |
| `log` | 4000 karakter terakhir `/tmp/hg680pcls-update.log` (diganti utuh tiap poll, bukan tambahan) |

Cara membaca keadaan:

| `running` | `done` | Arti |
|---|---|---|
| `true` | `false` | installer sedang jalan |
| `false` | `true` | selesai — cek `code` (`0` sukses) |
| `false` | `false` | belum pernah dijalankan, atau installer mati sebelum menulis exit code (dashboard memberi tenggang ~15 detik lalu melaporkan "installer tidak berjalan") |

**Response 403** — sesi LuCI tidak valid (endpoint hanya untuk sesi admin).

---

## `POST /uninstall` — **POST+token**

Hapus add-on dari STB (setara menjalankan `uninstall.sh` lewat SSH), dipicu tombol merah **Uninstall**
di baris tombol kartu **Update** (sebelah *Pasang ulang*). Konfirmasi berlapis di dashboard:
`prompt` yang mewajibkan mengetik **HAPUS**.

1. Tolak (409) bila masih ada `update` atau `uninstall` lain yang berjalan.
2. Resolve ref = tag `v<versi>` tertinggi (`remote_version()`), fallback `main`.
3. Unduh `uninstall.sh` dari ref tersebut ke `/tmp/hg680pcls-uninstall.sh` — bila gagal, **belum ada
   file yang dihapus** (502).
4. Lepas ke latar belakang dengan jeda 1 detik (agar respons ini terkirim sebelum file add-on hilang).
   Wrapper menulis PID, menjalankan uninstaller, lalu menulis exit code.

Yang dihapus `uninstall.sh`: `/etc/config/hg680pcls`, `/etc/init.d/hg680pcls`, `/usr/bin/hg680pcl`,
controller, folder view, sisa CBI lama, `/tmp/hg680p_led`. **Backup** `/etc/config/hg680pcls.bak`
sengaja dipertahankan. LED di-reset dan service dihentikan lebih dulu.

**Body:** `token=<csrf token>`

**Response 200** (cepat — uninstaller baru dilepas)

```json
{ "ok": true, "started": true, "ref": "v1.5.2" }
```

**Response 409 / 502**

```json
{ "ok": false, "error": "penghapusan sedang berjalan" }
{ "ok": false, "error": "gagal mengunduh uninstaller dari GitHub" }
```

**Response 403 / 405** — sama seperti `/save`.

---

## `GET /uninstalllog`

Kemajuan penghapusan, dipantau dashboard tiap ~1 detik. **Setelah sukses endpoint ini ikut hilang**
(controller + `/etc/config/hg680pcls` terhapus), jadi dashboard menganggap **HTTP 404 sebagai tanda
berhasil** dan mengalihkan ke halaman utama LuCI.

```json
{ "ok": true, "running": true, "done": false, "code": null, "log": "[HG680PCLS] Removing installation...\n" }
```

| Field | Keterangan |
|---|---|
| `running` | `true` bila proses uninstaller (PID di `/tmp/hg680pcls-uninstall.pid`) masih hidup |
| `done` | `true` bila exit code sudah ditulis (`/tmp/hg680pcls-uninstall.rc`) |
| `code` | exit code uninstaller (`0` sukses) |
| `log` | 2000 karakter terakhir `/tmp/hg680pcls-uninstall.log` |

---

## Keamanan (ringkas)
- `save`, `update`, & `uninstall` = **POST + token CSRF** (dua lapis: dispatcher LuCI + `require_post()`).
- `service` (`action=on|off`) = **POST + token CSRF**, memakai helper yang sama.
- `status`, `check`, `updatelog`, & `uninstalllog` = GET, read-only.
- `/update` & `/uninstall` menjalankan skrip dari GitHub sebagai **root** (detached) — hanya bisa dipicu
  dari sesi admin LuCI yang login (token CSRF + ACL `luci`), satu proses pada satu waktu, dan hanya
  satu dari keduanya (update menolak saat uninstall berjalan, begitu pula sebaliknya).
- `/updatelog` & `/uninstalllog` hanya membaca berkas log/PID/exit-code di `/tmp` — tidak menerima input.
