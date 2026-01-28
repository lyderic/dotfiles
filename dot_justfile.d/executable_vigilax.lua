#!/usr/bin/env lua

local leepath = os.getenv("HOME").."/.local/share/lua/?.lua"
package.path = package.path..";"..leepath
require "lee"

local m = {}

function main()
	init()
	reboot()
	updates()
	diskusage()
	coc()
	display()
end

function display()
	local keys = {}
	for key in pairs(m) do table.insert(keys, key) end
	table.sort(keys)
	print(json.encode(m, {
		indent = true,
		keyorder = keys
	}))
end

function init()
	hinfo()
	virt()
	m.fqdn, m.rkernel, m.processor = eo("uname -mnr"):match("(%S+) (%S+) (%S+)")
	m.hostname = m.fqdn:match("([%w%-]+)%.?")
	m.timestamp = os.time()
	m.full=eo("awk -F= '/^PRETTY_NAME=/ { print $2 }' /etc/os-release"):gsub('"','')
	m.distro=eo("awk -F= '/^ID=/ { print $2 }' /etc/os-release")
	m.loadavg = io.open("/proc/loadavg"):read("*n")
	m.nproc = tonumber(eo("nproc"))
	m.secondsup = io.open("/proc/uptime"):read("*n")
	m.uptime = dhms(m.secondsup, true)
end

function hinfo()
	if not x("[ -x /usr/bin/hostnamectl ]") then return end
	local hinfo = json.decode(ea("hostnamectl -j"))
	m.vendor = hinfo.HardwareVendor
	m.model = hinfo.HardwareModel
	m.chassis = hinfo.Chassis
end

function virt()
	if x("[ -x /usr/bin/systemd-detect-virt ]") then
		m.virt = eo("systemd-detect-virt")
		return
	end
	-- If we reach here, then it means that the system
	-- doesn't have systemd. However, we can still try
	-- to detect if it's an LXC container by looking for
	-- the '/dev/.lxc-boot-id' file.
	if abs("/dev/.lxc-boot-id") then
		m.virt = "lxc"
	else
		m.virt = "unknown"
	end
end

function updates()
	local cmd = "echo 0"
	if m.distro == "arch" then
		cmd = "checkupdates | wc -l"
	elseif m.distro == "alpine" then
		cmd = "apk version | grep -c '>'"
	elseif m.distro == "debian" or m.distro == "raspbian" or m.distro == "ubuntu" then
		cmd = "apt list --upgradable 2>/dev/null | grep -c upgradeable"
	elseif m.distro == "fedora" then
		cmd = "dnf check-update -q | wc -l"
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

-- on arch: if running kernel or glibc is different than the
-- installed kernel or glibc, then we want to reboot
function reboot()
	if m.virt == "lxc" then return end
	if m.distro == "arch" then
		local cmd = "pacman -Q linux linux-lts"
		cmd = cmd .. " 2>/dev/null | awk '{print $2}'"
		m.ikernel = eo(cmd)
		if not m.ikernel then return end
		if knorm(m.rkernel) ~= knorm(m.ikernel) then m.reboot = true end
		m.rglibc = tonumber(eo("ldd --version"):match("(%d+%.%d+)"))
		m.iglibc = tonumber(eo("pacman -Q glibc"):match("(%d+%.%d+)"))
		if m.rglibc ~= m.iglibc then m.reboot = true end
	elseif m.distro == "alpine" then
		local fh = e("apk version | grep '>'")
		local _,_,n = fh:close()
		if n > 1 then m.reboot = true end
	elseif m.distro == "debian" or m.distro == "ubuntu" or m.distro == "raspbian" then
		if abs("/var/run/reboot-required") then m.reboot = true end
	elseif m.distro == "fedora" then
		local fh = e("needs-restarting --reboothint")
		local _,_,n = fh:close()
		if n > 0 then m.reboot = true end
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
