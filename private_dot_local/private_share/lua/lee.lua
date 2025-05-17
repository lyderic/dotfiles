json = require("dkjson")
f = string.format
x = os.execute
e = io.popen
env = os.getenv

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
function printf(format, ...)
	io.write(f(format, ...))
end

-- if <path> exists, return absolute path
-- otherwise, return false
function abs(path)
	local output = eo("readlink -e " .. path)
	if output == nil then
		return false
	else
		return output
	end
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

-- write <content> to <file>
-- by default, overwrite file, don't append newline
-- optional:
--   append   default false, i.e. overwrite
--   newline  default false, i.e. don't add '\n' at the end of file
function writefile(file, content, append, newline)
	local fh = assert(io.open(file, append and "a" or "w"))
	fh:write(content, newline and "\n" or "")
	fh:close()
end

-- read <file> to a string
function readfile(file)
	local fh = assert(io.open(file))
	output = fh:read("*all")
	fh:close()
	return output
end

-- dump <var> for debugging: show type and json representation
function dump(var)
	printf("=== %s ===\n%s\n", type(var),
		json.encode(var, { indent = true }))
end
