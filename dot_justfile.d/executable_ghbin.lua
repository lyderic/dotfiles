#!/usr/bin/env -S lua

local leepath = os.getenv("HOME").."/.local/share/lua/?.lua"
package.path = package.path..";"..leepath
require "lee"

-- GLOBALS
url = "https://lola.lyderic.com"

function main()
	if not valid() then os.exit(42) end
	local cmd = f("curl -sL %s/cgi-bin/state", url)
	local state = json.decode(ea(cmd))
	for _,i in ipairs(state) do
		printf("\27[1m%-8.8s  \27[m", i.binary..":")
		local c = get_situation(i.binary)
		if not c then goto next end
		if c.parent ~= "/usr/local/bin/" then
			printf("\27[90mskipped as found in %q\27[m\n", c.parent)
			goto next
		end
		if c.cksum == i.cksum and c.size == i.size then
			printf("\27[90mup to date (sum=%s, size=%s)\27[m\n",
			c.cksum, c.size)
		else
			print("\27[32mupdate available\27[m")
			deploy(i.binary)
		end
	::next::end
end

-- get situation of a binary on the host, i.e.path, parent, cksum
-- and size
-- if a binary is not found, it is deployed
function get_situation(binary)
	local t = {} -- local situation on host
	t.binary = binary
	t.path = eo("command -v "..binary)
	if not t.path then
		printf("\27[33m%s: binary not found\n\27[m", binary)
		deploy(binary)
		return nil
	end
	t.parent = t.path:match(".*/")
	t.cksum, t.size = eo("cksum "..t.path):match("(%d+) (%d+)")
	return t
end

-- if binary not installable with pacman, then get binary from lola
-- and put it in /usr/local/bin
-- if binary already found in /usr/local/bin, it is overwritten
function deploy(binary)
	printf("\27[7m %s \27[m", binary)
	if pacman(binary) then return end
	local gz = binary..".gz"
	local curl_cmd = f("curl -s -L -o %q %s/gz/%s", "/tmp/"..gz, url, gz)
	print("---> [XeQ] ", curl_cmd)
	if not x(curl_cmd) then return end
	if not x("gzip -d /tmp/"..gz) then return end
	local dst="/usr/local/bin/"..binary
	if not x(f("sudo mv -v %q %q", "/tmp/"..binary, dst)) then return end
	if not x("sudo chown -v 0:0 "..dst) then return end
	if not x("sudo chmod -v 0755 "..dst) then return end
end

-- try to install binary with pacman
function pacman(binary)
	if not x("command -v pacman") then return false end
	print("---> trying pacman...")
	return x("sudo pacman -S --needed "..binary)
end

function valid()
	-- This works only on amd64!
	local validcpu = "x86_64"
	local cpu = eo("uname -m")
	if cpu == validcpu then
		return true
	else
		printf("\27[31m%s: invalid cpu (valid is: %s)\n", cpu, validcpu)
		return false
	end
end

main()
