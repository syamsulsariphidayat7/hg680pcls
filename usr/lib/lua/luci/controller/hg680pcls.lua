module("luci.controller.hg680pcls", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/hg680pcls") then
        return
    end
    entry({"admin", "services", "hg680pcls"}, cbi("hg680pcls"),
        _("HG680P CLS"), 90).leaf = true
end
