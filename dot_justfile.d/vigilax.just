vigilax-version := "202504081338"

[private]
vigilax-reboot:
	#!/usr/bin/env lua
	require "lee"
	hcolor = "\27[1m"; high = "\27[1;7;33m"; noc = "\27[m"
	hostname = eo("hostname -s")
	-- no need to run this if the machine is a container
	if eo("tail -c 4 /proc/self/cgroup") == "lxc" then
		goto display
	end
	if "{{distro}}" == "arch" then
		k = "linux"
		r = eo("uname -r | tr '-' '.'")
		if string.sub(r, -3) == "lts" then k = k.."-lts" end
		i = eo(f("pacman -Q %s | awk '{print $2}' | tr '-' '.'", k))
		if not r == i then hcolor = high end
	elseif "{{distro}}" == "ubuntu" then
		if abs("/var/run/reboot-required") then hcolor = high end
	end
	::display::
	printf(hcolor..hostname..noc)

[private]
vigilax-uptime *t:
	#!/usr/bin/env lua
	require("lee")
	s = io.open("/proc/uptime"):read("*n")
	d = math.floor(s/(24*60* 60)); s = s%(24*60*60)
	h = math.floor(s/(60 * 60)); s = s%(60*60); m = math.floor(s/60)
	color = "\27[90m"
	if d > 7 then color = "\27[m"
	elseif d > 15 then color = "\27[93m"
	elseif d > 30 then color = "\27[91m" end
	if "{{t}}" == "t" then
		format = "%s% 4dd% 3dh% 3dm\27[m "
		printf(format, color, d, h, m)
	else
		format = "%s%s%s%s\27[m "
		printf(format, color, d > 0 and d.."d" or "",
			h > 0 and h.."h" or "", m > 0 and m.."m" or "")
	end

[private]
vigilax-updates *t:
	#!/usr/bin/env lua
	require("lee")
	-- we track this metric only for arch, as this is the only
	-- rolling distribution we use
	if "{{distro}}" ~= "arch" then
		printf("\27[2;36m---\27[m ")
		os.exit(0)
	end
	n = 0
	for line in e("checkupdates"):lines() do n = n + 1 end
	color = "\27[90m"; noc = "\27[m"
	if n > 5 then color = noc
	elseif n > 20 then color = "\27[93m"
	elseif n > 50 then color = "\27[91m"
	end
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
	hcolor = "\27[1;32m"; noc = "\27[m"
	if not x("mountpoint -q /pool") then hcolor = "\27[1;33m" end
	printf(" %sCOC%s ", hcolor, noc)
