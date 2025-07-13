#!/usr/bin/env -S lua

local leepath = os.getenv("HOME").."/.local/share/lua/?.lua"
package.path = package.path..";"..leepath
require "lee"

local m = {}
local hinfo = json.decode(ea("hostnamectl --json=short status"))

function main()
	init()
	reboot()
	updates()
	diskusage()
	coc()
	print(json.encode(m, { indent = true }))
end

function init()
	m.timestamp = os.time()
	m.hostname = hinfo.Hostname
	if hinfo.HardwareVendor then
		m.hardware = hinfo.HardwareVendor.." "..hinfo.HardwareModel
	end
	m.chassis = hinfo.Chassis
	m.rkernel = knorm(hinfo.KernelRelease)
	m.distro = hinfo.OperatingSystemPrettyName
	m.virt = eo("systemd-detect-virt")
	m.loadavg = io.open("/proc/loadavg"):read("*n")
	m.nproc = tonumber(eo("nproc"))
	m.secondsup = io.open("/proc/uptime"):read("*n")
	m.uptime = dhms(m.secondsup, true)
end

function updates()
	local cmd = "checkupdates | wc -l"
	if m.distro:lower():sub(1,6) == "ubuntu" then
		cmd = "apt list --upgradeable 2>/dev/null | sed 1d | wc -l"
	end
	m.updates = tonumber(eo(cmd))
end

function diskusage()
	m.diskusage = {}
	local just = "just --justfile "..env("HOME").."/justfile"
	local targets = eo(just.." --evaluate targets 2>/dev/null")
	if not targets then targets = "/" end
	local cmd = f("df --output=target,pcent %s | sed 1d", targets)
	for line in e(cmd):lines() do
		mountpoint, pcent = line:match('(%S+)%s+(%S+)')
		m.diskusage[mountpoint] = tonumber(pcent:sub(1,-2))
	::next:: end
end

function reboot()
	if m.mtype == "lxc" then return end
	if m.distro:lower():sub(1,4) == "arch" then
		local cmd = "pacman -Q linux linux-lts"
		cmd = cmd .. " 2>/dev/null | awk '{print $2}'"
		local ikernel = eo(cmd)
		if not ikernel then return end
		m.ikernel = knorm(ikernel)
		if m.rkernel ~= m.ikernel then m.reboot = true end
	elseif m.distro == "ubuntu" then
		if abs("/var/run/reboot-required") then m.reboot = true end
	end
end

function coc()
	if abs("/usr/local/bin/coc") then
		if x("mountpoint -q /pool") then
			m.coc = "loaded"
		else
			m.coc = "unloaded"
		end
	end
end

function knorm(kernel)
	local k = kernel:gsub(".lts","")
	return k:gsub("-",".")
end

main()
