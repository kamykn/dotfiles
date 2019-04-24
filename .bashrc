# .bashrc

# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ll='ls -l'
alias v='vim .'

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

if [ "$TERM" == "xterm" ]; then
	# No it isn't, it's gnome-terminal
	export TERM=xterm-256color
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# デフォルトでtmux起動
# if command -v tmux>/dev/null; then
# 	[[ ! $TERM =~ screen ]] && [ -z $TMUX ] && exec tmux
# fi

# オーソドックスなprompt
export PS1='\[\e[1;32m\]\u@\h:\w${text}$\[\e[m\] '

# FZF
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

fbr() {
	local branches branch
	branches=$(git branch -vv) &&
		branch=$(echo "$branches" | fzf +m) &&
		git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# リモートブランチ
fbrm() {
	local branches branch
	branches=$(git branch --all | grep -v HEAD) &&
	branch=$(echo "$branches" |
	fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
	git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

ffind() {
	local FIND_OPTION=''

	# 第一引数だけ見て-aかどうか評価するので注意
	if [ "${1}" != "-a" ]; then
		FIND_OPTION=" -type d -name '.*' -prune -or -not -name '.*'"
	fi

	eval find . "*" "${FIND_OPTION}" | fzf
}
