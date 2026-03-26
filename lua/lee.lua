leeversion = "20260326-0"

json = require 'dkjson'

f = string.format
e = io.popen
env = os.getenv

-- same as os.execute, but also allows
-- printf-like input
function x(...)
	return os.execute(f(...))
end

-- execute <cmd>, one line
-- returns first line of output as a string
function eo(...)
	local fh = e(f(...))
	local firstline = fh:read()
	fh:close()
	return firstline
end

-- execute <cmd>, all lines
-- returns all output lines as a string
-- includes final "\n"
function ea(...)
	local fh = e(f(...))
	local output = fh:read("a")
	fh:close()
	return output
end

-- return absolute path or nil
function abs(path)
	return(eo("realpath " .. path))
end

-- check if a command is available
function has(command)
	return x("command -v %q >/dev/null", command)
end

-- traditional (C, go) printf
function printf(...)
	io.write(f(...))
end

-- format <bytes> to human readable e.g. 11825 -> 11.5K
function bfmt(bytes)
	local units = {"B", "K", "M", "G", "T"}
	local uidx = 1
	-- Convert bytes to the appropriate unit
	while bytes >= 1024 and uidx < #units do
		bytes = bytes / 1024
		uidx = uidx + 1
	end
	-- Format the result to one decimal place
	return f("%.1f%s", bytes, units[uidx])
end

-- Thousands separator
-- credit: http://richard.warburton.it
function ths(n)
	local a,b,c = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return a..(b:reverse():gsub('(%d%d%d)','%1,'):reverse())..c
end

-- convert unix epoch seconds to human representation
function dhms(seconds,ignoreseconds)
	local days = math.floor(seconds / 86400)
	seconds = seconds % 86400
	local hours = math.floor(seconds / 3600)
	seconds = seconds % 3600
	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60
	local result = ""
	if days > 0 then
		result = result .. days .. "d"
	end
	if hours > 0 then
		result = result .. hours .. "h"
	end
	if minutes > 0 then
		result = result .. minutes .. "m"
	end
	if not ignoreseconds then
		if seconds > 0 or result == "" then
			result = result .. f("%.0f", seconds) .. "s"
		end
	end
	if result:len() == 0 then result = "<1m" end
	return result
end

-- fnv1 hashing algorithm
function hash(str)
	local FNV_OFFSET_BASIS = 0x811c9dc5
	local FNV_PRIME = 0x01000193
	local hash = FNV_OFFSET_BASIS
	for i = 1, #str do
		hash = hash ~ string.byte(str, i)
		hash = (hash * FNV_PRIME) & 0xFFFFFFFF
	end
	return string.format("%08x", hash)
end

-- dump <var> for debugging: show type and json representation
function dump(var)
	printf("=== %s ===\n%s\n", type(var),
		json.encode(var, { indent = true }))
end

-- show key/values of any table, mainly for debugging
function kv(t)
	if type(t) ~= "table" then return end
	for k,v in pairs(t) do
		print(k,v)
	end
end

-- show lee's reserved words
function leedoc()
	this = debug.getinfo(1, "S").short_src
	x("grep -E '^[a-zA-Z]* = ' " .. this)
	x("grep ^function " .. this)
end
