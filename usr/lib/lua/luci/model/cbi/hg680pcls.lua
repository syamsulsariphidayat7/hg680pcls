-- CBI form: HG680P CLS
-- Halaman pengaturan native LuCI (tombol Save & Apply mengikuti tema).

local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local util = require "luci.util"

local m, s, o

m = Map("hg680pcls", translate("HG680P CLS"),
	translate("Kontrol LED dan pemantau koneksi untuk STB HG680P berbasis OpenWrt."))

-- ------------------------------------------------------------------
-- Panel 1: Mode LED
-- ------------------------------------------------------------------
s = m:section(NamedSection, "settings", "hg680pcls", translate("Mode LED"))
s.addremove = false
s.anonymous = false

o = s:option(ListValue, "power_mode", translate("Mode LED Power"))
o:value("offline", translate("Offline — merah berkedip"))
o:value("online", translate("Online — hijau berkedip"))
o:value("heart", translate("Heart — detak kuning-hijau"))
o:value("disko", translate("Disko — cepat warna-warni"))
o.default = "online"

o = s:option(ListValue, "lan_mode", translate("Mode LED LAN"))
o:value("offline", translate("Offline — merah berkedip"))
o:value("online", translate("Online — hijau berkedip"))
o:value("heart", translate("Heart — detak kuning-hijau"))
o:value("disko", translate("Disko — cepat warna-warni"))
o.default = "heart"

-- Restart service otomatis tiap Save & Apply
m.on_after_commit = function(self)
	sys.call("/etc/init.d/hg680pcls restart >/dev/null 2>&1 &")
end

-- ------------------------------------------------------------------
-- Panel 2: Status Koneksi (ping target + interval + status live)
-- ------------------------------------------------------------------
local function esc(t)
	return (tostring(t):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"):gsub('"', "&quot;"))
end

local function ping_all(hosts)
	local jobs = {}
	for i, host in ipairs(hosts) do
		jobs[#jobs + 1] = string.format(
			"( r=$(ping -c1 -W1 %s 2>/dev/null); "
			.. "ms=$(echo \"$r\" | sed -n 's/.*time=\\([0-9.]*\\).*/\\1/p'); "
			.. "if [ -n \"$ms\" ]; then echo \"%d ok $ms\"; else echo \"%d bad\"; fi ) &",
			util.shellquote(host), i, i)
	end
	local out = sys.exec("{ " .. table.concat(jobs, " ") .. " wait; } 2>/dev/null")
	local res = {}
	for idx, st, ms in out:gmatch("(%d+) (%a+)([^\n]*)") do
		res[tonumber(idx)] = { ok = st == "ok", ms = tonumber(ms) }
	end
	return res
end

local function info_html()
	local targets = uci:get("hg680pcls", "settings", "ping_targets") or "graph.instagram.com"
	local hosts = {}
	for h in targets:gmatch("%S+") do
		hosts[#hosts + 1] = h
		if #hosts >= 8 then break end
	end
	local res = ping_all(hosts)

	local online = false
	local rows = {}
	for i, h in ipairs(hosts) do
		local r = res[i] or {}
		if r.ok then online = true end
		local ms = r.ok and (r.ms and string.format("%.1f ms", r.ms) or "ok") or "timeout"
		rows[#rows + 1] = string.format(
			'<div class="hg-row %s"><span class="hg-tdot"></span>'
			.. '<span class="hg-host">%s</span><span class="hg-ms">%s</span></div>',
			r.ok and "ok" or "bad", esc(h), esc(ms))
	end

	return table.concat({
		'<style>',
		'.hg-big{font-size:24px;font-weight:800;letter-spacing:1px;margin:4px 0 10px}',
		'.hg-big.on{color:#22c55e}.hg-big.off{color:#ef4444}',
		'.hg-row{display:flex;align-items:center;gap:10px;padding:6px 10px;border:1px solid rgba(128,128,128,.4);border-radius:8px;margin-bottom:6px;font-size:13px}',
		'.hg-tdot{width:9px;height:9px;border-radius:50%;flex:none}',
		'.hg-row.ok .hg-tdot{background:#22c55e}.hg-row.bad .hg-tdot{background:#ef4444}',
		'.hg-host{flex:1;font-family:ui-monospace,monospace;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}',
		'.hg-ms{opacity:.7;font-family:ui-monospace,monospace;font-size:12px}',
		'.hg-prev{display:flex;gap:26px;align-items:center;margin-top:12px}',
		'.hg-prev-item{display:flex;align-items:center;gap:8px;font-size:13px}',
		'.hg-led{width:16px;height:16px;border-radius:50%;background:#666;flex:none;display:inline-block}',
		'.hg-led.m-offline{animation:hg-red 1s infinite}',
		'.hg-led.m-online{animation:hg-green 1s infinite}',
		'.hg-led.m-heart{animation:hg-heart 1.2s infinite}',
		'.hg-led.m-disko{animation:hg-disko .45s infinite}',
		'@keyframes hg-red{0%,100%{background:#3a1111;box-shadow:none}50%{background:#ef4444;box-shadow:0 0 10px #ef4444}}',
		'@keyframes hg-green{0%,100%{background:#123322;box-shadow:none}50%{background:#22c55e;box-shadow:0 0 10px #22c55e}}',
		'@keyframes hg-heart{0%,100%{background:#3a1111}30%{background:#f59e0b;box-shadow:0 0 8px #f59e0b}60%{background:#22c55e;box-shadow:0 0 10px #22c55e}}',
		'@keyframes hg-disko{0%{background:#ef4444}33%{background:#f59e0b}66%{background:#22c55e}100%{background:#3b82f6}}',
		'</style>',
		'<div class="hg-big ' .. (online and "on" or "off") .. '">'
			.. (online and "ONLINE" or "OFFLINE") .. '</div>',
		'<div class="hg-rows">' .. table.concat(rows) .. '</div>',
		'<div class="hg-prev">',
		'<div class="hg-prev-item">Power <span class="hg-led" id="hgPrevPower"></span></div>',
		'<div class="hg-prev-item">LAN <span class="hg-led" id="hgPrevLan"></span></div>',
		'</div>',
		'<script>',
		'(function(){',
		'var M={offline:"m-offline",online:"m-online",heart:"m-heart",disko:"m-disko"};',
		'function bind(suf,dotId){',
		'var s=document.querySelector(\'select[name$="\'+suf+\'"]\'),d=document.getElementById(dotId);',
		'if(!s||!d)return;function a(){d.className="hg-led "+(M[s.value]||"");}',
		's.addEventListener("change",a);a();}',
		'function init(){bind("power_mode","hgPrevPower");bind("lan_mode","hgPrevLan");}',
		'if(document.readyState!=="loading")init();else document.addEventListener("DOMContentLoaded",init);',
		'})();',
		'</script>'
	})
end

s = m:section(NamedSection, "settings", "hg680pcls", translate("Status Koneksi"))
s.addremove = false
s.anonymous = false

o = s:option(Value, "ping_targets", translate("Ping target"),
	translate("Pisahkan dengan spasi. Online jika salah satu target merespons."))
o.default = "graph.instagram.com"
o.rmempty = false
o.validate = function(self, value, section)
	if not value or value:gsub("%s", "") == "" then
		return nil, translate("Ping target tidak boleh kosong")
	end
	return value
end

o = s:option(Value, "interval", translate("Interval cek (detik)"))
o.datatype = "range(1,60)"
o.default = "5"

o = s:option(DummyValue, "_status", translate("Status saat ini"))
o.rawhtml = true
o.cfgvalue = function(self, section)
	return info_html()
end

return m
