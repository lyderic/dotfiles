leeversion = "202507070652"

json = require 'dkjson'
P = require 'posix.compat'
S = require 'posix.stdlib'
U = require 'posix.unistd'

f = string.format
x = os.execute
e = io.popen
env = os.getenv
setenv = S.setenv
abs = S.realpath
mkdir = P.mkdir
chdir = P.chdir

-- execute <cmd>, one line
-- returns first line of output as a string
function eo(cmd)
	return e(cmd):read()
end

-- execute <cmd>, all lines
-- returns all output lines as a string
-- includes final "\n"
function ea(cmd)
	return e(cmd):read("*a")
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

-- dump <var> for debugging: show type and json representation
function dump(var)
	printf("=== %s ===\n%s\n", type(var),
		json.encode(var, { indent = true }))
end

-- show key/values of any table, mainly for debugging
function kv(t)
	if not type(t) == "table" then return end
	for k,v in pairs(t) do
		print(k,v)
	end
end

-- a nice hacky getopt
-- example usage of this:
-- function main()
--   local opts = getopt("f")
--   if opts.h then usage() return end
--   local user = opts.u and opts.u or "default"
--   local debug = opts.d and true or false
--   print(user, debug)
-- end
function getopt(o)
  local p = {}
  for k,v in ipairs(arg) do
    if v:byte(1) == 45 then
      local l = v:sub(2,2)
      if o:match(l) then
        p[l] = arg[k+1]
      else
        p[l] = true
      end
    end
  end
  return p
end

-- show lee's reserved words
function leedoc()
	this = debug.getinfo(1, "S").short_src
	x("grep -E '^[a-zA-Z]* = ' " .. this)
	x("grep ^function " .. this)
end
