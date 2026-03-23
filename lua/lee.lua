leeversion = "20260322-3"

json = require 'dkjson'
realpath = require "posix.stdlib".realpath
stat = require "posix.sys.stat"

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
-- wrapper to lua posix's realpath(path)
function abs(path)
	return realpath(path)
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

-- gather most used information about a file into a table
-- if calcsum is 'true', then cksum is calculated
-- but at the cost of a little speed loss
function ffile(file, calcsum)
	local t = {}
	t.path = realpath(file)
	if not t.path then return nil end
	t.file = file
	t.filename = t.path:match(".+/(.+)$")
	t.dirname = t.path:match("^(.+)/")
	t.extension = t.path:match("^.+%.(%g+)$")
	if t.extension then
		t.basename = t.filename:gsub("%."..t.extension.."$", "")
	else
		t.basename = t.filename
	end
	local s = stat.stat(t.path) -- lua posix stat
	t.size = s.st_size
	t.uid, t.gid = s.st_uid, s.st_gid
	t.atime = s.st_atime -- last accessed (read)
	t.mtime = s.st_mtime -- last modified content
	t.ctime = s.st_ctime -- last changed metadata
	t.mode = s.st_mode
	if stat.S_ISDIR(t.mode) > 0 then
		t.isdir = true
	end
	if stat.S_ISREG(t.mode) == 0 then
		return t
	end
	if calcsum then
		local cksum = e(f("cksum %q", t.path))
		local sm = cksum:read("n") cksum:close()
		t.sum = f("%x", tonumber(sm))
	end
	return t
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

-- We're phasing this out in favour of posix's getopt
-- 
-- a nice hacky getopt
-- example usage of this:
-- function main()
--   local opts = getopt("u")
--   if opts.h then usage() return end
--   local user = opts.u and opts.u or "default"
--   local debug = opts.d and true or false
--   print(user, debug)
-- end
--function getopt(o)
--  local p = {}
--  for k,v in ipairs(arg) do
--	if v:byte(1) == 45 then
--	  local l = v:sub(2,2)
--	  if o:match(l) then
--		p[l] = arg[k+1]
--	  else
--		p[l] = true
--	  end
--	end
--  end
--  return p
--end

-- show lee's reserved words
function leedoc()
	this = debug.getinfo(1, "S").short_src
	x("grep -E '^[a-zA-Z]* = ' " .. this)
	x("grep ^function " .. this)
end
