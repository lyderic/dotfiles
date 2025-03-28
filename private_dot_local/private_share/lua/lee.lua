json = require("dkjson")
f = string.format
xeq = os.execute

-- execute <cmd>, one line
-- returns first line of output as a string
function eo(cmd)
	return io.popen(cmd):read()
end

-- execute <cmd>, multiline
-- returns a function to iterate on e.g.:
-- for line in em("ls") do print(line) end
function em(cmd)
	return io.popen(cmd):lines()
end

-- traditional (C, go) printf
function printf(format, ...)
	io.write(f(format, ...))
end

-- write <content> to <file>
-- by default, overwrite file, don't append newline
-- optional:
--   append   default false, i.e. overwrite
--   newline  default false, i.e. don't add '\n' at the end of file
function writefile(content, file, append, newline)
	local fh = assert(io.open(file, append and "a" or "w"))
	fh:write(content, newline and "\n" or "")
	fh:close()
end

-- read <file> to a string
function readfile(file)
	local fh = assert(io.open(file, "r"))
	output = fh:read("*all")
	fh:close()
	return output
end

-- dump <var> for debugging: show type and json representation
function dump(var)
	printf("=== %s ===\n%s\n", type(var),
		json.encode(var, { indent = true }))
end
