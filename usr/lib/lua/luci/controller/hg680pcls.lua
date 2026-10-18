module("luci.controller.hg680pcls", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/hg680pcls") then
        return
    end
    entry({"admin", "services", "hg680pcls"},
        template("hg680pcls/dashboard"), "HG680P CLS", 90)
    entry({"admin", "services", "hg680pcls", "status"},
        call("action_status")).leaf = true
    entry({"admin", "services", "hg680pcls", "save"},
        post("action_save")).leaf = true
    entry({"admin", "services", "hg680pcls", "check"},
        call("action_check")).leaf = true
    entry({"admin", "services", "hg680pcls", "update"},
        post("action_update")).leaf = true
end

local MODES = { offline = true, online = true, heart = true, disko = true }
-- LED ketiga (tunggal) tidak punya offline/online karena hanya satu pin.
local STATUS_MODES = { off = true, on = true, heart = true, disko = true }

local MAX_TARGETS = 8
local REPO_SLUG = "syamsulsariphidayat7/hg680pcls"
local REPO_RAW  = "https://raw.githubusercontent.com/" .. REPO_SLUG
local REPO_API  = "https://api.github.com/repos/" .. REPO_SLUG
local VERSION_FILE = "/usr/lib/lua/luci/view/hg680pcls/VERSION"

-- Wajib POST + token CSRF yang sah (dipakai LuCI). Return false kalau ditolak;
-- respons error sudah dikirim oleh LuCI, jadi pemanggil cukup `return`.
local function require_post()
    local disp = luci.dispatcher
    if disp and disp.test_post_security then
        return disp.test_post_security()
    end
    if luci.http.getenv("REQUEST_METHOD") ~= "POST" then
        luci.http.status(405, "Method Not Allowed")
        return false
    end
    local tok  = luci.http.formvalue("token")
    local want = disp and disp.context and disp.context.authtoken
    if tok and want and tok == want then
        return true
    end
    luci.http.status(403, "Forbidden")
    return false
end

-- Validasi target ping: cegah injeksi shell (dipakai loop `for host in $targets`
-- di init.d) & opsi ping (token diawali '-').
local function valid_targets(s)
    local n = 0
    for tok in s:gmatch("%S+") do
        n = n + 1
        if n > MAX_TARGETS then
            return nil, "maksimal " .. MAX_TARGETS .. " target"
        end
        if #tok > 253 then
            return nil, "target terlalu panjang: " .. tok
        end
        if not tok:match("^[A-Za-z0-9][A-Za-z0-9%.%-%:_]*$") then
            return nil, "target tidak valid: " .. tok
        end
    end
    if n == 0 then
        return nil, "ping target tidak boleh kosong"
    end
    return true
end

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local data = f:read("*a")
    f:close()
    return data
end

local function read_tail(path, max)
    local f = io.open(path, "rb")
    if not f then return "" end
    local size = f:seek("end") or 0
    local off = size - max
    if off < 0 then off = 0 end
    f:seek("set", off)
    local data = f:read("*a") or ""
    f:close()
    return data
end

local function local_version()
    local v = read_file(VERSION_FILE)
    if not v then return "?" end
    v = v:gsub("%s+", "")
    if v == "" then return "?" end
    return v
end

-- Versi terbaru = tag rilis tertinggi (tag dinamai v<versi>).
-- Tidak memakai /releases/latest karena repo ini tidak selalu punya "Release".
local function remote_version()
    local out = luci.sys.exec(string.format(
        "curl -fsSL --connect-timeout 6 --max-time 12 '%s/tags?per_page=100' 2>/dev/null",
        REPO_API))
    local best, bestnum
    for v in (out or ""):gmatch('"name"%s*:%s*"v([0-9][0-9%.%-]*)"') do
        local a, b, c = v:match("^(%d+)%.(%d+)%.(%d+)")
        if a then
            local num = tonumber(a) * 1000000 + tonumber(b) * 1000 + tonumber(c)
            if not bestnum or num > bestnum then
                bestnum, best = num, v
            end
        end
    end
    if best then
        return best, ("v" .. best)
    end
    -- Fallback (API dibatasi / offline): baca VERSION dari branch main
    local fb = luci.sys.exec(string.format(
        "curl -fsSL --connect-timeout 6 --max-time 12 %s/main/VERSION 2>/dev/null",
        REPO_RAW))
    return (fb or ""):gsub("%s+", ""), "main"
end

-- Catatan rilis: ambil bagian CHANGELOG.md untuk versi tsb dari ref rilis.
local function changelog_notes(ver, ref)
    if not ver or ver == "" or not ref then return "" end
    local txt = luci.sys.exec(string.format(
        "curl -fsSL --connect-timeout 6 --max-time 12 %s/%s/CHANGELOG.md 2>/dev/null",
        REPO_RAW, ref))
    if not txt or txt == "" then return "" end
    local out, on = {}, false
    for line in (txt .. "\n"):gmatch("([^\n]*)\n") do
        if line:match("^##%s") then
            if on then break end
            local v = line:gsub("^##%s*", ""):gsub("[%[%]]", ""):match("^([%w%.%-]+)")
            if v == ver then on = true end
        elseif on and line:match("%S") then
            out[#out + 1] = line
        end
    end
    local s = table.concat(out, "\n")
    if #s > 900 then s = s:sub(1, 900) .. "\n…" end
    return s
end

local function get_config()
    local uci = luci.model.uci.cursor()
    return {
        power_mode   = uci:get("hg680pcls", "settings", "power_mode") or "online",
        lan_mode     = uci:get("hg680pcls", "settings", "lan_mode") or "heart",
        status_mode  = uci:get("hg680pcls", "settings", "status_mode") or "heart",
        ping_targets = uci:get("hg680pcls", "settings", "ping_targets") or "graph.instagram.com",
        interval     = tonumber(uci:get("hg680pcls", "settings", "interval")) or 5,
    }
end

local function ping_check_all(hosts)
    local jobs = {}
    for i, host in ipairs(hosts) do
        jobs[#jobs + 1] = string.format(
            "( r=$(ping -c1 -W1 %s 2>/dev/null); "
            .. "ms=$(echo \"$r\" | sed -n 's/.*time=\\([0-9.]*\\).*/\\1/p'); "
            .. "if [ -n \"$ms\" ]; then echo \"%d ok $ms\"; else echo \"%d bad\"; fi ) &",
            luci.util.shellquote(host), i, i)
    end
    local out = luci.sys.exec("{ " .. table.concat(jobs, " ")
        .. " wait; } 2>/dev/null")
    local results = {}
    for idx, status, ms in out:gmatch("(%d+) (%a+)([^\n]*)") do
        results[tonumber(idx)] = { ok = status == "ok", ms = tonumber(ms) }
    end
    return results
end

local function service_running()
    return luci.sys.call(
        "pgrep -f '/usr/bin/hg680pcl' >/dev/null 2>&1") == 0
end

function action_status()
    local cfg = get_config()
    local hosts = {}
    for host in cfg.ping_targets:gmatch("%S+") do
        hosts[#hosts + 1] = host
        if #hosts >= MAX_TARGETS then break end
    end
    local res = ping_check_all(hosts)
    local targets = {}
    local online = false
    for i, host in ipairs(hosts) do
        local r = res[i] or {}
        if r.ok then online = true end
        targets[#targets + 1] = { host = host, ok = r.ok or false, ms = r.ms }
    end
    luci.http.prepare_content("application/json")
    luci.http.write(luci.jsonc.stringify({
        online  = online,
        service = service_running() and "running" or "stopped",
        version = local_version(),
        config  = cfg,
        targets = targets,
    }))
end

function action_save()
    if not require_post() then
        return
    end

    local http = luci.http
    local power_mode   = http.formvalue("power_mode")
    local lan_mode     = http.formvalue("lan_mode")
    local status_mode  = http.formvalue("status_mode")
    local interval     = tonumber(http.formvalue("interval"))
    local ping_targets = (http.formvalue("ping_targets") or "")
        :gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

    local function bad(msg)
        http.status(400, "Bad Request")
        http.prepare_content("application/json")
        http.write(luci.jsonc.stringify({ ok = false, error = msg }))
    end

    if not (power_mode and MODES[power_mode]) then
        return bad("power_mode tidak valid")
    end
    if not (lan_mode and MODES[lan_mode]) then
        return bad("lan_mode tidak valid")
    end
    -- status_mode opsional: installasi lama belum punya setelan ini
    if status_mode ~= nil and status_mode ~= "" and not STATUS_MODES[status_mode] then
        return bad("status_mode tidak valid")
    end
    if not (interval and interval >= 1 and interval <= 60) then
        return bad("interval harus 1-60 detik")
    end
    if ping_targets == "" then
        return bad("ping target tidak boleh kosong")
    end
    local ok_t, err_t = valid_targets(ping_targets)
    if not ok_t then
        return bad(err_t)
    end

    local uci = luci.model.uci.cursor()
    uci:set("hg680pcls", "settings", "power_mode", power_mode)
    uci:set("hg680pcls", "settings", "lan_mode", lan_mode)
    if status_mode ~= nil and status_mode ~= "" then
        uci:set("hg680pcls", "settings", "status_mode", status_mode)
    end
    uci:set("hg680pcls", "settings", "interval", tostring(interval))
    uci:set("hg680pcls", "settings", "ping_targets", ping_targets)
    uci:commit("hg680pcls")

    luci.sys.call("/etc/init.d/hg680pcls restart >/dev/null 2>&1 &")

    http.prepare_content("application/json")
    http.write(luci.jsonc.stringify({ ok = true }))
end

-- ===================== Update dari GitHub =====================

function action_check()
    local lv = local_version()
    local rv, ref = remote_version()
    local has_update = (rv ~= "" and rv ~= lv)
    luci.http.prepare_content("application/json")
    luci.http.write(luci.jsonc.stringify({
        ok        = true,
        ["local"] = lv,
        remote    = rv,
        update    = has_update,
        notes     = has_update and changelog_notes(rv, ref) or "",
    }))
end

function action_update()
    if not require_post() then
        return
    end

    local http = luci.http
    http.prepare_content("application/json")

    -- Ambil installer dari ref rilis terbaru (fallback: main) supaya isi
    -- yang dipasang konsisten dengan versi yang diumumkan.
    local _, ref = remote_version()
    if not ref or ref == "" then ref = "main" end

    local logfile = "/tmp/hg680pcls-update.log"
    local cmd = string.format(
        "sh -c \"$(curl -fsSL %s/%s/install.sh)\" >%s 2>&1",
        REPO_RAW, ref, logfile)
    local rc = luci.sys.call(cmd)

    http.write(luci.jsonc.stringify({
        ok        = rc == 0,
        code      = rc,
        ref       = ref,
        ["local"] = local_version(),
        log       = read_tail(logfile, 4000),
    }))
end
