vigilax-version := "202504161852"

[private]
vigilax-reboot *t:
	#!/usr/bin/env lua
	require "lee"
	color = "\27[1m"; high = "\27[1;33m"; noc = "\27[m"
	hostname = eo("hostname -s")
	if "{{distro}}" == "arch" then
		k = "linux"
		r = eo("uname -r | tr '-' '.'")
		if string.sub(r, -3) == "lts" then
			k = k.."-lts"
			r = r:gsub(".lts","")
		end
		i = eo(f("pacman -Q %s 2>/dev/null | awk '{print $2}' | tr '-' '.'", k))
		-- no need to run this if the machine is a container
		if i == nil then goto display end
		if r ~= i then color = high end
	elseif "{{distro}}" == "ubuntu" then
		if abs("/var/run/reboot-required") then color = high end
	end
	::display::
	if "{{t}}" == "t" then
		printf("%s%-10.10s%s", color, hostname, noc)
	else
		printf("%s%s%s ", color, hostname, noc)
	end

[private]
vigilax-uptime *t:
	#!/usr/bin/env lua
	require("lee")
	s = io.open("/proc/uptime"):read("*n")
	d = math.floor(s/(24*60* 60)); s = s%(24*60*60)
	h = math.floor(s/(60 * 60)); s = s%(60*60); m = math.floor(s/60)
	color = "\27[90m"; noc = "\27[m"
	if d > 7 then color = noc end
	if d > 15 then color = "\27[93m" end
	if d > 30 then color = "\27[91m" end
	if "{{t}}" == "t" then
		format = "% 4dd% 3dh% 3dm "
		display = f(format, d, h, m)
	else
		format = "%s%s%s "
		display = f(format, d > 0 and d.."d" or "",
			h > 0 and h.."h" or "", m > 0 and m.."m" or "")
	end
	printf(color..display..noc)

[private]
vigilax-updates:
	#!/usr/bin/env lua
	require("lee")
	if "{{distro}}" == "arch" then
		cmd = "checkupdates | wc -l"
	elseif "{{distro}}" == "ubuntu" then
		cmd = "apt list --upgradeable 2>/dev/null | sed 1d | wc -l"
	else
		printf("---"); os.exit(0)
	end
	n = tonumber(eo(cmd))
	color = "\27[90m"; noc = "\27[m"
	if n > 5 then color = noc end
	if n > 20 then color = "\27[33m" end
	if n > 50 then color = "\27[91m" end
	printf("%s%03d%s ", color, n, noc)

[private]
vigilax-diskusage:
	#!/usr/bin/env lua
	require("lee")
	targets = env("targets")
	if not targets then targets = "/" end
	cmd = f("df --output=target,size,used %s | sed 1d", targets)
	for line in e(cmd):lines() do
		t = {}
		for b in line:gmatch("%S+") do
			table.insert(t,b)
		end; target = t[1]; size = t[2]; used = t[3]
		pcent = (used / size) * 100
		color = "\27[90m"; noc = "\27[m"
		if pcent > 50 then color = noc
		elseif pcent > 75 then color = "\27[93m"
		elseif pcent > 90 then color = "\27[91m"
		end
		printf("[%s%s:%2.f%%%s]", color, target, pcent+1, noc)
	end

[private]
vigilax-coc:
	#!/usr/bin/env lua
	require "lee"
	if not abs("/usr/local/bin/coc") then os.exit(0) end
	color = "\27[1;32m"; noc = "\27[m"
	if not x("mountpoint -q /pool") then color = "\27[1;33m" end
	printf(" %sCOC%s ", color, noc)
