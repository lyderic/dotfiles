f = string.format
xeq = os.execute

function eo(cmd)
	return io.popen(cmd):read()
end

function printf(format, ...)
	io.write(f(format, ...))
end

function dump(t)
	for k,v in pairs(t) do print(k,v) end
end

function ok(message)
	printf("\27[32m%s\27[m\n", message)
end
