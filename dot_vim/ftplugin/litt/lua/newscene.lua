local e = io.popen
local grepcmd = "grep -siIrhoE '^\\[//[0-9a-f]{4}\\]' *"
local gencmd = "uuidgen | head -c4"

-- for practical reasons, id is in the form: '[//xxxx]', eg: [//143f]
function main()
	::begin::
	local uuid = e(gencmd):read()
	local id = '[//'..uuid..']'
	-- we check that there is no uuid collision as the uuid is too
	-- short (only 4 chars). uuid is short because we want to be able
	-- to type it quickly if needed.
	for existing_id in e(grepcmd):lines() do
		if existing_id == id then goto begin end
	end
	vim.command("normal o"..id..": # (")
	vim.command("startinsert!")
end

main()
