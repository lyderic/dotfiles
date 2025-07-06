#!/usr/bin/env lua

local leepath = os.getenv("HOME").."/.local/share/lua/?.lua"
package.path = package.path..";"..leepath

require "lee"
utsname = require "posix.sys.utsname"

local m = {}

function main()
	init()
	reboot()
	uptime()
	updates()
	diskusage()
	coc()
	local content = json.encode(m, { indent = true })
	print(content)
end

function init()
	unameinfo = utsname.uname()
	m.hostname = unameinfo.nodename
	running_kernel = unameinfo.release
	running_kernel = running_kernel:gsub(".lts","")
	m.rkernel = running_kernel:gsub("-",".")
	m.distro = distro()
end

function distro()
	local fh = io.open("/etc/os-release")
	for line in fh:lines() do
		if line:match("^ID=") then
			d = line:sub(4):gsub('"', '') fh:close() break
		end
	end
	return d
end

function reboot()
	m.reboot = false
	if m.distro == "arch" then
		local cmd = "pacman -Q linux linux-lts"
		cmd = cmd .. " 2>/dev/null | awk '{print $2}'"
		local output = eo(cmd)
		if not output then return end
		m.ikernel = output:gsub("-",".")
		if m.rkernel ~= m.ikernel then m.reboot = true end
	elseif m.distro == "ubuntu" then
		if abs("/var/run/reboot-required") then m.reboot = true end
	end
end

function uptime()
	secs = io.open("/proc/uptime"):read("*n")
	m.secondsup = secs
	days = math.floor(secs/(24*60* 60)); secs = secs%(24*60*60)
	hours = math.floor(secs/(60 * 60)); secs = secs%(60*60); mins = math.floor(secs/60)
	format = "%s%s%s"
	m.uptime = f(format,
		days > 0 and days.."d" or "",
		hours > 0 and hours.."h" or "",
		mins > 0 and mins.."m" or "")
end

function updates()
	local cmd = "checkupdates | wc -l"
	if m.distro == "ubuntu" then
		cmd = "apt list --upgradeable 2>/dev/null | sed 1d | wc -l"
	end
	m.updates = eo(cmd)
end

function diskusage()
	local global_justfile = env("HOME").."/justfile"
	local targets = eo("just --justfile "..global_justfile.." --evaluate targets 2>/dev/null")
	if not targets then targets = "/" end
	cmd = f("df --output=target,size,used %s | sed 1d", targets)
	for line in e(cmd):lines() do
		t = {}
		for b in line:gmatch("%S+") do
			table.insert(t,b)
		end; target = t[1]; size = t[2]; used = t[3]
		pcent = (used / size) * 100
		m.diskusage = m.diskusage or ""
		usage = f("[%s:%2.f%%]", target, pcent+1)
		m.diskusage = m.diskusage..usage
	end
end

function coc()
	m.coc = "n/a"
	if abs("/usr/local/bin/coc") then
		if x("mountpoint -q /pool") then
			m.coc = "loaded"
		else
			m.coc = "unloaded"
		end
	end
end

main()
