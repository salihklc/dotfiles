[user]
	name = ${GIT_USER_NAME}
	email = ${GIT_USER_EMAIL}

[init]
	defaultBranch = main

[pull]
	rebase = true

[push]
	autoSetupRemote = true

[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only

[merge]
	conflictstyle = diff3

[diff]
	colorMoved = default

[delta]
	navigate = true
	side-by-side = false
	line-numbers = true

[alias]
	l = log --oneline --graph --decorate -20