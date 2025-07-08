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
	m.mtype = eo("systemd-detect-virt")
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
	if m.mtype == "lxc" then return end
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
	m.updates = tonumber(eo(cmd))
end

function diskusage()
	m.diskusage = {}
	local just = "just --justfile "..env("HOME").."/justfile"
	local targets = eo(just.." --evaluate targets 2>/dev/null")
	if not targets then targets = "/" end
	cmd = "df --output=target,pcent "..targets
	for line in e(cmd):lines() do
		if line:sub(1,1) ~= '/' then goto next end
		local entry = {}
		entry.mountpoint, entry.pcent = line:match('(%S+)%s+(%S+)')
		table.insert(m.diskusage, entry)
	::next:: end
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
