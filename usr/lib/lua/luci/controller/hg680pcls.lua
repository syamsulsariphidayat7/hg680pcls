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
        call("action_save")).leaf = true
    entry({"admin", "services", "hg680pcls", "check"},
        call("action_check")).leaf = true
    entry({"admin", "services", "hg680pcls", "update"},
        call("action_update")).leaf = true
end

local MODES = { offline = true, online = true, heart = true, disko = true }

local REPO_RAW = "https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main"
local VERSION_FILE = "/usr/lib/lua/luci/view/hg680pcls/VERSION"

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

local function remote_version()
    local out = luci.sys.exec(string.format(
        "curl -fsSL --connect-timeout 6 --max-time 12 %s/VERSION 2>/dev/null",
        REPO_RAW))
    return (out or ""):gsub("%s+", "")
end

local REPO_RAW = "https://raw.githubusercontent.com/syamsulsariphidayat7/hg680pcls/main"
local VERSION_FILE = "/usr/lib/lua/luci/view/hg680pcls/VERSION"

local function get_config()
    local uci = luci.model.uci.cursor()
    return {
        power_mode   = uci:get("hg680pcls", "settings", "power_mode") or "online",
        lan_mode     = uci:get("hg680pcls", "settings", "lan_mode") or "heart",
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
        if #hosts >= 8 then break end
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
    local http = luci.http
    local power_mode   = http.formvalue("power_mode")
    local lan_mode     = http.formvalue("lan_mode")
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
    if not (interval and interval >= 1 and interval <= 60) then
        return bad("interval harus 1-60 detik")
    end
    if ping_targets == "" then
        return bad("ping target tidak boleh kosong")
    end

    local uci = luci.model.uci.cursor()
    uci:set("hg680pcls", "settings", "power_mode", power_mode)
    uci:set("hg680pcls", "settings", "lan_mode", lan_mode)
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
    local rv = remote_version()
    luci.http.prepare_content("application/json")
    luci.http.write(luci.jsonc.stringify({
        ok        = true,
        ["local"] = lv,
        remote    = rv,
        update    = (rv ~= "" and rv ~= lv),
    }))
end

function action_update()
    local http = luci.http
    http.prepare_content("application/json")

    local function fail(msg)
        http.write(luci.jsonc.stringify({ ok = false, error = msg }))
    end

    if http.getenv("REQUEST_METHOD") ~= "POST" then
        http.status(405, "Method Not Allowed")
        return fail("POST required")
    end

    local logfile = "/tmp/hg680pcls-update.log"
    local cmd = string.format(
        "sh -c \"$(curl -fsSL %s/install.sh)\" >%s 2>&1",
        REPO_RAW, logfile)
    local rc = luci.sys.call(cmd)

    http.write(luci.jsonc.stringify({
        ok        = rc == 0,
        code      = rc,
        ["local"] = local_version(),
        log       = read_tail(logfile, 4000),
    }))
end
