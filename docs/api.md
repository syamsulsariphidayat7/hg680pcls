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
    "status_mode": "heart",
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
| `service` | string | `"running"` / `"stopped"` (`pgrep -f /usr/bin/hg680pcl`) |
| `version` | string | versi terpasang dari `VERSION`; `""` bila file tidak ada |
| `config.power_mode` / `config.lan_mode` | string | mode tersimpan (`offline`\|`online`\|`heart`\|`disko`) |
| `config.status_mode` | string | mode LED ketiga (`off`\|`on`\|`heart`\|`disko`) |
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
| `status_mode` | tidak | salah satu dari `off`\|`on`\|`heart`\|`disko`; dilewati bila kosong/absen (installasi lama) |
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

Pesan lain yang mungkin: `power_mode tidak valid`, `lan_mode tidak valid`, `status_mode tidak valid`,
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

## `POST /update` — **POST+token**

Jalankan installer resmi dari ref rilis, sebagai root.

Dipicu oleh dua tombol di dashboard:
- **Install Update** (muncul hanya bila ada versi lebih baru),
- **Pasang ulang** (selalu tersedia — untuk perbaikan, mis. service/LED bermasalah padahal versi sudah terbaru).

Keduanya memanggil endpoint ini tanpa parameter tambahan; ref selalu rilis terbaru.

1. Resolve ref = tag `v<versi>` tertinggi (`remote_version()`), fallback `main`.
2. `curl` `install.sh` dari ref tersebut lalu jalankan (`sh -c`), output ke `/tmp/hg680pcls-update.log`.
3. Installer mempertahankan `/etc/config/hg680pcls`, backup ke `/etc/config/hg680pcls.bak`,
   memasang file, dan restart service.

**Body:** `token=<csrf token>` (`application/x-www-form-urlencoded`)

**Response 200**

```json
{
  "ok": true,
  "code": 0,
  "ref": "v1.3.0",
  "local": "1.3.0",
  "log": "[HG680PCLS] Ref dipakai: v1.3.0\n…"
}
```

| Field | Keterangan |
|---|---|
| `ok` | `true` bila exit code installer `0` |
| `code` | exit code installer |
| `ref` | ref yang dipakai (`v1.2.3` atau `main`) |
| `local` | versi terpasang **setelah** installer selesai |
| `log` | 4000 karakter terakhir `/tmp/hg680pcls-update.log` |

**Response 403 / 405** — sama seperti `/save`.

---

## Keamanan (ringkas)
- `save` & `update` = **POST + token CSRF** (dua lapis: dispatcher LuCI + `require_post()`).
- `status` & `check` = GET, read-only.
- `/update` menjalankan installer sebagai **root** — hanya bisa dipicu dari sesi admin LuCI
  yang login (token CSRF + ACL `luci`).
