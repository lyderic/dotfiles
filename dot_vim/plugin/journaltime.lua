function main()
	if vim.b.langnr > #lang or vim.b.langnr < 1 then
		usage()
		return
	end
	local now = os.date("*t", os.time())
	local message = localise(lang[vim.b.langnr], now)
	local b = vim.buffer()
	local pos = vim.window().line
	-- if current line not empty, we insert a new line first
	if vim.line() ~= "" then
		b:insert("", pos)
		b:insert(message, pos + 1)
		vim.command("normal }jo")
	else
		b:insert(message, pos)
		vim.command("normal jo")
	end
end

function usage()
	print("select one of: 1=fr 2=de 3=en 4=es")
end

function localise(l, d)
	return string.format("# %s %d %s %d %02d:%02d",
		l.wdays[d.wday], d.day, l.months[d.month], d.year, d.hour, d.min)
end

lang = {
	-- 1: French
	{
		wdays = {
			"Dimanche",
			"Lundi",
			"Mardi",
			"Mercredi",
			"Jeudi",
			"Vendredi",
			"Samedi",
		},
		months = {
			"janvier",
			"février",
			"mars",
			"avril",
			"mai",
			"juin",
			"juillet",
			"août",
			"septembre",
			"octobre",
			"novembre",
			"décembre"
		},
	},
	-- 2: German
	{
		wdays = {
			"Sonntag",
			"Montag",
			"Dienstag",
			"Mittwoch",
			"Donnerstag",
			"Freitag",
			"Samstag"
		},
		months = {
			"Januar",
			"Februar",
			"März",
			"April",
			"Mai",
			"Juni",
			"Juli",
			"August",
			"September",
			"Oktober",
			"November",
			"Dezember",
		},
	},
	-- 3: English
	{
		wdays = {
			"Sunday",
			"Monday",
			"Tuesday",
			"Wednesday",
			"Thursday",
			"Friday",
			"Saturday",
		},
		months = {
			"January",
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December",
		},
	},
	-- 4: Spanish
	{
		wdays = {
			"Domingo",
			"Lunes",
			"Martes",
			"Miércoles",
			"Jueves",
			"Viernes",
			"Sábado",
		},
		months = {
			"enero",
			"febrero",
			"marzo",
			"abril",
			"mayo",
			"junio",
			"julio",
			"agosto",
			"septiembre",
			"octubre",
			"noviembre",
			"diciembre",
		},
	},
}

main()
