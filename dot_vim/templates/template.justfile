_listing:
	@printf "${BLU}{{justfile()}}${NOC}\n"
	@just --unsorted --list --list-heading='' --list-prefix=' • ' \
		| grep -v 'alias for'

test:
	# something to test

set shell := ["bash","-uc"]
# vim: ft=make
